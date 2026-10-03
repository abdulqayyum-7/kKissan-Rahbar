package com.kissanrahbar.app

import android.app.Activity
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.content.Intent
import android.speech.RecognizerIntent
import android.net.Uri
import java.io.ByteArrayOutputStream
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.kissanrahbar.app/speech"
    private val speechRequestCode = 7401
    private val imageRequestCode = 7402
    private var speechResult: MethodChannel.Result? = null
    private var imageResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "pickImage") {
                    if (imageResult != null) {
                        result.error("busy", "Image selection is already open.", null)
                        return@setMethodCallHandler
                    }
                    val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
                        type = "image/*"
                        addCategory(Intent.CATEGORY_OPENABLE)
                    }
                    imageResult = result
                    try {
                        startActivityForResult(
                            Intent.createChooser(intent, "Choose a crop or pest photo"),
                            imageRequestCode,
                        )
                    } catch (error: Exception) {
                        imageResult = null
                        result.error("unavailable", error.localizedMessage ?: "Could not open your photos.", null)
                    }
                    return@setMethodCallHandler
                }
                if (call.method != "listen") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                if (speechResult != null) {
                    result.error("busy", "Speech recognition is already open.", null)
                    return@setMethodCallHandler
                }
                val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                    putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                    putExtra(RecognizerIntent.EXTRA_LANGUAGE, call.argument<String>("locale") ?: "ur-PK")
                    putExtra(RecognizerIntent.EXTRA_PROMPT, "اپنا زرعی سوال بولیں")
                    putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
                }
                if (intent.resolveActivity(packageManager) == null) {
                    result.error("unavailable", "No speech recognition service is available on this device.", null)
                    return@setMethodCallHandler
                }
                speechResult = result
                try {
                    startActivityForResult(intent, speechRequestCode)
                } catch (error: Exception) {
                    speechResult = null
                    result.error("unavailable", error.localizedMessage ?: "Could not open speech recognition.", null)
                }
            }
    }

    @Deprecated("Deprecated in Android, retained for the speech recognition activity result")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == imageRequestCode) {
            val pending = imageResult ?: return
            imageResult = null
            if (resultCode != Activity.RESULT_OK) {
                pending.success(null)
                return
            }
            val uri = data?.data
            if (uri == null) {
                pending.error("unavailable", "The selected photo could not be opened.", null)
                return
            }
            try {
                val image = compressImage(uri)
                pending.success(mapOf("bytes" to image, "mimeType" to "image/jpeg"))
            } catch (error: Exception) {
                pending.error("invalid_image", error.localizedMessage ?: "The selected image could not be read.", null)
            }
            return
        }
        if (requestCode != speechRequestCode) return
        val pending = speechResult ?: return
        speechResult = null
        if (resultCode == Activity.RESULT_OK) {
            val transcript = data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)?.firstOrNull()
            if (transcript.isNullOrBlank()) pending.error("empty", "No speech was recognized. Try again.", null)
            else pending.success(transcript)
        } else {
            pending.success(null)
        }
    }

    private fun compressImage(uri: Uri): ByteArray {
        val source = contentResolver.openInputStream(uri)?.use { input ->
            val output = ByteArrayOutputStream()
            val buffer = ByteArray(8 * 1024)
            var total = 0
            while (true) {
                val count = input.read(buffer)
                if (count < 0) break
                total += count
                if (total > 20 * 1024 * 1024) {
                    throw IllegalArgumentException("Choose an image smaller than 20 MB.")
                }
                output.write(buffer, 0, count)
            }
            output.toByteArray()
        } ?: throw IllegalArgumentException("Could not read the selected photo.")

        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeByteArray(source, 0, source.size, bounds)
        if (bounds.outWidth <= 0 || bounds.outHeight <= 0) {
            throw IllegalArgumentException("This image format is not supported.")
        }

        var sampleSize = 1
        while (maxOf(bounds.outWidth, bounds.outHeight) / sampleSize > 1440) {
            sampleSize *= 2
        }
        val options = BitmapFactory.Options().apply { inSampleSize = sampleSize }
        val bitmap = BitmapFactory.decodeByteArray(source, 0, source.size, options)
            ?: throw IllegalArgumentException("This image could not be decoded.")

        try {
            var quality = 82
            var compressed: ByteArray
            do {
                val output = ByteArrayOutputStream()
                bitmap.compress(Bitmap.CompressFormat.JPEG, quality, output)
                compressed = output.toByteArray()
                quality -= 10
            } while (compressed.size > 2 * 1024 * 1024 && quality >= 52)

            if (compressed.size > 2 * 1024 * 1024) {
                throw IllegalArgumentException("This photo is too large to attach. Choose a smaller image.")
            }
            return compressed
        } finally {
            if (!bitmap.isRecycled) bitmap.recycle()
        }
    }
}
