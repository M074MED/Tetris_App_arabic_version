import 'package:flutter/material.dart';
import 'package:tetris_app/init.dart';
import 'package:tetris_app/pages/helper.dart';
import '../routes/routes.dart';

final usernameInput = TextEditingController();
bool showIndicator = true;

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

  void toggleSwitch(bool value) {
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
                  const Text(
                    'Show Indicator',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(
                    width: 100,
                  ),
                  Transform.scale(
                      scale: 2,
                      child: Switch(
                        onChanged: toggleSwitch,
                        value: showIndicator,
                        inactiveTrackColor: Colors.white,
                      )),
                ]),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: const InputDecoration(
                      iconColor: Colors.white,
                      labelText: 'Enter Username',
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (usernameInput.text == "") {
                      showSnackBar(context, "Please Enter a Username!");
                    } else {
                      Navigator.of(context).pushNamed(RouteManager.gamePage);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Text(
                        'Play',
                        style: TextStyle(fontSize: 40),
                      ),
                      Icon(
                        Icons.play_arrow,
                        size: 40,
                      )
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
