import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'theme.dart';

String asset(String name) => 'assets/images/$name.png';

/// Forms keep their bottom action reachable on small screens and above keyboards.
class ScrollableColumn extends StatelessWidget {
  const ScrollableColumn({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(28),
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });
  final List<Widget> children;
  final EdgeInsets padding;
  final CrossAxisAlignment crossAxisAlignment;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) => SingleChildScrollView(
      padding: padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: (bounds.maxHeight - padding.vertical).clamp(
            0,
            double.infinity,
          ),
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            children: children,
          ),
        ),
      ),
    ),
  );
}

void go(BuildContext context, String route, {Object? arguments}) =>
    Navigator.of(context).pushNamed(route, arguments: arguments);
void home(BuildContext context) =>
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
void toast(BuildContext context, String text) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(text)));

class Avatar extends StatelessWidget {
  const Avatar(this.image, {super.key, this.size = 48, this.radius});
  final String image;
  final double size;
  final double? radius;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius ?? size / 2),
    child: Image.asset(
      asset(image),
      width: size,
      height: size,
      fit: BoxFit.cover,
    ),
  );
}

class PinkButton extends StatelessWidget {
  const PinkButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.white = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool white;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 56,
    child: FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: white ? Colors.white : AmiaColors.pink,
        foregroundColor: white ? AmiaColors.pink : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      onPressed: onPressed,
      child: Text(label),
    ),
  );
}

class FormFieldLine extends StatelessWidget {
  const FormFieldLine(
    this.label, {
    super.key,
    this.hint,
    this.controller,
    this.obscure = false,
    this.suffix,
    this.validator,
    this.keyboard,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscure, readOnly;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final TextInputType? keyboard;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      TextFormField(
        controller: controller,
        obscureText: obscure,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboard,
        validator: validator,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
      ),
    ],
  );
}

class SettingRow extends StatelessWidget {
  const SettingRow(
    this.title, {
    super.key,
    this.icon,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.height = 65,
  });
  final String title;
  final IconData? icon;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double height;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 23),
                const SizedBox(width: 20),
              ],
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AmiaColors.muted,
                        ),
                      ),
                  ],
                ),
              ),
              trailing ?? const Icon(CupertinoIcons.chevron_right, size: 18),
            ],
          ),
        ),
      ),
      const Divider(),
    ],
  );
}

class BottomTabs extends StatelessWidget {
  const BottomTabs(this.index, {super.key});
  final int index;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .035),
          blurRadius: 14,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 62,
        child: Row(
          children: List.generate(
            4,
            (i) => Expanded(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 50,
                      height: 3,
                      decoration: BoxDecoration(
                        color: i == index
                            ? AmiaColors.pink
                            : Colors.transparent,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      tooltip: [
                        'Calls',
                        'Channels',
                        'Notifications',
                        'Profile',
                      ][i],
                      icon: Icon(
                        [
                          CupertinoIcons.mic,
                          CupertinoIcons.chat_bubble_text,
                          CupertinoIcons.bell,
                          CupertinoIcons.person,
                        ][i],
                      ),
                      onPressed: () {
                        if (i != index) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            [
                              '/calls',
                              '/home',
                              '/notifications',
                              '/profile',
                            ][i],
                            (_) => false,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class SlantPainter extends CustomPainter {
  const SlantPainter({
    this.primary = AmiaColors.pink,
    this.secondary = AmiaColors.yellow,
  });
  final Color primary, secondary;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = secondary);
    canvas.drawPath(
      Path()
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height * .72)
        ..lineTo(size.width * .3, size.height * .84)
        ..lineTo(0, size.height * .77)
        ..close(),
      Paint()..color = primary,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * .77)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant SlantPainter old) =>
      primary != old.primary || secondary != old.secondary;
}

class ArtEmpty extends StatelessWidget {
  const ArtEmpty({
    super.key,
    required this.title,
    required this.message,
    this.image = 'notification_art',
  });
  final String title, message, image;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(asset(image), width: 160, height: 160),
      const SizedBox(height: 30),
      Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 42),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AmiaColors.muted,
            height: 1.8,
            fontSize: 12,
          ),
        ),
      ),
    ],
  );
}
