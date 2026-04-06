package storage

import (
	"bytes"
	"image"
	"image/color"
	"image/png"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func encodePNG(t *testing.T, width, height int) *bytes.Reader {
	t.Helper()
	img := image.NewRGBA(image.Rect(0, 0, width, height))
	for y := 0; y < height; y++ {
		for x := 0; x < width; x++ {
			img.Set(x, y, color.RGBA{R: 255, G: 0, B: 0, A: 255})
		}
	}
	var buf bytes.Buffer
	require.NoError(t, png.Encode(&buf, img))
	return bytes.NewReader(buf.Bytes())
}

func createTestImageFile(t *testing.T, dir, filename string, width, height int) string {
	t.Helper()
	img := image.NewRGBA(image.Rect(0, 0, width, height))
	for y := 0; y < height; y++ {
		for x := 0; x < width; x++ {
			img.Set(x, y, color.RGBA{R: 255, G: 0, B: 0, A: 255})
		}
	}
	path := filepath.Join(dir, filename)
	f, err := os.Create(path)
	require.NoError(t, err)
	defer f.Close()
	require.NoError(t, png.Encode(f, img))
	return path
}

// =============================================================================
// NewLocalProvider
// =============================================================================

func TestNewLocalProvider_GivenValidDir_WhenCreated_ThenDirExists(t *testing.T) {
	dir := filepath.Join(t.TempDir(), "uploads")
	provider := NewLocalProvider(dir, "/api/uploads")

	assert.NotNil(t, provider)
	info, err := os.Stat(dir)
	require.NoError(t, err)
	assert.True(t, info.IsDir())
}

func TestNewLocalProvider_GivenExistingDir_WhenCreated_ThenNoError(t *testing.T) {
	dir := t.TempDir()
	provider := NewLocalProvider(dir, "/api/uploads")
	assert.NotNil(t, provider)
}

// =============================================================================
// Save
// =============================================================================

func TestSave_GivenPNGFile_WhenSaved_ThenFileExistsOnDisk(t *testing.T) {
	dir := t.TempDir()
	provider := NewLocalProvider(dir, "/api/uploads")

	data := encodePNG(t, 50, 50)
	result, err := provider.Save("user-123", "test.png", data)

	require.NoError(t, err)
	assert.Contains(t, result.URL, "/api/uploads/user-123/")
	assert.Contains(t, result.URL, ".png")
	assert.Contains(t, result.ThumbnailURL, "/api/uploads/user-123/thumbnails/")
	assert.NotEmpty(t, result.Filename)

	// Verify file exists on disk
	entries, err := os.ReadDir(filepath.Join(dir, "user-123"))
	require.NoError(t, err)
	assert.GreaterOrEqual(t, len(entries), 1)
}

func TestSave_GivenJPGExtension_WhenSaved_ThenFilenameHasJPG(t *testing.T) {
	dir := t.TempDir()
	provider := NewLocalProvider(dir, "/api/uploads")

	data := encodePNG(t, 10, 10)
	result, err := provider.Save("user-456", "photo.jpg", data)

	require.NoError(t, err)
	assert.Contains(t, result.Filename, ".jpg")
}

func TestSave_GivenJPEGExtension_WhenSaved_ThenFilenameHasJPEG(t *testing.T) {
	dir := t.TempDir()
	provider := NewLocalProvider(dir, "/api/uploads")

	data := encodePNG(t, 10, 10)
	result, err := provider.Save("user-jpeg", "photo.jpeg", data)

	require.NoError(t, err)
	assert.Contains(t, result.Filename, ".jpeg")
}

func TestSave_GivenUnknownExtension_WhenSaved_ThenDefaultsToJPG(t *testing.T) {
	dir := t.TempDir()
	provider := NewLocalProvider(dir, "/api/uploads")

	content := strings.NewReader("fake data")
	result, err := provider.Save("user-789", "document.bmp", content)

	require.NoError(t, err)
	assert.Contains(t, result.Filename, ".jpg")
}

func TestSave_GivenAllAllowedExtensions_WhenSaved_ThenPreservesEach(t *testing.T) {
	dir := t.TempDir()
	provider := NewLocalProvider(dir, "/api/uploads")

	allowedExts := []string{".jpg", ".jpeg", ".png", ".gif", ".webp"}
	for _, ext := range allowedExts {
		content := strings.NewReader("fake data")
		result, err := provider.Save("user-ext", "file"+ext, content)
		require.NoError(t, err, "extension %s should be allowed", ext)
		assert.Contains(t, result.Filename, ext, "expected extension %s in filename", ext)
	}
}

func TestSave_GivenUpperCaseExtension_WhenSaved_ThenNormalizesToLower(t *testing.T) {
	dir := t.TempDir()
	provider := NewLocalProvider(dir, "/api/uploads")

	content := strings.NewReader("fake data")
	result, err := provider.Save("user-upper", "PHOTO.PNG", content)

	require.NoError(t, err)
	assert.Contains(t, result.Filename, ".png")
}

func TestSave_GivenMultipleFiles_WhenSaved_ThenEachHasUniqueFilename(t *testing.T) {
	dir := t.TempDir()
	provider := NewLocalProvider(dir, "/api/uploads")

	filenames := make(map[string]bool)
	for i := 0; i < 5; i++ {
		content := strings.NewReader("data")
		result, err := provider.Save("user-multi", "image.png", content)
		require.NoError(t, err)
		assert.False(t, filenames[result.Filename], "filename should be unique")
		filenames[result.Filename] = true
	}
}

// =============================================================================
// Delete
// =============================================================================

func TestDelete_GivenExistingFile_WhenDeleted_ThenFileRemoved(t *testing.T) {
	dir := t.TempDir()
	provider := NewLocalProvider(dir, "/api/uploads")

	userDir := filepath.Join(dir, "user-del")
	require.NoError(t, os.MkdirAll(userDir, 0755))
	testFile := filepath.Join(userDir, "delete-me.jpg")
	require.NoError(t, os.WriteFile(testFile, []byte("content"), 0644))

	err := provider.Delete("user-del/delete-me.jpg")
	assert.NoError(t, err)

	_, err = os.Stat(testFile)
	assert.True(t, os.IsNotExist(err))
}

func TestDelete_GivenNonExistentFile_WhenDeleted_ThenReturnsError(t *testing.T) {
	dir := t.TempDir()
	provider := NewLocalProvider(dir, "/api/uploads")

	err := provider.Delete("nonexistent/file.jpg")
	assert.Error(t, err)
}

// =============================================================================
// URL
// =============================================================================

func TestURL_GivenPath_WhenCalled_ThenReturnsPrefixedURL(t *testing.T) {
	provider := NewLocalProvider(t.TempDir(), "/api/uploads")

	url := provider.URL("user-123/image.jpg")
	assert.Equal(t, "/api/uploads/user-123/image.jpg", url)
}

func TestURL_GivenEmptyPath_WhenCalled_ThenReturnsPrefix(t *testing.T) {
	provider := NewLocalProvider(t.TempDir(), "/api/uploads")

	url := provider.URL("")
	assert.Equal(t, "/api/uploads/", url)
}

// =============================================================================
// GenerateThumbnail
// =============================================================================

func TestGenerateThumbnail_GivenValidPNG_WhenGenerated_ThenThumbnailCreated(t *testing.T) {
	dir := t.TempDir()
	thumbDir := filepath.Join(dir, "thumbnails")
	require.NoError(t, os.MkdirAll(thumbDir, 0755))

	srcPath := createTestImageFile(t, dir, "source.png", 100, 100)
	GenerateThumbnail(srcPath, thumbDir, "thumb_source.jpg")

	thumbPath := filepath.Join(thumbDir, "thumb_source.jpg")
	info, err := os.Stat(thumbPath)
	require.NoError(t, err)
	assert.Greater(t, info.Size(), int64(0))
}

func TestGenerateThumbnail_GivenWideImage_WhenGenerated_ThenFileExists(t *testing.T) {
	dir := t.TempDir()
	thumbDir := filepath.Join(dir, "thumbnails")
	require.NoError(t, os.MkdirAll(thumbDir, 0755))

	srcPath := createTestImageFile(t, dir, "wide.png", 400, 100)
	GenerateThumbnail(srcPath, thumbDir, "thumb_wide.jpg")

	_, err := os.Stat(filepath.Join(thumbDir, "thumb_wide.jpg"))
	require.NoError(t, err)
}

func TestGenerateThumbnail_GivenTallImage_WhenGenerated_ThenFileExists(t *testing.T) {
	dir := t.TempDir()
	thumbDir := filepath.Join(dir, "thumbnails")
	require.NoError(t, os.MkdirAll(thumbDir, 0755))

	srcPath := createTestImageFile(t, dir, "tall.png", 100, 400)
	GenerateThumbnail(srcPath, thumbDir, "thumb_tall.jpg")

	_, err := os.Stat(filepath.Join(thumbDir, "thumb_tall.jpg"))
	require.NoError(t, err)
}

func TestGenerateThumbnail_GivenSmallImage_WhenGenerated_ThenFileExists(t *testing.T) {
	dir := t.TempDir()
	thumbDir := filepath.Join(dir, "thumbnails")
	require.NoError(t, os.MkdirAll(thumbDir, 0755))

	// Tiny image that would produce < 1 pixel dimensions without the min clamp
	srcPath := createTestImageFile(t, dir, "tiny.png", 1, 1)
	GenerateThumbnail(srcPath, thumbDir, "thumb_tiny.jpg")

	_, err := os.Stat(filepath.Join(thumbDir, "thumb_tiny.jpg"))
	require.NoError(t, err)
}

func TestGenerateThumbnail_GivenNonExistentSource_WhenCalled_ThenNoThumbnail(t *testing.T) {
	dir := t.TempDir()
	GenerateThumbnail("/nonexistent/source.png", dir, "thumb.jpg")

	_, err := os.Stat(filepath.Join(dir, "thumb.jpg"))
	assert.True(t, os.IsNotExist(err))
}

func TestGenerateThumbnail_GivenInvalidImageData_WhenCalled_ThenNoThumbnail(t *testing.T) {
	dir := t.TempDir()
	thumbDir := filepath.Join(dir, "thumbnails")
	require.NoError(t, os.MkdirAll(thumbDir, 0755))

	badFile := filepath.Join(dir, "not-image.png")
	require.NoError(t, os.WriteFile(badFile, []byte("this is not an image"), 0644))

	GenerateThumbnail(badFile, thumbDir, "thumb_bad.jpg")

	_, err := os.Stat(filepath.Join(thumbDir, "thumb_bad.jpg"))
	assert.True(t, os.IsNotExist(err))
}

// =============================================================================
// Interface compliance
// =============================================================================

func TestLocalProvider_ImplementsProviderInterface(t *testing.T) {
	var _ Provider = (*LocalProvider)(nil)
}
