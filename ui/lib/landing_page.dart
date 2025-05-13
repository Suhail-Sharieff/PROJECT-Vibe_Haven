

import 'package:flutter/material.dart';
import 'package:ui/pages/Discover_page/discover_page.dart';
import 'package:ui/pages/Home_page/home_page.dart';
import 'package:ui/pages/Leaderboard_page/leader_board.dart';

import 'constants/routes.dart';




class Landing_page extends StatefulWidget {
  static const String route_name=landing_route;
  const Landing_page({super.key});

  @override
  State<Landing_page> createState() => _Landing_pageState();
}

class _Landing_pageState extends State<Landing_page> {

  int currPageIdx=0;

  void onChange(int idx){
    setState(() {
      currPageIdx=idx;
    });
  }
  late final List<Widget>pages;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pages = [
      const HomePage(),
      const DiscoverPage(),
      const LeaderBoardPage()
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currPageIdx],
      bottomNavigationBar: get_nav_bar(currPageIdx, onChange),
    );
  }
}


NavigationBar get_nav_bar(int currentPageIndex,Function(int) onChange) {
  return NavigationBar(
    labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
    selectedIndex: currentPageIndex,
    onDestinationSelected: onChange,
    destinations: const <Widget>[
      NavigationDestination(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.newspaper),
        label: 'Discover',
      ),

      NavigationDestination(
        icon: Icon(Icons.leaderboard),
        label: 'Leaderboard',
      ),
    ],
  );
}


