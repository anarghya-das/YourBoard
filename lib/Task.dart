class Task {
  int id;
  String title;
  String content;
  bool isComplete;

  Task(this.title, this.content, this.isComplete, this.id);

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
}
