class Channel {
  String? sId;
  String? email;
  String? avatar;
  String? coverImage;
  int? nSubscribers;
  int? nSubscribed;
  bool? haveISubscribedAlready;
  String? channelName;

  Channel(
      {this.sId,
        this.email,
        this.avatar,
        this.coverImage,
        this.nSubscribers,
        this.nSubscribed,
        this.haveISubscribedAlready,
        this.channelName});

  Channel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    avatar = json['avatar'];
    coverImage = json['coverImage'];
    nSubscribers = json['nSubscribers'];
    nSubscribed = json['nSubscribed'];
    haveISubscribedAlready = json['haveISubscribedAlready'];
    channelName = json['channelName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['email'] = this.email;
    data['avatar'] = this.avatar;
    data['coverImage'] = this.coverImage;
    data['nSubscribers'] = this.nSubscribers;
    data['nSubscribed'] = this.nSubscribed;
    data['haveISubscribedAlready'] = this.haveISubscribedAlready;
    data['channelName'] = this.channelName;
    return data;
  }
}
