class NotificationModel {
  String title;
  String text;
  //1:不跳转 2:跳转原生 3:跳转H5
  num pushJumpType;
  String pushJumpUrl;
  String pushJumpParam;
  bool pushNeedCallback;
  String pushCallbackUrl;
  String pushCallbackParam;
  String pushJumpTitle;
  NotificationModel({this.title, this.text,this.pushJumpType, this.pushJumpUrl,  this.pushJumpParam, this.pushNeedCallback, this.pushCallbackUrl, this.pushCallbackParam,this.pushJumpTitle});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    text = json['text'];
    pushJumpUrl = json['pushJumpUrl'];
    pushJumpType = json['pushJumpType'];
    pushJumpParam = json['pushJumpParam'];
    pushCallbackUrl = json['pushCallbackUrl'];
    pushNeedCallback = json['pushNeedCallback'];
    pushCallbackParam = json['pushCallbackParam'];
    pushJumpTitle = json['pushJumpTitle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['text'] = this.text;
    data['pushJumpUrl'] = this.pushJumpUrl;
    data['pushJumpType'] = this.pushJumpType;
    data['pushJumpParam'] = this.pushJumpParam;
    data['pushCallbackUrl'] = this.pushCallbackUrl;
    data['pushNeedCallback'] = this.pushNeedCallback;
    data['pushCallbackParam'] = this.pushCallbackParam;
    data['pushJumpTitle'] = this.pushJumpTitle;
    return data;
  }
}