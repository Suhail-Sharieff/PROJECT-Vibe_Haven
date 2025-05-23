class Video {
  String? id;
  String? videoFile;
  String? thumbNail;
  String? title;
  String? description;
  double? duration;
  int? views;
  bool? isPublished;
  Owner? owner;
  List<String>? hashtags;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Video(
      {this.id,
        this.videoFile,
        this.thumbNail,
        this.title,
        this.description,
        this.duration,
        this.views,
        this.isPublished,
        this.owner,
        this.hashtags,
        this.createdAt,
        this.updatedAt,
        this.iV});

  Video.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    videoFile = json['videoFile'];
    thumbNail = json['thumbNail'];
    title = json['title'];
    description = json['description'];
    duration = json['duration'];
    views = json['views'];
    isPublished = json['isPublished'];
    owner = json['owner'] != null ? new Owner.fromJson(json['owner']) : null;
    hashtags = json['hashtags'].cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['videoFile'] = this.videoFile;
    data['thumbNail'] = this.thumbNail;
    data['title'] = this.title;
    data['description'] = this.description;
    data['duration'] = this.duration;
    data['views'] = this.views;
    data['isPublished'] = this.isPublished;
    if (this.owner != null) {
      data['owner'] = this.owner!.toJson();
    }
    data['hashtags'] = this.hashtags;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Owner {
  String? sId;
  String? fullName;
  String? avatar;

  Owner({this.sId, this.fullName, this.avatar});

  Owner.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['fullName'] = this.fullName;
    data['avatar'] = this.avatar;
    return data;
  }
}
