import 'package:flutter/material.dart';
import 'package:quotesmaker/provider/drawer_provider.dart';

class MyMenuBar extends StatefulWidget {
  const MyMenuBar({Key? key}) : super(key: key);

  @override
  _MyMenuBarState createState() => _MyMenuBarState();
}

class _MyMenuBarState extends State<MyMenuBar> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final DrawerProvider _drawerProvider = Provider.of<DrawerProvider>(context);
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          items.length,
          (index) => _buildMenuItem(index, _drawerProvider),
        ),
      ),
    );
  }

  Widget _buildMenuItem(int index, DrawerProvider dp) {
    return Container(
      padding: const EdgeInsets.all(4.0),

      margin: const EdgeInsets.only(right: 5, left: 5),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: dp.selectedIndex == index ? Theme.of(context).primaryColor.withOpacity(.2) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              color: dp.selectedIndex == index ? Theme.of(context).primaryColor : null,
              icon: Icon(items[index].icon),
              onPressed: () {
                dp.changeIndex(index);
                // setState(() => selectedIndex = index);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class MenuItem {
  String title;
  IconData icon;
  Widget child;

  MenuItem(this.title, this.icon, this.child);
}

List<MenuItem> items = [
  MenuItem("Dashboard", Icons.dashboard, Container()),
  MenuItem("Explore", Icons.graphic_eq, Container()),
  MenuItem("Business", Icons.auto_stories, Container())
];
