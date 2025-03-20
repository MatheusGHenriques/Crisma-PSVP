import 'package:flutter/material.dart';

class CustomPage extends Page {
  final Widget child;
  final int newIndex;
  final int oldIndex;

  const CustomPage({required this.child, required this.newIndex, required this.oldIndex, required LocalKey key})
    : super(key: key);

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: Duration(milliseconds: 100),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Offset begin = (newIndex > oldIndex) ? Offset(1.0, 0.0) : Offset(-1.0, 0.0);
        const Offset end = Offset.zero;
        const curve = Curves.fastEaseInToSlowEaseOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: FadeTransition(opacity: animation, child: child));
      },
    );
  }
}
