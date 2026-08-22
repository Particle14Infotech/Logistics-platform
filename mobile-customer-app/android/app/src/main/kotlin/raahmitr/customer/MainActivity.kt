package raahmitr.customer

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Native-level edge-to-edge opt-in, applied before the Flutter engine
        // attaches. main.dart's SystemChrome.setEnabledSystemUIMode call only
        // takes effect once Dart starts running and draws its first frame -
        // it doesn't cover the native launch window shown before that, which
        // is what Play Console's automated check was still catching despite
        // that fix already being in place.
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }
}
