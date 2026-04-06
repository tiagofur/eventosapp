package com.creapolis.solennix.core.data.util

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import androidx.exifinterface.media.ExifInterface
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream

object ImageCompressor {

    /**
     * Compresses and resizes an image from a ByteArray.
     * 
     * @param bytes The original image bytes.
     * @param maxDimension The maximum width or height of the resulting image.
     * @param quality The JPEG compression quality (0-100).
     * @return The compressed image bytes.
     */
    fun compress(
        bytes: ByteArray,
        maxDimension: Int = 1280,
        quality: Int = 80
    ): ByteArray {
        try {
            // 1. Decode bounds to check size without loading entire image into memory
            val options = BitmapFactory.Options().apply {
                inJustDecodeBounds = true
            }
            BitmapFactory.decodeByteArray(bytes, 0, bytes.size, options)

            // 2. Calculate sample size to scale down during decoding
            options.inSampleSize = calculateInSampleSize(options, maxDimension, maxDimension)
            options.inJustDecodeBounds = false

            // 3. Decode actual bitmap with sample size
            var bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size, options) ?: return bytes

            // 4. Handle rotation from EXIF if possible
            bitmap = rotateImageIfRequired(bitmap, bytes)

            // 5. Final resize to exact maxDimension if still larger
            if (bitmap.width > maxDimension || bitmap.height > maxDimension) {
                bitmap = resizeBitmap(bitmap, maxDimension)
            }

            // 6. Compress to JPEG
            val outputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.JPEG, quality, outputStream)
            val compressedBytes = outputStream.toByteArray()
            
            // Clean up
            bitmap.recycle()
            
            return compressedBytes
        } catch (e: Exception) {
            e.printStackTrace()
            return bytes // Return original if something fails
        }
    }

    private fun calculateInSampleSize(options: BitmapFactory.Options, reqWidth: Int, maxDimension: Int): Int {
        val (height: Int, width: Int) = options.outHeight to options.outWidth
        var inSampleSize = 1

        if (height > maxDimension || width > maxDimension) {
            val halfHeight: Int = height / 2
            val halfWidth: Int = width / 2

            while (halfHeight / inSampleSize >= maxDimension && halfWidth / inSampleSize >= maxDimension) {
                inSampleSize *= 2
            }
        }
        return inSampleSize
    }

    private fun resizeBitmap(bitmap: Bitmap, maxDimension: Int): Bitmap {
        val width = bitmap.width
        val height = bitmap.height
        
        val scale = if (width > height) {
            maxDimension.toFloat() / width
        } else {
            maxDimension.toFloat() / height
        }
        
        val newWidth = (width * scale).toInt()
        val newHeight = (height * scale).toInt()
        
        return Bitmap.createScaledBitmap(bitmap, newWidth, newHeight, true)
    }

    private fun rotateImageIfRequired(img: Bitmap, bytes: ByteArray): Bitmap {
        return try {
            val ei = ExifInterface(ByteArrayInputStream(bytes))
            val orientation = ei.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL)

            when (orientation) {
                ExifInterface.ORIENTATION_ROTATE_90 -> rotateImage(img, 90f)
                ExifInterface.ORIENTATION_ROTATE_180 -> rotateImage(img, 180f)
                ExifInterface.ORIENTATION_ROTATE_270 -> rotateImage(img, 270f)
                else -> img
            }
        } catch (e: Exception) {
            img
        }
    }

    private fun rotateImage(img: Bitmap, degree: Float): Bitmap {
        val matrix = Matrix()
        matrix.postRotate(degree)
        val rotatedImg = Bitmap.createBitmap(img, 0, 0, img.width, img.height, matrix, true)
        img.recycle()
        return rotatedImg
    }
}
