package com.box.project.recording_app;

import io.flutter.embedding.android.FlutterActivity;

import android.view.KeyEvent;

public class MainActivity extends FlutterActivity {
    private boolean isEnterKeyDown = false;

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        if (event.getKeyCode() == KeyEvent.KEYCODE_DPAD_CENTER) {
            if (event.getAction() == KeyEvent.ACTION_DOWN) {
                if (!isEnterKeyDown) {
                    // Generate the Enter down event
                    KeyEvent enterDownEvent = new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_ENTER);
                    isEnterKeyDown = true;
                    return super.dispatchKeyEvent(enterDownEvent);
                }
            } else if (event.getAction() == KeyEvent.ACTION_UP && isEnterKeyDown) {
                // Generate the Enter up event
                KeyEvent enterUpEvent = new KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_ENTER);
                isEnterKeyDown = false;
                return super.dispatchKeyEvent(enterUpEvent);
            }
        }
        return super.dispatchKeyEvent(event);
    }
}