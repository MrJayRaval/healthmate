import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showLogo;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showLogo = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLogo) ...[
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 12),
          ],
          Text(
            title,
            style: Theme.of(
              context,
            ).appBarTheme.titleTextStyle?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
