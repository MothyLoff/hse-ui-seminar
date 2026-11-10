package ru.hse.uiseminar

import android.os.Bundle
import android.view.Gravity
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        // Bootstrap placeholder; feature widgets will be supplied by their Dagger factories.
        val content = AppCompatTextView(this).apply {
            setText(R.string.app_name)
            gravity = Gravity.CENTER
        }
        ViewCompat.setOnApplyWindowInsetsListener(content) { view, insets ->
            val safeArea = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            view.setPadding(safeArea.left, safeArea.top, safeArea.right, safeArea.bottom)
            insets
        }
        setContentView(content)
        ViewCompat.requestApplyInsets(content)
    }
}
