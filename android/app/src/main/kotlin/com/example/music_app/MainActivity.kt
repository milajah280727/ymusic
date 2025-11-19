package com.example.music_app // Pastikan nama package ini sesuai dengan proyek Anda

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.ryanheise.audioservice.AudioServiceActivity

// --- GANTI EXTENDS DARI FlutterActivity MENJADI AudioServiceActivity ---
class MainActivity : AudioServiceActivity() {
}