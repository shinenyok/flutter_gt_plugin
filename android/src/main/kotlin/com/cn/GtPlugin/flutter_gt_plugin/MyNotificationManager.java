package com.cn.GtPlugin.flutter_gt_plugin;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Build;

import androidx.core.app.NotificationCompat;

import org.json.JSONException;
import org.json.JSONObject;

import static android.content.Context.NOTIFICATION_SERVICE;

class MyNotificationManager {


    public static final String CHANNEL_ID = "my_channel_01";
    public static final int NOTIFICATION_ID = 234;

    private Context context;
    private JSONObject jsonObject;
    private String title;
    private String content;
    private String text;
    private int messageId;//消息id
    private String type = "互动";
    private int a = 0;

    public MyNotificationManager(Context context, JSONObject jsonObject, int messageId) {
        this.context = context;
        this.jsonObject = jsonObject;
        this.messageId = messageId;
    }

    public void showNotification() throws JSONException {
        messageId++;
        if (jsonObject.has("title")) {
            title = jsonObject.getString("title");

        }
        if (jsonObject.has("content")) {
            content = jsonObject.getString("content");
        }
        if (jsonObject.has("text")) {
            text = jsonObject.getString("text");
        }

        //定义广播接收器
        //点击通知栏啊

        Intent intentClick = new Intent(context, PushReceiver.class);
        intentClick.setAction("notification_clicked");
        intentClick.putExtra(PushReceiver.TYPE, type);
//        intentClick.putExtra("obj", jsonObject.toString());
//        intentClick.putExtra("title", jsonObject.getString("title"));
//        intentClick.putExtra("text", jsonObject.getString("text"));
//        intentClick.putExtra("content", jsonObject.getString("content"));
        intentClick.putExtra("payload", jsonObject.toString());
        intentClick.putExtra("a", messageId);
        PendingIntent pendingIntentClick = PendingIntent.getBroadcast(context, messageId, intentClick, PendingIntent.FLAG_UPDATE_CURRENT);//flag应设置为FLAG_UPDATE_CURRENT否则只有一次点击事件
        //清除
        Intent intentCancel = new Intent(context, PushReceiver.class);
        intentCancel.setAction("notification_cancelled");
        intentCancel.putExtra(PushReceiver.TYPE, type);
        PendingIntent pendingIntentCancel = PendingIntent.getBroadcast(context, messageId, intentCancel, PendingIntent.FLAG_ONE_SHOT);

        NotificationCompat.Builder builder = new NotificationCompat.Builder(context);
        builder.setContentTitle(title);//设置标题
        builder.setContentText(text);//设置内容
        builder.setShowWhen(true);//设置显示时间
        builder.setOngoing(false);//是否可手动消除改通知
        builder.setAutoCancel(true);
        // 获取app_icon
        int logoId = context.getApplicationContext().getResources().getIdentifier("ic_launcher", "mipmap",
                context.getApplicationContext().getPackageName());
        builder.setSmallIcon(logoId);
        //需要VIBRATE权限
        builder.setDefaults(Notification.DEFAULT_VIBRATE);
        builder.setPriority(Notification.PRIORITY_DEFAULT);
        builder.setContentIntent(pendingIntentClick);
        builder.setDeleteIntent(pendingIntentCancel);
        android.app.NotificationManager notificationManager = (android.app.NotificationManager) context.getSystemService(NOTIFICATION_SERVICE);//通知管理器

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            String name = "my_channel";
            String description = "This is my channel";
            int importance = NotificationManager.IMPORTANCE_HIGH;
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, name, importance);
            channel.setDescription(description);
            channel.setLightColor(Color.WHITE);
            channel.setShowBadge(false);
            channel.setVibrationPattern(new long[0]);
            notificationManager.createNotificationChannel(channel);
            builder.setChannelId(CHANNEL_ID);
        }

        notificationManager.notify(messageId, builder.build());
    }
}
