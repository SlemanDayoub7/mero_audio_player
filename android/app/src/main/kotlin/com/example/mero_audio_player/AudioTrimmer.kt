package com.example.mero_audio_player

import android.media.*
import java.io.File
import java.io.FileOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.io.RandomAccessFile

class AudioTrimmerWav {

    companion object {

        fun trimToWav(inputPath: String, outputPath: String, startMs: Long, endMs: Long): Boolean {
            var extractor: MediaExtractor? = null
            var decoder: MediaCodec? = null
            var outputStream: FileOutputStream? = null

            return try {
                extractor = MediaExtractor()
                extractor.setDataSource(inputPath)

                // ابحث عن تراك الصوت
                var audioTrackIndex = -1
                var audioFormat: MediaFormat? = null
                for (i in 0 until extractor.trackCount) {
                    val format = extractor.getTrackFormat(i)
                    val mime = format.getString(MediaFormat.KEY_MIME)
                    if (mime?.startsWith("audio/") == true) {
                        audioTrackIndex = i
                        audioFormat = format
                        break
                    }
                }

                if (audioTrackIndex == -1) {
                    println("No audio track found")
                    return false
                }

                extractor.selectTrack(audioTrackIndex)

                // أنشئ decoder للصيغة الأصلية
                val mime = audioFormat!!.getString(MediaFormat.KEY_MIME)!!
                decoder = MediaCodec.createDecoderByType(mime)
                decoder.configure(audioFormat, null, null, 0)
                decoder.start()

                // ابدأ عند startMs
                extractor.seekTo(startMs * 1000, MediaExtractor.SEEK_TO_CLOSEST_SYNC)

                // افتح output stream للـ WAV
                outputStream = FileOutputStream(File(outputPath))
                // سنكتب هيدر WAV مؤقتاً
                val wavHeader = ByteArray(44)
                outputStream.write(wavHeader)

                val bufferInfo = MediaCodec.BufferInfo()
                var sawEOS = false
                var totalPcmBytes = 0L
                val pcmBuffer = ByteBuffer.allocate(65536)

                // نقرأ الـ samples ونفكها
                while (!sawEOS) {
                    // feed decoder
                    val inputBufferIndex = decoder.dequeueInputBuffer(10_000)
                    if (inputBufferIndex >= 0) {
                        val inputBuffer = decoder.getInputBuffer(inputBufferIndex)!!
                        val sampleSize = extractor.readSampleData(inputBuffer, 0)
                        if (sampleSize < 0) {
                            decoder.queueInputBuffer(
                                inputBufferIndex,
                                0,
                                0,
                                0,
                                MediaCodec.BUFFER_FLAG_END_OF_STREAM
                            )
                        } else {
                            val presentationTimeUs = extractor.sampleTime
                            if (presentationTimeUs > endMs * 1000) {
                                // وصلنا للنهاية
                                decoder.queueInputBuffer(
                                    inputBufferIndex,
                                    0,
                                    0,
                                    0,
                                    MediaCodec.BUFFER_FLAG_END_OF_STREAM
                                )
                            } else {
                                decoder.queueInputBuffer(
                                    inputBufferIndex,
                                    0,
                                    sampleSize,
                                    presentationTimeUs,
                                    0
                                )
                                extractor.advance()
                            }
                        }
                    }

                    // read decoded PCM
                    val outputBufferIndex = decoder.dequeueOutputBuffer(bufferInfo, 10_000)
                    if (outputBufferIndex >= 0) {
                        val outBuffer = decoder.getOutputBuffer(outputBufferIndex)!!
                        if (bufferInfo.size > 0) {
                            outBuffer.position(bufferInfo.offset)
                            outBuffer.limit(bufferInfo.offset + bufferInfo.size)
                            // PCM عادة 16 بت little-endian
                            val pcm = ByteArray(bufferInfo.size)
                            outBuffer.get(pcm)
                            outputStream.write(pcm)
                            totalPcmBytes += pcm.size
                        }
                        decoder.releaseOutputBuffer(outputBufferIndex, false)
                        if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                            sawEOS = true
                        }
                    }
                }

                // حدث هيدر WAV بالأحجام الصحيحة
                val sampleRate = audioFormat.getInteger(MediaFormat.KEY_SAMPLE_RATE)
                val channels = audioFormat.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
                val bitsPerSample = 16 // نفترض 16 بت
                val header = createWavHeader(
                    totalPcmBytes,
                    sampleRate,
                    channels,
                    bitsPerSample
                )
                val raf = RandomAccessFile(outputPath, "rw")
                raf.seek(0)
                raf.write(header)
                raf.close()

                println("Finished trimming to WAV: $outputPath size=$totalPcmBytes bytes PCM")
                true
            } catch (e: Exception) {
                e.printStackTrace()
                false
            } finally {
                try {
                    extractor?.release()
                } catch (_: Exception) {
                }
                try {
                    decoder?.stop()
                    decoder?.release()
                } catch (_: Exception) {
                }
                try {
                    outputStream?.close()
                } catch (_: Exception) {
                }
            }
        }

        private fun createWavHeader(
            totalAudioLen: Long,
            sampleRate: Int,
            channels: Int,
            bitsPerSample: Int
        ): ByteArray {
            val totalDataLen = totalAudioLen + 36
            val byteRate = sampleRate * channels * bitsPerSample / 8

            val header = ByteArray(44)
            val bb = ByteBuffer.wrap(header)
            bb.order(ByteOrder.LITTLE_ENDIAN)
            // ChunkID "RIFF"
            header[0] = 'R'.code.toByte()
            header[1] = 'I'.code.toByte()
            header[2] = 'F'.code.toByte()
            header[3] = 'F'.code.toByte()
            // ChunkSize
            bb.putInt(4, totalDataLen.toInt())
            // Format "WAVE"
            header[8] = 'W'.code.toByte()
            header[9] = 'A'.code.toByte()
            header[10] = 'V'.code.toByte()
            header[11] = 'E'.code.toByte()
            // Subchunk1ID "fmt "
            header[12] = 'f'.code.toByte()
            header[13] = 'm'.code.toByte()
            header[14] = 't'.code.toByte()
            header[15] = ' '.code.toByte()
            // Subchunk1Size (16 for PCM)
            bb.putInt(16, 16)
            // AudioFormat (1 = PCM)
            bb.putShort(20, 1.toShort())
            // NumChannels
            bb.putShort(22, channels.toShort())
            // SampleRate
            bb.putInt(24, sampleRate)
            // ByteRate
            bb.putInt(28, byteRate)
            // BlockAlign
            bb.putShort(32, (channels * bitsPerSample / 8).toShort())
            // BitsPerSample
            bb.putShort(34, bitsPerSample.toShort())
            // Subchunk2ID "data"
            header[36] = 'd'.code.toByte()
            header[37] = 'a'.code.toByte()
            header[38] = 't'.code.toByte()
            header[39] = 'a'.code.toByte()
            // Subchunk2Size
            bb.putInt(40, totalAudioLen.toInt())
            return header
        }
    }
}
