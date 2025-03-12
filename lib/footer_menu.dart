import 'package:flutter/material.dart';

class FooterMenu extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FooterMenu({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Trang chủ",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: "Bài học",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Cá nhân",
        ),
      ],
    );
  }
}
