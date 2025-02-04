package com.example.demo_with_getx_and_100ms

import io.flutter.embedding.android.FlutterActivity
import live.hms.hmssdk_flutter.HmssdkFlutterPlugin
import android.app.Activity
import android.content.Intent
import live.hms.hmssdk_flutter.Constants


class MainActivity: FlutterActivity() {
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
super.onActivityResult(requestCode, resultCode, data)

    if (requestCode == Constants.SCREEN_SHARE_INTENT_REQUEST_CODE && resultCode == Activity.RESULT_OK){
        HmssdkFlutterPlugin.hmssdkFlutterPlugin?.requestScreenShare(data)
    }

}
}
