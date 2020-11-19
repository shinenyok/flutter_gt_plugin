package com.cn.GtPlugin.flutter_gt_plugin

import android.content.Context
import android.util.Log
import com.cn.GtPlugin.flutter_gt_plugin.FlutterGtPlugin.MessageEvent
import com.igexin.sdk.GTIntentService
import com.igexin.sdk.PushManager
import com.igexin.sdk.message.GTCmdMessage
import com.igexin.sdk.message.GTNotificationMessage
import com.igexin.sdk.message.GTTransmitMessage
import org.greenrobot.eventbus.EventBus
import org.json.JSONException
import org.json.JSONObject


class MyIntentService : GTIntentService() {

    private var cnt = 0

    /**
     * 收到推送消息
     */
    override fun onReceiveMessageData(context: Context, message: GTTransmitMessage?) {

        handleNotification(context, message)
//        EventBus.getDefault().post(MessageEvent(1, msg))
    }

    override fun onNotificationMessageArrived(context: Context?, p1: GTNotificationMessage?) {
    }

    override fun onReceiveServicePid(context: Context?, p1: Int) {
    }

    override fun onNotificationMessageClicked(context: Context?, message: GTNotificationMessage?) {
        println("message" + message.toString())
    }

    override fun onReceiveCommandResult(context: Context?, p1: GTCmdMessage?) {
    }

    /**
     * 收到clientId
     */
    override fun onReceiveClientId(context: Context?, clientId: String?) {
        val params = HashMap<String, String?>()
        params["clientId"] = clientId
        EventBus.getDefault().post(MessageEvent(0, params))
    }

    override fun onReceiveOnlineState(context: Context?, p1: Boolean) {
    }


    private fun handleNotification(context: Context?, msg: GTTransmitMessage?) {
        val appId: String = msg!!.appid
        val taskId: String = msg!!.taskId
        val messageId: String = msg!!.messageId
        val payload: ByteArray = msg!!.payload
        val pkg: String = msg!!.pkgName
        val cid: String = msg!!.clientId
        val result = PushManager.getInstance().sendFeedbackMessage(context, taskId, messageId, 90001)
        Log.d(TAG, "call sendFeedbackMessage = " + if (result) "success" else "failed")

        val data = String(payload)
        val obj: JSONObject?
        try {
            obj = JSONObject(data)
            println("JSON==$obj")
            val defaultNotification = MyNotificationManager(context, obj, cnt++)
            defaultNotification.showNotification()
        } catch (e: JSONException) {
            e.printStackTrace()
        }
    }
}