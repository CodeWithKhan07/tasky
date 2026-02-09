class TodoModel {
  int? id;
  String task;
  String timeline;
  bool isDone;
  String desc;

  TodoModel({
    this.id,
    required this.task,
    required this.timeline,
    required this.isDone,
    required this.desc,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'task': this.task,
      'timeline': this.timeline,
      'isDone': isDone ? 1 : 0,
      'desc': this.desc,
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as int,
      task: map['task'] as String,
      timeline: map['timeline'] as String,
      isDone: map['isDone'] == 1,
      desc: map['desc'] as String,
    );
  }
}
