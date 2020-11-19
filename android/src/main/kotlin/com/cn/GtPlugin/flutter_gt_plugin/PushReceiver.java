package com.cn.GtPlugin.flutter_gt_plugin;

import android.app.NotificationManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.alibaba.fastjson.JSONObject;

import org.greenrobot.eventbus.EventBus;

import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

import static android.content.Context.NOTIFICATION_SERVICE;

public class PushReceiver extends BroadcastReceiver {
    public static final String TYPE = "type";
    private String obj;
    private MethodChannel channel;


    @Override
    public void onReceive(Context context, Intent intent) {

        String action = intent.getAction();
        //点击
        if (action.equals("notification_clicked")) {
            //处理点击事件
            System.out.println("------- 点击了" + intent.getStringExtra("obj"));

            String title = intent.getStringExtra("title");
            String text = intent.getStringExtra("text");
            String url = intent.getStringExtra("url");
            String payload = intent.getStringExtra("payload");

            JSONObject jsonObject = JSONObject.parseObject(payload);
            //json对象转Map
            Map map;
            map = (Map) jsonObject;
            EventBus.getDefault().post(new FlutterGtPlugin.MessageEvent(2, map));

            obj = intent.getStringExtra("obj");//获取到了数据后续就做我们自己需要做的事情
            int a = intent.getIntExtra("a", -1);
            if (a != -1) {
                NotificationManager notificationManager = (NotificationManager) context.getSystemService(NOTIFICATION_SERVICE);
                System.out.println("点击了" + a);
                if (AppStateUtil.isBackground(context)) {
                    Intent msgIntent =
                            context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());//获取启动Activity
                    context.startActivity(msgIntent);
                }
                notificationManager.cancel(a);
            }
        }

        //删除，取消
        if (action.equals("notification_cancelled")) {
            //处理滑动清除和点击删除事件
            System.out.println("删除了");
        }
    }

}
