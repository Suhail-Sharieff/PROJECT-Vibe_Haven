
import 'package:flutter/material.dart';

import '../../constants/appbar.dart';
import '../../constants/end_drawer.dart';
import '../../constants/routes.dart';

class DiscoverPage extends StatefulWidget {
  static const String route_name=discover_route;
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: get_app_bar("Discover News !", true),
      endDrawer: get_end_drawer(context),
    );
  }
}
