class ToDo {
  String body;
  String userId;
  bool done;

  ToDo(this.body, this.userId, this.done);

  ToDo.fromJson(Map<String, dynamic> map) {
    this.body = map['body'];
    this.userId = map['user_id'];
    this.done = map['done'];
  }

  Map<String, dynamic> toMAp() {
    return {
      'body': this.body,
      'user_id': this.userId,
      'done': this.done,
    };
  }
}
