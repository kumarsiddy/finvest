import 'package:finvest/presentation/shared/app_colors.dart';
import 'package:finvest/presentation/shared/widgets/app_bar.dart';
import 'package:finvest/presentation/shared/widgets/icon.dart';
import 'package:flutter/material.dart';

class CommonScaffold extends StatefulWidget {
  final Widget child;

  const CommonScaffold({
    super.key,
    required this.child,
  });

  @override
  State<CommonScaffold> createState() => _CommonScaffoldState();
}

class _CommonScaffoldState extends State<CommonScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Credit cards',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.child,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: BottomNavigationIcon(iconKey: 'assets/icons/home.svg'),
            activeIcon:
                BottomNavigationIcon(iconKey: 'assets/icons/home_filled.svg'),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: BottomNavigationIcon(iconKey: 'assets/icons/invest.svg'),
            activeIcon:
                BottomNavigationIcon(iconKey: 'assets/icons/invest_filled.svg'),
            label: 'INVEST',
          ),
          BottomNavigationBarItem(
            icon: BottomNavigationIcon(iconKey: 'assets/icons/discover.svg'),
            activeIcon: BottomNavigationIcon(
                iconKey: 'assets/icons/discover_filled.svg'),
            label: 'DISCOVER',
          ),
          BottomNavigationBarItem(
            icon: BottomNavigationIcon(iconKey: 'assets/icons/account.png'),
            activeIcon: BottomNavigationIcon(
                iconKey: 'assets/icons/account_filled.png'),
            label: 'ACCOUNT',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        onTap: _onItemTapped,
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        selectedIconTheme: IconThemeData(size: 30),
        unselectedIconTheme: IconThemeData(size: 30),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
