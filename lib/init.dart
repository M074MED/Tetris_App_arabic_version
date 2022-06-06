import 'package:backendless_sdk/backendless_sdk.dart';
// import 'package:backendless_todo_starter/routes/routes.dart';
// import 'package:backendless_todo_starter/services/todo_service.dart';
// import 'package:backendless_todo_starter/services/user_service.dart';
import 'package:flutter/cupertino.dart';
// import 'package:provider/provider.dart';

class InitApp {
  static final String apiKeyAndroid = '20CE2D9E-0741-4C02-85D6-A8EE096E8443';
  static final String apiKeyiOS = '9014B01E-141B-478F-ABF6-25E01AD02CA1';
  static final String appID = '1B87CFC9-DC13-690E-FFA2-F557A5EF0E00';

  static void initializeApp(BuildContext context) async {
    await Backendless.initApp(
        applicationId: appID,
        iosApiKey: apiKeyiOS,
        androidApiKey: apiKeyAndroid);
    // String result = await context.read<UserService>().checkIfUserLoggedIn();
    // if (result == 'OK') {
    //   context
    //       .read<TodoService>()
    //       .getTodos(context.read<UserService>().currentUser!.email);
    //   Navigator.popAndPushNamed(context, RouteManager.todoPage);
    // } else {
    //   Navigator.popAndPushNamed(context, RouteManager.loginPage);
    // }
  }
}
