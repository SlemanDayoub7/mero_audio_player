package com.example.mero_audio_player

import android.os.Environment
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.UUID
import android.content.Intent
import android.net.Uri
import android.provider.Settings

class MainActivity: AudioServiceActivity()  {
    private val CHANNEL = "com.example.mero_audio_player/audio_trimmer"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            
            when (call.method) {
                "openWriteSettings"->{
                    val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS)
                    intent.data = Uri.parse("package:com.example.mero_audio_player")
                    if (intent.resolveActivity(packageManager) != null) {
                        startActivity(intent)
                        result.success(null)
                    } else {
                        result.error("UNAVAILABLE", "Cannot open WRITE_SETTINGS settings", null)
                    }
                }
                "trimAudio"-> {
                    val inputPath = call.argument<String>("inputPath")
                    val startMs = call.argument<Int>("startMs") ?: 0
                    val endMs = call.argument<Int>("endMs") ?: 30000
                    
                    if (inputPath == null) {
                        result.error("INVALID_PATH", "Input path is null", null)
                        return@setMethodCallHandler
                    }
                    
                    // Validate input file exists
                    val inputFile = File(inputPath)
                    if (!inputFile.exists()) {
                        result.error("FILE_NOT_FOUND", "Input file does not exist: $inputPath", null)
                        return@setMethodCallHandler
                    }
                    
                    try {
                        // Create output file in cache directory
                        val outputFile = File.createTempFile(
                            "trimmed_${UUID.randomUUID()}",
                            ".m4a",
                            cacheDir
                        )
                        
                        println("Trimming audio: $inputPath -> ${outputFile.absolutePath}")
                        println("Time range: ${startMs}ms to ${endMs}ms")
                        
                        // بدل AudioTrimmer.trimAudio بـ:
                        val success = AudioTrimmerWav.trimToWav(inputPath, outputFile.absolutePath, startMs.toLong(), endMs.toLong())

                        
                        if (success && outputFile.exists() && outputFile.length() > 0) {
                            println("Audio trimming successful. Output file size: ${outputFile.length()} bytes")
                            result.success(outputFile.absolutePath)
                        } else {
                            println("Audio trimming failed or output file is invalid")
                            // Clean up failed output file
                            if (outputFile.exists()) outputFile.delete()
                            result.error("TRIMMING_FAILED", "Audio trimming failed or produced invalid output", null)
                        }
                    } catch (e: Exception) {
                        println("Exception during trimming: ${e.message}")
                        e.printStackTrace()
                        result.error("EXCEPTION", "Error during trimming: ${e.message}", e.stackTraceToString())
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}