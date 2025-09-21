package com.example.mero_audio_player

import android.content.ContentValues
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = " com.example.mero_audio_player/mychannel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        // تسجيل جميع الـ Plugins أولًا
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setRingtone" -> {
                        val path = call.argument<String>("path")!!
                        // التحقق من صلاحية WRITE_SETTINGS
                        if (!Settings.System.canWrite(this)) {
                            val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS)
                            intent.data = Uri.parse("package:$packageName")
                            startActivity(intent)
                            result.error("PERMISSION", "Need WRITE_SETTINGS permission", null)
                            return@setMethodCallHandler
                        }

                        val success = setRingtone(path)
                        if (success) result.success(null)
                        else result.error("ERROR", "Failed to set ringtone", null)
                    }

                    "canWriteSettings" -> {
                        // تعريف method للتحقق من صلاحية WRITE_SETTINGS
                        result.success(Settings.System.canWrite(this))
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun setRingtone(filePath: String): Boolean {
        return try {
            val file = File(filePath)
            if (!file.exists()) return false

            val mimeType = when(file.extension.lowercase()) {
                "mp3" -> "audio/mp3"
                "wav" -> "audio/wav"
                "ogg" -> "audio/ogg"
                "m4a", "aac" -> "audio/mp4"
                "flac" -> "audio/flac"
                else -> "audio/*"
            }

            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DATA, file.absolutePath)
                put(MediaStore.MediaColumns.TITLE, file.nameWithoutExtension)
                put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                put(MediaStore.Audio.Media.IS_RINGTONE, true)
                put(MediaStore.Audio.Media.IS_NOTIFICATION, false)
                put(MediaStore.Audio.Media.IS_ALARM, true)
                put(MediaStore.Audio.Media.IS_MUSIC, false)
            }

            val uri: Uri = MediaStore.Audio.Media.getContentUriForPath(file.absolutePath)!!
            val newUri = contentResolver.insert(uri, values)
            RingtoneManager.setActualDefaultRingtoneUri(this, RingtoneManager.TYPE_RINGTONE, newUri)
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}
