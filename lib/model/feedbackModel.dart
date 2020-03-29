class FeedbackModel {
  String feedback_type;
  String feedback_comment;

  FeedbackModel({
    this.feedback_type,
    this.feedback_comment,
  });

  FeedbackModel.fromJson(Map<String, dynamic> json)
      : feedback_type = json['feedback_type'],
        feedback_comment = json['feedback_comment'];

  Map<String, dynamic> toJson() => {
        'feedback_type': feedback_type,
        'feedback_comment': feedback_comment,
      };
}
