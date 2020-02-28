import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:github_app/i10n/localization_intl.dart';
import 'package:simple_animations/simple_animations.dart';

class AnimBgRoute extends StatefulWidget {
  @override
  _AnimBgRouteState createState() {
    return new _AnimBgRouteState();
  }
}

class _AnimBgRouteState extends State<AnimBgRoute> {
  bool isWave = true;

  void changeAnim() {
    setState(() {
      isWave = !isWave;
    });
  }

  @override
  Widget build(BuildContext context) {
    GmLocalizations gm = GmLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(gm.animBg),
      ),
      body: isWave ? AnimatedWaveRoute() : ParticleRoute(),
      floatingActionButton: FloatingActionButton(
        onPressed: changeAnim,
        child: Icon(Icons.change_history),
      ),
    );
    ;
  }
}

// -------------------------- animation wave ---------------------------
class AnimatedWaveRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GmLocalizations gm = GmLocalizations.of(context);
    return Stack(
      children: <Widget>[
        Positioned.fill(child: AnimatedBackground()),
        onBottom(AnimatedWave(
          height: 180,
          speed: 1,
        )),
        onBottom(AnimatedWave(
          height: 120,
          speed: 0.8,
          offset: pi,
        )),
        onBottom(AnimatedWave(
          height: 220,
          speed: 1.2,
          offset: pi / 2,
        )),
        Positioned.fill(
            child: new Center(
          child: Text(
            gm.animBg,
            style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ))
      ],
    );
  }

  onBottom(Widget child) => Positioned.fill(
          child: Align(
        alignment: Alignment.bottomCenter,
        child: child,
      ));
}

class AnimatedWave extends StatelessWidget {
  final double height;
  final double speed;
  final double offset;

  AnimatedWave({this.height, this.speed, this.offset = 0.0});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: height,
          width: constraints.biggest.width,
          child: ControlledAnimation(
            playback: Playback.LOOP,
            duration: Duration(microseconds: (5000000 / speed).round()),
            tween: Tween(begin: 0, end: 2 * pi),
            builder: (context, value) {
              return CustomPaint(
                foregroundPainter: CurvePainter(value + offset),
              );
            },
          ),
        );
      },
    );
  }
}

class CurvePainter extends CustomPainter {
  final double value;

  CurvePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white.withAlpha(60);
    final path = Path();

    final y1 = sin(value);
    final y2 = sin(value + pi / 2);
    final y3 = sin(value + pi);

    final startPointY = size.height * (0.5 + 0.4 * y1);
    final controlPointY = size.height * (0.5 + 0.4 * y2);
    final endPointY = size.height * (0.5 + 0.4 * y3);

    path.moveTo(size.width * 0, startPointY);
    path.quadraticBezierTo(
        size.width * 0.5, controlPointY, size.width, endPointY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("color1").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xffD38312), end: Colors.lightBlue.shade900)),
      Track("color2").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xffA83279), end: Colors.blue.shade600))
    ]);

    return ControlledAnimation(
      playback: Playback.MIRROR,
      tween: tween,
      duration: tween.duration,
      builder: (context, animation) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [animation["color1"], animation["color2"]])),
        );
      },
    );
  }
}

// -------------------------- animation particle ---------------------------
class ParticleRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Positioned.fill(child: AnimatedBackground2()),
      Positioned.fill(child: ParticlesWidget(30)),
      Positioned.fill(
        child: new Center(
          child: new Text(
            "Particle Animation",
            style: new TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    ]);
  }
}

class AnimatedBackground2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("color1").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xffD38312), end: Colors.lightBlue.shade900)),
      Track("color2").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xffA83279), end: Colors.blue.shade600))
    ]);

    return ControlledAnimation(
      playback: Playback.MIRROR,
      tween: tween,
      duration: tween.duration,
      builder: (context, animation) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [animation["color1"], animation["color2"]])),
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  List<ParticleModel> particles;
  Duration time;

  ParticlePainter(this.particles, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(50);
    particles.forEach((particle) {
      var progress = particle.animationProgress.progress(time);
      final animation = particle.tween.transform(progress);
      final position =
          Offset(animation["x"] * size.width, animation["y"] * size.height);
      canvas.drawCircle(position, size.width * 0.2 * particle.size, paint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ParticleModel {
  Animatable tween;
  double size;
  AnimationProgress animationProgress;
  Random random;
  int defaultMilliseconds;

  ParticleModel(this.random, {this.defaultMilliseconds = 500}) {
    restart();
  }

  restart({Duration time = Duration.zero}) {
    final startPosition = Offset(-0.2 + 1.4 * random.nextDouble(), 1.2);

    final endPosition = Offset(-0.2 + 1.4 * random.nextDouble(), -0.2);

    final duration =
        Duration(milliseconds: defaultMilliseconds + random.nextInt(1000));

    tween = MultiTrackTween([
      Track("x").add(
          duration, Tween(begin: startPosition.dx, end: endPosition.dx),
          curve: Curves.easeInOutSine),
      Track("y").add(
          duration, Tween(begin: startPosition.dy, end: endPosition.dy),
          curve: Curves.easeIn),
    ]);
    animationProgress = AnimationProgress(duration: duration, startTime: time);
    size = 0.2 + random.nextDouble() * 0.4;
  }

  maintainRestart(Duration time) {
    if (animationProgress.progress(time) == 1.0) {
      restart(time: time);
    }
  }
}

class ParticlesWidget extends StatefulWidget {
  final int numberOfParticles;

  ParticlesWidget(this.numberOfParticles);

  @override
  _ParticlesWidgetState createState() => _ParticlesWidgetState();
}

class _ParticlesWidgetState extends State<ParticlesWidget> {
  final Random random = Random();

  final List<ParticleModel> particles = [];

  @override
  void initState() {
    List.generate(widget.numberOfParticles, (index) {
      particles.add(ParticleModel(random, defaultMilliseconds: 5000));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Rendering(
      startTime: Duration(seconds: 50),
      onTick: _simulateParticles,
      builder: (context, time) {
        _simulateParticles(time);
        return CustomPaint(
          painter: ParticlePainter(particles, time),
        );
      },
    );
  }

  _simulateParticles(Duration time) {
    particles.forEach((particle) => particle.maintainRestart(time));
  }
}
