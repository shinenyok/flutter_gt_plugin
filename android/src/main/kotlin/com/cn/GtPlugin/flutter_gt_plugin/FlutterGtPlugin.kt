package com.cn.GtPlugin.flutter_gt_plugin

import android.content.Context
import androidx.annotation.NonNull
import com.alibaba.fastjson.JSON
import com.alibaba.fastjson.JSONObject
import com.igexin.sdk.PushManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode


/** FlutterGtPlugin */
public class FlutterGtPlugin : FlutterPlugin, MethodCallHandler {
    lateinit var channel: MethodChannel

    lateinit var context: Context
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_gt_plugin")
        channel.setMethodCallHandler(this);
        EventBus.getDefault().register(this);
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val plugin = FlutterGtPlugin()
            plugin.context = registrar.context()
            plugin.channel = MethodChannel(registrar.messenger(), "flutter_gt_plugin")
            plugin.channel.setMethodCallHandler(plugin)

        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            Constant.METHOD_SET_UP -> setup()
            Constant.METHOD_APPLY_PUSH_AUTHORITY -> {
            }
            else -> {
            }
        }
    }

    private fun setup() {
        PushManager.getInstance().initialize(context, MyPushService::class.java)
        //注册第三方服务
        PushManager.getInstance().registerPushIntentService(context, MyIntentService::class.java)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        this.channel.setMethodCallHandler(null)
        EventBus.getDefault().unregister(this);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onMessageEvent(event: MessageEvent?) {
        when (event?.type) {
            0 -> {
                channel.invokeMethod(Constant.METHOD_RECEIVE_CLIENT_ID, event.data)
            }
            1 -> {
                channel.invokeMethod(Constant.METHOD_RECEIVE_MESSAGE, event.data)
            }
            2 -> {
                channel.invokeMethod(Constant.METHOD_ON_CLICK_MESSAGE, event.data)
            }
            else -> {

            }
        }
    }

    class MessageEvent(type: Int, data: Map<String, String?>) {
        val type: Int? = type
        val data: Map<String, String?> = data
    }
}
