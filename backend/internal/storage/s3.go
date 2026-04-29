package storage

import (
	"bytes"
	"context"
	"fmt"
	"image"
	_ "image/gif"
	"image/jpeg"
	_ "image/png"
	"io"
	"log/slog"
	"path/filepath"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/google/uuid"
	"golang.org/x/image/draw"
	_ "golang.org/x/image/webp"
)

// S3Provider stores files in AWS S3 or S3-compatible storage (MinIO, DigitalOcean Spaces, etc.).
type S3Provider struct {
	client   *s3.Client
	bucket   string
	prefix   string // Key prefix (e.g. "uploads/")
	cdnURL   string // CDN/public URL base (e.g. "https://cdn.solennix.com")
}

// S3Config holds S3 provider configuration.
type S3Config struct {
	Bucket   string
	Region   string
	Prefix   string // Optional key prefix
	Endpoint string // Custom endpoint for MinIO/DO Spaces (empty for AWS)
	CDNURL   string // Public URL base for serving files
}

// NewS3Provider creates an S3 storage provider.
func NewS3Provider(ctx context.Context, cfg S3Config) (*S3Provider, error) {
	var opts []func(*config.LoadOptions) error
	opts = append(opts, config.WithRegion(cfg.Region))

	awsCfg, err := config.LoadDefaultConfig(ctx, opts...)
	if err != nil {
		return nil, fmt.Errorf("load AWS config: %w", err)
	}

	var clientOpts []func(*s3.Options)
	if cfg.Endpoint != "" {
		clientOpts = append(clientOpts, func(o *s3.Options) {
			o.BaseEndpoint = aws.String(cfg.Endpoint)
			o.UsePathStyle = true // Required for MinIO
		})
	}

	client := s3.NewFromConfig(awsCfg, clientOpts...)

	prefix := cfg.Prefix
	if prefix != "" && !strings.HasSuffix(prefix, "/") {
		prefix += "/"
	}

	cdnURL := cfg.CDNURL
	if cdnURL == "" {
		cdnURL = fmt.Sprintf("https://%s.s3.%s.amazonaws.com", cfg.Bucket, cfg.Region)
	}

	slog.Info("S3 storage provider initialized", "bucket", cfg.Bucket, "region", cfg.Region)
	return &S3Provider{
		client: client,
		bucket: cfg.Bucket,
		prefix: prefix,
		cdnURL: cdnURL,
	}, nil
}

func (p *S3Provider) Save(userID, originalFilename string, data io.Reader) (*FileResult, error) {
	ext := strings.ToLower(filepath.Ext(originalFilename))
	allowedExts := map[string]bool{".jpg": true, ".jpeg": true, ".png": true, ".gif": true, ".webp": true}
	if !allowedExts[ext] {
		ext = ".jpg"
	}
	filename := fmt.Sprintf("%s%s", uuid.New().String(), ext)
	key := fmt.Sprintf("%s%s/%s", p.prefix, userID, filename)

	// Read all data into memory for S3 upload
	buf, err := io.ReadAll(data)
	if err != nil {
		return nil, fmt.Errorf("read file data: %w", err)
	}

	contentType := "image/jpeg"
	switch ext {
	case ".png":
		contentType = "image/png"
	case ".gif":
		contentType = "image/gif"
	case ".webp":
		contentType = "image/webp"
	}

	_, err = p.client.PutObject(context.Background(), &s3.PutObjectInput{
		Bucket:      aws.String(p.bucket),
		Key:         aws.String(key),
		Body:        bytes.NewReader(buf),
		ContentType: aws.String(contentType),
	})
	if err != nil {
		return nil, fmt.Errorf("upload to S3: %w", err)
	}

	// TODO: Generate thumbnail via Lambda or server-side processing
	// For now, return the same URL for both
	url := fmt.Sprintf("%s/%s", p.cdnURL, key)

	return &FileResult{
		URL:                url,
		ThumbnailURL:       url, // Placeholder until thumbnail pipeline is set up
		Filename:           filename,
		ObjectKey:          fmt.Sprintf("%s/%s", userID, filename),
		ThumbnailObjectKey: fmt.Sprintf("%s/thumbnails/thumb_%s.jpg", userID, strings.TrimSuffix(filename, ext)),
		ContentType:        contentType,
	}, nil
}

func (p *S3Provider) PresignUpload(userID, originalFilename, contentType string) (*PresignResult, error) {
	if !strings.HasPrefix(strings.ToLower(contentType), "image/") {
		return nil, fmt.Errorf("only image content types are allowed")
	}

	ext := strings.ToLower(filepath.Ext(originalFilename))
	if ext == "" {
		ext = extFromContentType(contentType)
	}
	allowedExts := map[string]bool{".jpg": true, ".jpeg": true, ".png": true, ".gif": true, ".webp": true}
	if !allowedExts[ext] {
		ext = extFromContentType(contentType)
	}
	filename := fmt.Sprintf("%s%s", uuid.New().String(), ext)
	objectKey := fmt.Sprintf("%s/%s", userID, filename)
	fullKey := fmt.Sprintf("%s%s", p.prefix, objectKey)

	presigner := s3.NewPresignClient(p.client)
	expires := 15 * time.Minute
	out, err := presigner.PresignPutObject(context.Background(), &s3.PutObjectInput{
		Bucket:      aws.String(p.bucket),
		Key:         aws.String(fullKey),
		ContentType: aws.String(contentType),
	}, func(opts *s3.PresignOptions) {
		opts.Expires = expires
	})
	if err != nil {
		return nil, fmt.Errorf("presign upload: %w", err)
	}

	return &PresignResult{
		UploadURL:        out.URL,
		Method:           "PUT",
		Headers:          map[string]string{"Content-Type": contentType},
		ObjectKey:        objectKey,
		ExpiresInSeconds: int(expires.Seconds()),
		ContentType:      contentType,
	}, nil
}

