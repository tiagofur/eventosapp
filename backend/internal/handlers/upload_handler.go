package handlers

import (
	"fmt"
	"image"
	"image/jpeg"
	_ "image/png"
	"io"
	"log/slog"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"github.com/google/uuid"
	"github.com/tiagofur/solennix-backend/internal/middleware"
	"golang.org/x/image/draw"
)

// UploadHandler handles image uploads, organizing files by user ID.
type UploadHandler struct {
	uploadDir string
	userRepo  UserRepository
}

func NewUploadHandler(uploadDir string, userRepo UserRepository) *UploadHandler {
	// Ensure base upload directory exists
	if err := os.MkdirAll(uploadDir, 0755); err != nil {
		slog.Error("Failed to create upload directory", "dir", uploadDir, "error", err)
	}
	return &UploadHandler{uploadDir: uploadDir, userRepo: userRepo}
}

// maxUploadsForPlan returns the maximum number of uploads allowed per user based on plan.
func maxUploadsForPlan(plan string) int {
	switch plan {
	case "pro":
		return 200
	default: // basic
		return 50
	}
}

// countUserUploads counts the number of files in a user's upload directory.
func countUserUploads(userDir string) int {
	entries, err := os.ReadDir(userDir)
	if err != nil {
		return 0 // Directory doesn't exist yet, 0 uploads
	}
	count := 0
	for _, e := range entries {
		if !e.IsDir() {
			count++
		}
	}
	return count
}

// UploadImage handles POST /api/uploads/image
// Accepts multipart/form-data with a "file" field.
// Files are stored in {uploadDir}/{userID}/ for per-user organization.
// Returns JSON with the image URL and thumbnail URL.
func (h *UploadHandler) UploadImage(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	// Check upload limits per user plan
	if h.userRepo != nil {
		user, err := h.userRepo.GetByID(r.Context(), userID)
		if err != nil {
			writeError(w, http.StatusInternalServerError, "User not found")
			return
		}
		userDir := filepath.Join(h.uploadDir, userID.String())
		currentCount := countUserUploads(userDir)
		maxUploads := maxUploadsForPlan(user.Plan)
		if currentCount >= maxUploads {
			writeError(w, http.StatusForbidden, fmt.Sprintf(
				"Upload limit reached (%d/%d). Upgrade your plan for more uploads.", currentCount, maxUploads))
			return
		}
	}

	// Limit upload size to 10MB
	r.Body = http.MaxBytesReader(w, r.Body, 10<<20)

	if err := r.ParseMultipartForm(10 << 20); err != nil {
		if err.Error() == "http: request body too large" {
			writeError(w, http.StatusBadRequest, "File too large (max 10MB)")
		} else {
			writeError(w, http.StatusBadRequest, "Invalid multipart form data")
		}
		return
	}

	file, header, err := r.FormFile("file")
	if err != nil {
		writeError(w, http.StatusBadRequest, "Missing file field")
		return
	}
	defer file.Close()

	// Validate file content by reading magic bytes (don't trust client Content-Type header)
	buf := make([]byte, 512)
	n, err := file.Read(buf)
	if err != nil && err != io.EOF {
		writeError(w, http.StatusBadRequest, "Failed to read file")
		return
	}
	detectedType := http.DetectContentType(buf[:n])
	if !strings.HasPrefix(detectedType, "image/") {
		writeError(w, http.StatusBadRequest, "Only image files are allowed")
		return
	}
	// Reset file reader position after sniffing
	if seeker, ok := file.(io.Seeker); ok {
		seeker.Seek(0, io.SeekStart)
	}

	// Whitelist allowed extensions
	ext := strings.ToLower(filepath.Ext(header.Filename))
	allowedExts := map[string]bool{".jpg": true, ".jpeg": true, ".png": true, ".gif": true, ".webp": true}
	if !allowedExts[ext] {
		ext = ".jpg" // Default to .jpg for unknown/disallowed extensions
	}
	filename := fmt.Sprintf("%s%s", uuid.New().String(), ext)

	// Create user-specific directories
	userDir := filepath.Join(h.uploadDir, userID.String())
	userThumbDir := filepath.Join(userDir, "thumbnails")
	for _, dir := range []string{userDir, userThumbDir} {
		if err := os.MkdirAll(dir, 0755); err != nil {
			slog.Error("Failed to create user upload directory", "dir", dir, "error", err)
			writeError(w, http.StatusInternalServerError, "Failed to save file")
			return
		}
	}

	// Save original file
	dstPath := filepath.Join(userDir, filename)
	dst, err := os.Create(dstPath)
	if err != nil {
		slog.Error("Failed to create file", "path", dstPath, "error", err)
		writeError(w, http.StatusInternalServerError, "Failed to save file")
		return
	}
	defer dst.Close()

	if _, err := io.Copy(dst, file); err != nil {
		slog.Error("Failed to write file", "error", err)
		writeError(w, http.StatusInternalServerError, "Failed to save file")
		return
	}

	// Generate thumbnail (200x200 max) — synchronous to ensure it exists before responding
	thumbFilename := fmt.Sprintf("thumb_%s.jpg", strings.TrimSuffix(filename, ext))
	h.generateThumbnail(dstPath, filepath.Join(userDir, "thumbnails"), thumbFilename)

	slog.Info("Image uploaded", "user_id", userID, "filename", filename)

	writeJSON(w, http.StatusOK, map[string]string{
		"url":           fmt.Sprintf("/api/uploads/%s/%s", userID.String(), filename),
		"thumbnail_url": fmt.Sprintf("/api/uploads/%s/thumbnails/%s", userID.String(), thumbFilename),
		"filename":      filename,
	})
}

func (uh *UploadHandler) generateThumbnail(srcPath, thumbDir, thumbFilename string) {
	srcFile, err := os.Open(srcPath)
	if err != nil {
		slog.Error("Failed to open source for thumbnail", "error", err)
		return
	}
	defer srcFile.Close()

	srcImg, _, err := image.Decode(srcFile)
	if err != nil {
		slog.Error("Failed to decode image for thumbnail", "error", err)
		return
	}

	// Calculate thumbnail dimensions (max 200x200 maintaining aspect ratio)
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

	thumbPath := filepath.Join(thumbDir, thumbFilename)
	thumbFile, err := os.Create(thumbPath)
	if err != nil {
		slog.Error("Failed to create thumbnail file", "error", err)
		return
	}
	defer thumbFile.Close()

	if err := jpeg.Encode(thumbFile, thumb, &jpeg.Options{Quality: 80}); err != nil {
		slog.Error("Failed to encode thumbnail", "error", err)
	}
}

