library float_bubble;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class FloatBubble extends StatefulWidget {
  ///create child for float widget
  ///
  final Widget child;

  ///this method use for hide widget
  ///
  final bool show;
  final double? maxY;
  final double? minY;

  ///set init position widget
  ///
  final Alignment initialAlignment;

  FloatBubble({
    required this.child,
    this.show = true,
    this.initialAlignment = Alignment.bottomRight,
    this.maxY,
    this.minY,
  });

  @override
  FloatBubbleState createState() => FloatBubbleState();
}

class FloatBubbleState extends State<FloatBubble>
    with SingleTickerProviderStateMixin {
  late Animation<Alignment> animation;
  late AnimationController controller;
  Alignment dragBeginAlignment = Alignment.bottomRight;
  Alignment dragEndAlignment = Alignment.bottomRight;

  @override
  void initState() {
    dragBeginAlignment = widget.initialAlignment;
    dragEndAlignment = widget.initialAlignment;

    super.initState();
    controller = AnimationController(vsync: this);

    controller.addListener(() {
      setState(() {
        dragBeginAlignment = animation.value;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void runAnimation(Offset pixelsPerSecond, Size size) {
    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    animation = controller.drive(
      AlignmentTween(
        begin: dragBeginAlignment,
        end: dragEndAlignment,
      ),
    );

    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);
    controller.animateWith(simulation);
  }

  void onPanUpdate(DragUpdateDetails details) {
    final size = MediaQuery.of(context).size;
    final dx = details.localPosition.dx;
    final dy = details.localPosition.dy;
    final width = size.width;
    final height = size.height;

    final maxY = widget.maxY ?? (height - kBottomNavigationBarHeight * 2);
    final minY = widget.minY ?? kBottomNavigationBarHeight;

    print('postion dx : $dx');
    print('postion dy : $dy');
    print('----------------------');

    setState(() {
      if (dx > (width / 2) && dy > maxY) {
        dragEndAlignment = Alignment(1, 1);
        dragBeginAlignment += Alignment(
          (details.delta.dx / (width / 2)),
          details.delta.dy / (height / 2),
        );
      } else if (dx > (width / 2) && dy > minY && dy < maxY) {
        dragEndAlignment = Alignment(
            1, dragBeginAlignment.y + details.delta.dy / (height / 2));
        dragBeginAlignment += Alignment(
          (details.delta.dx / (width / 2)),
          details.delta.dy / (height / 2),
        );
      } else if (dx > (width / 2) && dy < minY) {
        dragEndAlignment = Alignment(1, -1);
        dragBeginAlignment += Alignment(
          (details.delta.dx / (width / 2)),
          details.delta.dy / (height / 2),
        );
      } else if (dx < (width / 2) && dy > maxY) {
        dragEndAlignment = Alignment(
            -1, 1-dragBeginAlignment.y + details.delta.dy / (height / 2));
        dragBeginAlignment += Alignment(
          (details.delta.dx / (width / 2)),
          details.delta.dy / (height / 2),
        );
      } else if (dx < (width / 2) && dy > minY && dy < maxY) {
        dragEndAlignment = Alignment(
          -1,
          dragBeginAlignment.y + details.delta.dy / (size.height / 2),
        );
        dragBeginAlignment += Alignment(
          (details.delta.dx / (size.width / 2)),
          (details.delta.dy / (size.height / 2)),
        );
      } else if (dx < (width / 2) && dy < minY) {
        dragEndAlignment = Alignment(-1, -1);
        dragBeginAlignment += Alignment(
          (details.delta.dx / (width / 2)),
          details.delta.dy / (height / 2),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onPanDown: (details) {
        controller.stop();
      },
      onPanUpdate: (details) {
        onPanUpdate(details);
      },
      onPanEnd: (details) {
        runAnimation(details.velocity.pixelsPerSecond, size);
      },
      child: Align(
          alignment: dragBeginAlignment,
          child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(child: child, scale: animation);
              },
              child: (() {
                if (widget.show) {
                  return widget.child;
                } else {
                  return SizedBox();
                }
              }()))),
    );
  }
}
