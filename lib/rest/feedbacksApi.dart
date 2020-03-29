import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wimp/model/feedbackModel.dart';

class FeedbackApi {
  static Future<bool> postFeedback(Map<String, dynamic> map) async {
    int supermarketId;
    int productId;
    String feedback;
    map.forEach((k, v) {
      switch (k) {
        case "supermarket":
          supermarketId = v;
          break;
        case "product":
          productId = v;
          break;
        case "feedback":
          feedback = v;
          break;
        default:
          break;
      }
    });

    if (supermarketId == null || productId == null || feedback == null) {
      return false;
    }

    FeedbackModel feedbackModel = createFeedback(feedback);

    String body = jsonEncode(feedbackModel);
    String postUrl =
        "http://15.236.118.131:5000/feedback/";
    postUrl += "1/";
    postUrl += productId.toString() + "/" + supermarketId.toString();

    Map headers = new Map<String, String>();
    headers['Content-Type'] = 'application/json';

    final response = await http.post(
        postUrl,
        headers: headers,
        body: body);
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      return true;
    } else {
      // If that call was not successful, throw an error.
      return false;
    }
  }

  static createFeedback(String feedback) {
    String availability = "";
    switch (feedback) {
      case "Low availability":
        availability = "low_availability";
        break;
      case "No availability":
        availability = "no_availability";
        break;
      default:
        break;
    }
    return FeedbackModel(feedback_type: availability, feedback_comment: "");
  }

}
