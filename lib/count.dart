// ignore_for_file: prefer_const_constructors

import 'package:animate_do/animate_do.dart';
import 'package:count_app/round.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CountdownPage extends StatefulWidget {
  const CountdownPage({Key? key}) : super(key: key);

  @override
  _CountdownPageState createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage>
    with TickerProviderStateMixin {
  late AnimationController controller;

  bool isPlaying = false;

  String get countText {
    Duration count = controller.duration! * controller.value;
    return controller.isDismissed
        ? '${controller.duration!.inHours}:${(controller.duration!.inMinutes % 60).toString().padLeft(2, '0')}:${(controller.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
        : '${count.inHours}:${(count.inMinutes % 60).toString().padLeft(2, '0')}:${(count.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  double progress = 1.0;

  get FlutterRingtonePlayer => null;

  void notify() {
    if (countText == '0:00:00') {
      FlutterRingtonePlayer.playNotification();
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );

    controller.addListener(() {
      notify();
      if (controller.isAnimating) {
        setState(() {
          progress = controller.value;
        });
      } else {
        setState(() {
          progress = 1.0;
          isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
                    colors: const [Colors.black, Colors.black26],
                    begin: Alignment.bottomCenter,
                    end: Alignment.center)
                .createShader(bounds),
            blendMode: BlendMode.darken,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/learn1.jpg"),
                      fit: BoxFit.cover)),
            ),
          ),
          clock(context),
        ],
      ),
    );
  }

  Column clock(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              FadeInDownBig(
                child: Container(
                  width: 300,
                  height: 300,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.red,
                    value: progress,
                    strokeWidth: 6,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (controller.isDismissed) {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SizedBox(
                        height: 300,
                        child: CupertinoTimerPicker(
                          initialTimerDuration: controller.duration!,
                          onTimerDurationChanged: (time) {
                            setState(() {
                              controller.duration = time;
                            });
                          },
                        ),
                      ),
                    );
                  }
                },
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) => Text(
                    countText,
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (controller.isAnimating) {
                    controller.stop();
                    setState(() {
                      isPlaying = false;
                    });
                  } else {
                    controller.reverse(
                        from: controller.value == 0 ? 1.0 : controller.value);
                    setState(() {
                      isPlaying = true;
                    });
                  }
                },
                child: RoundButton(
                  icon: isPlaying == true ? Icons.pause : Icons.play_arrow,
                ),
              ),
              GestureDetector(
                onTap: () {
                  controller.reset();
                  setState(() {
                    isPlaying = false;
                  });
                },
                child: const RoundButton(
                  icon: Icons.stop,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
