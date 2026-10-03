package com.gymtimer.gym_interval_timer

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import android.media.MediaPlayer
import android.media.ToneGenerator
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread
import kotlin.math.PI
import kotlin.math.exp
import kotlin.math.sin

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.gymtimer/audio"
    private var toneGenerator: ToneGenerator? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        try {
            toneGenerator = ToneGenerator(AudioManager.STREAM_MUSIC, 85)
        } catch (e: Exception) {
            e.printStackTrace()
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            val scheme = call.argument<String>("scheme") ?: "titan_impact"

            when (call.method) {
                "playTone" -> {
                    val frequency = call.argument<Int>("frequency") ?: 800
                    val durationMs = call.argument<Int>("durationMs") ?: 200
                    playSynthesizedTone(frequency, durationMs)
                    result.success(true)
                }
                "playCountdown" -> {
                    playCountdownTone(scheme)
                    result.success(true)
                }
                "playWorkStart" -> {
                    playWorkStartTone(scheme)
                    result.success(true)
                }
                "playRestStart" -> {
                    playRestStartTone(scheme)
                    result.success(true)
                }
                "playWorkoutComplete" -> {
                    playVictoryFanfare(scheme)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Plays authentic audio from res/raw using MediaPlayer with optional custom duration and fade-out.
     * Safely handles concurrent playback and auto-releases resources on completion.
     */
    private fun playRawSound(resId: Int, durationMs: Long = 0L) {
        try {
            val mp = MediaPlayer.create(this, resId) ?: return
            if (durationMs > 0L) {
                mp.start()
                thread {
                    try {
                        val fadeDuration = 450L
                        val playTime = maxOf(durationMs - fadeDuration, 200L)
                        Thread.sleep(playTime)
                        // Smooth volume fade-out over 450ms
                        val steps = 10
                        val stepTime = fadeDuration / steps
                        for (i in steps downTo 0) {
                            val volume = i.toFloat() / steps
                            try { mp.setVolume(volume, volume) } catch (_: Exception) {}
                            Thread.sleep(stepTime)
                        }
                        try {
                            if (mp.isPlaying) mp.stop()
                            mp.release()
                        } catch (_: Exception) {}
                    } catch (_: Exception) {
                        try { mp.release() } catch (_: Exception) {}
                    }
                }
            } else {
                mp.setOnCompletionListener { player ->
                    try { player.release() } catch (_: Exception) {}
                }
                mp.start()
            }
        } catch (e: Exception) {
            Log.e("GymSound", "Error playing raw sound $resId", e)
        }
    }

    private fun playCountdownTone(scheme: String) {
        thread {
            try {
                when (scheme) {
                    // Authentic boxing gym clapper / woodblock warning tap
                    "boxing_bell" -> playRawSound(R.raw.boxing_clapper, 0L)
                    "arcade_retro" -> playAudioTone(988, 80, isSquare = true)
                    "zen_harmony" -> playAudioTone(528, 160, warmHarmonics = true)
                    "military_drill" -> playAudioTone(1400, 100)
                    else -> playAudioTone(880, 130, warmHarmonics = true) // titan_impact
                }
            } catch (e: Exception) {
                toneGenerator?.startTone(ToneGenerator.TONE_PROP_BEEP, 120)
            }
        }
    }

    private fun playWorkStartTone(scheme: String) {
        thread {
            try {
                when (scheme) {
                    "boxing_bell" -> {
                        // Work interval = CLOPOT DUBLU (Double bell: Ding! Ding! ~2s total)
                        playRawSound(R.raw.boxing_bell_single, 1200L)
                        Thread.sleep(340L)
                        playRawSound(R.raw.boxing_bell_single, 2100L)
                    }
                    "arcade_retro" -> {
                        // Rising 8-bit triad power-up
                        playAudioTone(523, 70, isSquare = true)
                        playAudioTone(659, 70, isSquare = true)
                        playAudioTone(1046, 180, isSquare = true)
                    }
                    "zen_harmony" -> {
                        // Authentic deep Tibetan Singing Bowl strike (meditative, grounded ~2.4s)
                        playRawSound(R.raw.zen_bowl_deep, 2400L)
                    }
                    "military_drill" -> {
                        // Double tactical whistle blast ("Move! Move!") ~2.0s total
                        playRawSound(R.raw.military_whistle, 900L)
                        Thread.sleep(220L)
                        playRawSound(R.raw.military_whistle, 1600L)
                    }
                    else -> {
                        // titan_impact: Modern smooth electronic chime (880Hz -> 1320Hz)
                        playAudioTone(880, 85, warmHarmonics = true)
                        Thread.sleep(25)
                        playAudioTone(1320, 260, warmHarmonics = true)
                    }
                }
            } catch (e: Exception) {
                toneGenerator?.startTone(ToneGenerator.TONE_CDMA_HIGH_L, 350)
            }
        }
    }

    private fun playRestStartTone(scheme: String) {
        thread {
            try {
                when (scheme) {
                    "boxing_bell" -> {
                        // Rest interval = CLOPOT SIMPLU (Single bell: Ding! ~2s with smooth fadeout)
                        playRawSound(R.raw.boxing_bell_single, 2100L)
                    }
                    "arcade_retro" -> {
                        // Descending 8-bit slide
                        playAudioTone(784, 70, isSquare = true)
                        playAudioTone(587, 70, isSquare = true)
                        playAudioTone(392, 180, isSquare = true)
                    }
                    "zen_harmony" -> {
                        // Authentic soft Tibetan Singing Bowl chime (peaceful recovery ~2.2s)
                        playRawSound(R.raw.zen_bowl_soft, 2200L)
                    }
                    "military_drill" -> {
                        // Single tactical command whistle blast ("Halt / Rest!") ~1.8s
                        playRawSound(R.raw.military_whistle, 1800L)
                    }
                    else -> {
                        // titan_impact: Warm descending chime (880Hz -> 587Hz)
                        playAudioTone(880, 85, warmHarmonics = true)
                        Thread.sleep(25)
                        playAudioTone(587, 240, warmHarmonics = true)
                    }
                }
            } catch (e: Exception) {
                toneGenerator?.startTone(ToneGenerator.TONE_PROP_PROMPT, 250)
            }
        }
    }

    private fun playVictoryFanfare(scheme: String) {
        thread {
            try {
                when (scheme) {
                    "boxing_bell" -> {
                        // Victory celebration = CLOPOT TRIPLU (3-strike flurry bell!)
                        playRawSound(R.raw.boxing_bell_single, 1000L)
                        Thread.sleep(300L)
                        playRawSound(R.raw.boxing_bell_single, 1000L)
                        Thread.sleep(300L)
                        playRawSound(R.raw.boxing_bell_single, 2200L)
                    }
                    "arcade_retro" -> {
                        // 8-bit victory level clear
                        val notes = intArrayOf(523, 659, 784, 1046)
                        val durations = intArrayOf(85, 85, 85, 280)
                        for (i in notes.indices) {
                            playAudioTone(notes[i], durations[i], isSquare = true)
                            Thread.sleep((durations[i] + 15).toLong())
                        }
                    }
                    "zen_harmony" -> {
                        // Deep resonant singing bowl peace celebration (~3.5s)
                        playRawSound(R.raw.zen_bowl_deep, 3500L)
                    }
                    "military_drill" -> {
                        // Authentic US military brass bugle call (First Call) ~3.8s
                        playRawSound(R.raw.military_bugle, 3800L)
                    }
                    else -> {
                        // titan_impact: C5, E5, G5, High C6
                        val notes = intArrayOf(523, 659, 784, 1046)
                        val durations = intArrayOf(110, 110, 110, 360)
                        for (i in notes.indices) {
                            playAudioTone(notes[i], durations[i], warmHarmonics = true)
                            Thread.sleep((durations[i] + 20).toLong())
                        }
                    }
                }
            } catch (e: Exception) {
                toneGenerator?.startTone(ToneGenerator.TONE_CDMA_ALERT_CALL_GUARD, 500)
            }
        }
    }

    private fun playSynthesizedTone(freq: Int, durationMs: Int) {
        thread {
            try {
                playAudioTone(freq, durationMs, warmHarmonics = true)
            } catch (e: Exception) {
                toneGenerator?.startTone(ToneGenerator.TONE_PROP_BEEP, durationMs)
            }
        }
    }

    /**
     * Synthesizes audio using AudioTrack with natural exponential decay,
     * smooth anti-click envelope, warm harmonic layering, and calibrated volume (16000)
     * to eliminate speaker distortion and harsh metallic resonance.
     */
    private fun playAudioTone(
        freq: Int,
        durationMs: Int,
        warmHarmonics: Boolean = false,
        isSquare: Boolean = false
    ) {
        val sampleRate = 44100
        val numSamples = (durationMs * sampleRate) / 1000
        if (numSamples <= 0) return

        val sample = ShortArray(numSamples)
        val angularFreq = 2.0 * PI * freq / sampleRate
        val rampSamples = minOf(sampleRate * 4 / 1000, numSamples / 6)

        for (i in 0 until numSamples) {
            val progress = i.toDouble() / numSamples
            // Exponential decay curve softens the sound and removes piercing sustain
            val decay = exp(-2.6 * progress)
            val attack = if (i < rampSamples) (i.toDouble() / rampSamples) else 1.0
            val env = attack * decay

            val wave = if (isSquare) {
                val s = sin(angularFreq * i)
                if (s >= 0) 1.0 else -1.0
            } else if (warmHarmonics) {
                // Add gentle second harmonic for warm acoustic presence
                (sin(angularFreq * i) + 0.3 * sin(2.0 * angularFreq * i)) / 1.3
            } else {
                sin(angularFreq * i)
            }

            // Calibrated amplitude: 16000 is ~ -6dBFS (prevents speaker clipping / metallic buzzing)
            val amp = 16000.0 * env * wave
            sample[i] = amp.toInt().toShort()
        }

        val track = AudioTrack.Builder()
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )
            .setAudioFormat(
                AudioFormat.Builder()
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .setSampleRate(sampleRate)
                    .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                    .build()
            )
            .setBufferSizeInBytes(numSamples * 2)
            .setTransferMode(AudioTrack.MODE_STATIC)
            .build()

        track.write(sample, 0, numSamples)
        track.play()
        Thread.sleep(durationMs.toLong() + 25)
        track.release()
    }

    override fun onDestroy() {
        toneGenerator?.release()
        toneGenerator = null
        super.onDestroy()
    }
}
