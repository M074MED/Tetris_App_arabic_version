import 'package:backendless_sdk/backendless_sdk.dart';
// import 'package:backendless_todo_starter/services/todo_service.dart';
// import 'package:backendless_todo_starter/services/user_service.dart';
import 'package:flutter/cupertino.dart';

import 'routes/routes.dart';
// import 'package:provider/provider.dart';

class InitApp {
  static final String apiKeyAndroid = '20CE2D9E-0741-4C02-85D6-A8EE096E8443';
  static final String apiKeyiOS = '9014B01E-141B-478F-ABF6-25E01AD02CA1';
  static final String appID = '1B87CFC9-DC13-690E-FFA2-F557A5EF0E00';

  static void initializeApp(BuildContext context) async {
    String result = "OK";
    Backendless.setUrl('https://api.backendless.com');
    await Backendless.initApp(
            applicationId: appID,
            iosApiKey: apiKeyiOS,
            androidApiKey: apiKeyAndroid)
        .onError((error, stackTrace) {
      result = error.toString();
    });
    if (result == 'OK') {
      print(result);
    } else {
      print(result);
    }
  }
}
