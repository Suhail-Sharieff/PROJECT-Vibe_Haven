import 'package:flutter/material.dart';
import 'package:ui/constants/routes.dart';

import '../../constants/appbar.dart';
class SubscriptionPage extends StatefulWidget {
  static const route_name=subscriptions_route;
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: get_app_bar('Subscriptions', true),
    );
  }
}
