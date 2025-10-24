package com.inexor.wealthnx.ai;

// import io.flutter.embedding.android.FlutterActivity;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.content.ContextCompat;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.Handler;
import android.util.Log;
import android.os.Bundle;

import org.java_websocket.client.WebSocketClient;
import org.java_websocket.handshake.ServerHandshake;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.HashMap;
import io.flutter.embedding.android.FlutterFragmentActivity;

public class MainActivity extends FlutterFragmentActivity {

    private static final String CHANNEL = "net.inexor.sockets/websocket_channel";
    private static final String EVENT_CHANNEL = "net.inexor.sockets/websocket_event";
    public static final String CUSTOM_INTENT_ACTION = "net.inexor.sockets.ACTION_CUSTOM_INTENT";

    private static final String TAG = "WebSocket - JAVA";
    private WebSocketClient mWebSocketClient;
    BroadcastReceiver myBroadCastReceiver;
    final Handler handler = new Handler();

    private static Context context;

    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        MainActivity.context = getApplicationContext();
    }

    public static Context getAppContext() {
        return MainActivity.context;
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            switch (call.method) {
                                case "connect":
                                    HashMap<String, String> data = call.arguments();
                                    assert data != null;
                                    connectWebSocket(data.get("url"), data.get("pingMessage"),
                                            data.get("isCustomPingMessage"), data.get("activatePing"), handler);
                                    result.success("requestSend");
                                    break;
                                case "isOpen":
                                    if (mWebSocketClient == null) {
                                        result.success(false);
                                        Log.d(TAG, "Socket is Null");
                                        return;
                                    }
                                    if (!mWebSocketClient.isOpen()) {
                                        result.success(false);
                                        return;
                                    }
                                    result.success(true);
                                    break;
                                case "message":
                                    String message = call.arguments();
                                    if (mWebSocketClient == null) {
                                        result.success(false);
                                        return;
                                    }
                                    if (!mWebSocketClient.isOpen()) {
                                        result.success(false);
                                        return;
                                    }
                                    mWebSocketClient.send(message);
                                    result.success(true);
                                    break;
                                case "disconnect":
                                    if (mWebSocketClient == null) {
                                        result.success(true);
                                        return;
                                    }
                                    if (!mWebSocketClient.isOpen()) {
                                        result.success(true);
                                        return;
                                    }
                                    mWebSocketClient.close();
                                    // This code causing app to crash
                                    // try {
                                    // mWebSocketClient.closeBlocking();
                                    // } catch (InterruptedException e) {
                                    // mWebSocketClient.close();
                                    // }
                                    if (myBroadCastReceiver != null) {
                                        unregisterReceiver(myBroadCastReceiver);
                                    }
                                    handler.removeCallbacksAndMessages(null);
                                    result.success(true);
                                    break;
                            }
                        });

        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EVENT_CHANNEL)
                .setStreamHandler(
                        new EventChannel.StreamHandler() {

                            @RequiresApi(api = Build.VERSION_CODES.TIRAMISU)
                            @Override
                            public void onListen(Object args, final EventChannel.EventSink events) {
                                Log.d(TAG, "OnListenStream");
                                IntentFilter filter = new IntentFilter(CUSTOM_INTENT_ACTION);
                                myBroadCastReceiver = new MyBroadcastReceiver(events);
                                registerReceiver(myBroadCastReceiver, filter, Context.RECEIVER_NOT_EXPORTED);
                            }

                            @Override
                            public void onCancel(Object args) {
                                Log.d(TAG, "OnCancelStream");
                                if (myBroadCastReceiver != null) {
                                    unregisterReceiver(myBroadCastReceiver);
                                }
                            }
                        });
    }

    private void connectWebSocket(String url, String pingMessage, String isCustomPingMessage, String activatePing,
            Handler handler) {

        final int delay = 30000;
        URI uri;
        try {
            uri = new URI(url);
        } catch (URISyntaxException e) {
            e.printStackTrace();
            return;
        }
        mWebSocketClient = new WebSocketClient(uri) {
            @Override
            public void onOpen(ServerHandshake serverHandshake) {
                Intent intent = new Intent(CUSTOM_INTENT_ACTION);
                intent.putExtra("message", "WebSocket Opened");
                intent.putExtra("type", "open");
                intent.setPackage(getAppContext().getPackageName());
                getAppContext().sendBroadcast(intent);
                // sendBroadcast(intent);
                if (activatePing.equals("true")) {
                    if (isCustomPingMessage.equals("true")) {
                        handler.postDelayed(new Runnable() {
                            public void run() {
                                // Log.d(TAG, "I am triggering Custom -- " + pingMessage + " -- Ping every " +
                                // delay + " mili seconds");
                                if (mWebSocketClient == null) {
                                    // Log.d(TAG, "HAHA 1");

                                    return;
                                }
                                if (!mWebSocketClient.isOpen()) {
                                    // Log.d(TAG, "HAHA 2");
                                    return;
                                }
                                mWebSocketClient.send(pingMessage);
                                handler.postDelayed(this, delay);
                            }
                        }, delay);
                    } else {
                        handler.postDelayed(new Runnable() {
                            public void run() {

                                // Log.d(TAG, "I am triggering Custom -- " + pingMessage + " -- Ping every " +
                                // delay + " mili seconds");
                                if (mWebSocketClient == null) {
                                    // Log.d(TAG, "HAHA 3");

                                    return;
                                }
                                if (!mWebSocketClient.isOpen()) {
                                    // Log.d(TAG, "HAHA 4");
                                    return;
                                }

                                mWebSocketClient.sendPing();
                                handler.postDelayed(this, delay);
                            }
                        }, delay);
                    }

                }

            }

            @Override
            public void onMessage(String message) {
                Intent intent = new Intent(CUSTOM_INTENT_ACTION);
                intent.putExtra("message", message);
                intent.putExtra("type", "onMessage");
                intent.setPackage(getAppContext().getPackageName());
                getAppContext().sendBroadcast(intent);
                // sendBroadcast(intent);
            }

            @Override
            public void onClose(int i, String s, boolean b) {
                Log.d(TAG, "Closed --- " + s);
            }

            @Override
            public void onError(Exception e) {
                Log.d(TAG, "Error " + e.getMessage());
            }
        };
        mWebSocketClient.setConnectionLostTimeout(0);
        try {
            mWebSocketClient.connect();
        } catch (Exception e) {
            Log.d("Connection Breaking", "Connection exception socket -- " + e.toString());
        }
    }

}
