import 'package:flutter/material.dart';
import '../routes/routes.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Image(image: AssetImage("assets/images/img.png")),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(RouteManager.gamePage);
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
    );
  }
}
