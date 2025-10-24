package com.inexor.wealthnx.ai;


import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.util.Log;
import android.widget.Toast;

import com.inexor.wealthnx.ai.MainActivity;

import java.util.HashMap;
import java.util.Objects;

import io.flutter.plugin.common.EventChannel;

public class MyBroadcastReceiver extends BroadcastReceiver {
    private static final String TAG = "MyBroadcastReceiver";
    EventChannel.EventSink events;

    public MyBroadcastReceiver() {
    }

    public MyBroadcastReceiver(EventChannel.EventSink events) {
        this.events = events;
    }

    @Override
    public void onReceive(Context context, Intent intent) {

        if (events!=null&&Objects.equals(intent.getAction(), MainActivity.CUSTOM_INTENT_ACTION)) {
            HashMap<String, String> response = new HashMap<String, String>();
            String message = intent.getStringExtra("message");
            String type = intent.getStringExtra("type");
            response.put("type", type);
            response.put("message", message);
            events.success(response);
        }
    }
}