func (p *S3Provider) CompletePresignedUpload(userID, objectKey string) (*FileResult, error) {
	objectKey = strings.TrimPrefix(strings.TrimSpace(objectKey), "/")
	if objectKey == "" {
		return nil, fmt.Errorf("object key is required")
	}
	if !strings.HasPrefix(objectKey, userID+"/") {
		return nil, fmt.Errorf("object key does not belong to user")
	}

	fullKey := fmt.Sprintf("%s%s", p.prefix, objectKey)
	obj, err := p.client.GetObject(context.Background(), &s3.GetObjectInput{
		Bucket: aws.String(p.bucket),
		Key:    aws.String(fullKey),
	})
	if err != nil {
		return nil, fmt.Errorf("get uploaded object: %w", err)
	}
	defer obj.Body.Close()

	buf, err := io.ReadAll(obj.Body)
	if err != nil {
		return nil, fmt.Errorf("read uploaded object: %w", err)
	}

	filename := filepath.Base(objectKey)
	ext := strings.ToLower(filepath.Ext(filename))
	thumbFilename := fmt.Sprintf("thumb_%s.jpg", strings.TrimSuffix(filename, ext))
	thumbObjectKey := fmt.Sprintf("%s/thumbnails/%s", userID, thumbFilename)
	fullThumbKey := fmt.Sprintf("%s%s", p.prefix, thumbObjectKey)

	if thumbBytes, genErr := generateThumbnailBytes(buf); genErr == nil {
		_, putErr := p.client.PutObject(context.Background(), &s3.PutObjectInput{
			Bucket:      aws.String(p.bucket),
			Key:         aws.String(fullThumbKey),
			Body:        bytes.NewReader(thumbBytes),
			ContentType: aws.String("image/jpeg"),
		})
		if putErr != nil {
			slog.Warn("S3 thumbnail upload failed after presigned completion", "error", putErr)
		}
	} else {
		slog.Warn("S3 thumbnail generation failed after presigned completion", "error", genErr)
	}

	contentType := aws.ToString(obj.ContentType)
	if contentType == "" {
		contentType = detectContentTypeFromExt(ext)
	}

	originalURL := fmt.Sprintf("%s/%s", strings.TrimRight(p.cdnURL, "/"), fullKey)
	thumbnailURL := fmt.Sprintf("%s/%s", strings.TrimRight(p.cdnURL, "/"), fullThumbKey)

	return &FileResult{
		URL:                originalURL,
		ThumbnailURL:       thumbnailURL,
		Filename:           filename,
		ObjectKey:          objectKey,
		ThumbnailObjectKey: thumbObjectKey,
		ContentType:        contentType,
	}, nil
}

func (p *S3Provider) Delete(path string) error {
	key := p.prefix + path
	_, err := p.client.DeleteObject(context.Background(), &s3.DeleteObjectInput{
		Bucket: aws.String(p.bucket),
		Key:    aws.String(key),
	})
	return err
}

func (p *S3Provider) URL(path string) string {
	return fmt.Sprintf("%s/%s%s", p.cdnURL, p.prefix, path)
}

func extFromContentType(contentType string) string {
	ct := strings.ToLower(strings.TrimSpace(strings.Split(contentType, ";")[0]))
	switch ct {
	case "image/png":
		return ".png"
	case "image/gif":
		return ".gif"
	case "image/webp":
		return ".webp"
	case "image/jpeg", "image/jpg":
		return ".jpg"
	default:
		return ".jpg"
	}
}

func generateThumbnailBytes(original []byte) ([]byte, error) {
	srcImg, _, err := image.Decode(bytes.NewReader(original))
	if err != nil {
		return nil, fmt.Errorf("decode image: %w", err)
	}

	bounds := srcImg.Bounds()
	imgW, imgH := bounds.Dx(), bounds.Dy()
	maxDim := 200

	var newW, newH int
	if imgW > imgH {
		newW = maxDim
		newH = int(float64(imgH) * float64(maxDim) / float64(imgW))
	} else {
		newH = maxDim
		newW = int(float64(imgW) * float64(maxDim) / float64(imgH))
	}
	if newW < 1 {
		newW = 1
	}
	if newH < 1 {
		newH = 1
	}

	thumb := image.NewRGBA(image.Rect(0, 0, newW, newH))
	draw.ApproxBiLinear.Scale(thumb, thumb.Bounds(), srcImg, srcImg.Bounds(), draw.Over, nil)

	var out bytes.Buffer
	if err := jpeg.Encode(&out, thumb, &jpeg.Options{Quality: 80}); err != nil {
		return nil, fmt.Errorf("encode thumbnail: %w", err)
	}

	return out.Bytes(), nil
}
