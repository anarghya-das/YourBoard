// * Template Task class to store the title, content, status, id and userId realted to a particular task.
class Task {
  int id;
  String userId, title, content;
  bool isComplete;

  Task(this.title, this.content, this.isComplete, this.id, this.userId);

  String getTitle() {
    return this.title;
  }

  String getContent() {
    return this.content;
  }

  bool getStatus() {
    return this.isComplete;
  }

  int getId() {
    return this.id;
  }

  String getUserId() {
    return this.userId;
  }
}
