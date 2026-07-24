package com.example.finanzas_ia

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Prevents balances and other financial data from appearing in
        // screenshots or the recents (task switcher) thumbnail.
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}
