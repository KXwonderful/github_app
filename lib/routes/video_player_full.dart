import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoFullRoute extends StatefulWidget {
  final VideoPlayerController _controller;

  VideoFullRoute(this._controller);

  @override
  _VideoFullRouteState createState() {
    return new _VideoFullRouteState();
  }
}

class _VideoFullRouteState extends State<VideoFullRoute> {
  bool isLand = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              Center(
                child: Hero(
                  tag: "player",
                  child: AspectRatio(
                    aspectRatio: widget._controller.value.aspectRatio,
                    child: VideoPlayer(widget._controller),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 25, right: 20),
                child: IconButton(
                    icon: const BackButtonIcon(),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(isLand
              ? Icons.screen_lock_landscape
              : Icons.screen_lock_portrait),
          onPressed: () {
            setState(() {
              if (isLand) {
                isLand = !isLand;
                AutoOrientation.portraitUpMode();
              } else {
                isLand = !isLand;
                AutoOrientation.landscapeLeftMode();
              }
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (isLand) {
      AutoOrientation.portraitUpMode();
    }
  }
}
