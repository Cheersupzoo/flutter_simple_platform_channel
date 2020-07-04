package com.example.flutter_simple_platform_channel

import androidx.annotation.NonNull
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import java.util.concurrent.TimeUnit


class MainActivity: FlutterActivity() {
    private val METHODCHANNEL = "sample.test.platform/text"
    private val EVENTCHANNEL = "sample.test.platform/number"
    private val TAG = "eventListener"

    private var timerSubscription: Disposable? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHODCHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "sendtext") {
                var text = call.argument<String>("message")
                var returnText = getStringReturnToDart(text as String)
                result.success(returnText)
                Log.d("sendtext","$returnText")
            } else {
                result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENTCHANNEL).setStreamHandler(
                object : EventChannel.StreamHandler {

                    override fun onListen(args: Any?, events: EventChannel.EventSink?) {
                        Log.w(TAG, "adding listener")
                        timerSubscription = Observable
                                .interval(0, 1, TimeUnit.SECONDS)
                                .observeOn(AndroidSchedulers.mainThread())
                                .subscribe(
                                        { timer: Long ->
                                            Log.w(TAG, "emitting timer event $timer")
                                            events?.success(timer)
                                        },
                                        { error: Throwable ->
                                            Log.e(TAG, "error in emitting timer", error)
                                            events?.error("STREAM", "Error in processing observable", error.message)
                                        },
                                        { Log.w(TAG, "closing the timer observable") }
                                )

                    }

                    override fun onCancel(args: Any?) {
                        Log.w(TAG, "cancelling listener")
                        if (timerSubscription != null) {
                            timerSubscription!!.dispose()
                            timerSubscription = null
                        }
                    }
                }
        )

    }


    private fun getStringReturnToDart(text: String): String {
        return text + " <- from Android"
    }
}
