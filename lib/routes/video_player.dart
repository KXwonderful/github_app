import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:github_app/i10n/localization_intl.dart';
import 'package:github_app/routes/video_player_full.dart';
import 'package:video_player/video_player.dart';

class VideoRoute extends StatefulWidget {
  @override
  _VideoRouteState createState() {
    return new _VideoRouteState();
  }
}

class _VideoRouteState extends State<VideoRoute> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'https://res.exexm.com/cw_145225549855002')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    GmLocalizations gm = GmLocalizations.of(context);
    return MaterialApp(
      title: gm.video,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 200,
                margin: EdgeInsets.only(
                    top: MediaQueryData.fromWindow(
                            WidgetsBinding.instance.window)
                        .padding
                        .top),
                color: Colors.black,
                child: _controller.value.initialized
                    ? Hero(
                        tag: "player",
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      )
                    : Container(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      ),
              ),
            )
          ],
        ),
        persistentFooterButtons: <Widget>[
          Builder(
            builder: (context) {
              return FlatButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return VideoFullRoute(_controller);
                    }));
                  },
                  color: Colors.green,
                  child: new Text(
                    "Full",
                    style: TextStyle(color: Colors.white),
                  ));
            },
          ),
        ],
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
