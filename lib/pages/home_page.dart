import 'package:flutter/material.dart';
import 'package:tetris_app/init.dart';
import 'package:tetris_app/pages/helper.dart';
import '../routes/routes.dart';

final usernameInput = TextEditingController();
bool showIndicator = true;
bool showScore = true;

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    InitApp.initializeApp(context);
  }

  void toggleSwitchForIndicator(bool value) {
    if (showIndicator == false) {
      setState(() {
        showIndicator = true;
      });
    } else {
      setState(() {
        showIndicator = false;
      });
    }
  }

  void toggleSwitchForScore(bool value) {
    if (showScore == false) {
      setState(() {
        showScore = true;
      });
    } else {
      setState(() {
        showScore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: const [
          Image(
            image: AssetImage("assets/images/icon.jpg"),
            width: 100,
            height: 50,
          ),
          Text("TETRIS"),
        ]),
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Image(image: AssetImage("assets/images/img.png")),
                ),
                const SizedBox(height: 50),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Transform.scale(
                      scale: 2,
                      child: Switch(
                        onChanged: toggleSwitchForIndicator,
                        value: showIndicator,
                        inactiveTrackColor: Colors.white,
                      )),
                  const SizedBox(
                    width: 127,
                  ),
                  const Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      'اظهار المؤشر',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ]),
                const SizedBox(
                  height: 5,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Transform.scale(
                      scale: 2,
                      child: Switch(
                        onChanged: toggleSwitchForScore,
                        value: showScore,
                        inactiveTrackColor: Colors.white,
                      )),
                  const SizedBox(
                    width: 125,
                  ),
                  const Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      'اظهار النتيجة',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ]),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: 300,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextField(
                      decoration: const InputDecoration(
                        iconColor: Colors.white,
                        labelText: 'ادخل اسم المستخدم',
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      controller: usernameInput,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (usernameInput.text == "") {
                      showSnackBar(context, "من فضلك قم بادخال اسم المستخدم");
                    } else {
                      Navigator.of(context).pushNamed(RouteManager.gamePage);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Icon(
                        Icons.arrow_left,
                        size: 40,
                      ),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          'ابدأ',
                          style: TextStyle(fontSize: 40),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
