import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? userid;

  @HiveField(2)
  String? title;

  @HiveField(3)
  String? content;

  @HiveField(4)
  DateTime? dateadded;

  Note({this.id, this.userid, this.title, this.content, this.dateadded});

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map["id"],
      userid: map["userid"],
      title: map["title"],
      content: map["content"],
      dateadded: DateTime.tryParse(map["dateadded"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "userid": userid,
      "title": title,
      "content": content,
      "dateadded": dateadded?.toIso8601String()
    };
  }
}
