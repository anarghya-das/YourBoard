class Task {
  String title;
  String content;
  bool isComplete;

  Task(this.title, this.content, this.isComplete);

  String getTitle() {
    return this.title;
  }

  String getContent() {
    return this.content;
  }

  bool getStatus() {
    return isComplete;
  }
}
