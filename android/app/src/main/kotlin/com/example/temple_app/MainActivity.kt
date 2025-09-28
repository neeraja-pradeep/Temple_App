package com.example.temple_app // use your actual package

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import com.google.firebase.FirebaseApp

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Initialize Firebase
        FirebaseApp.initializeApp(this)
    }
}
