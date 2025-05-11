import 'package:flutter/material.dart';

import 'images_names.dart';


AppBar get_app_bar(String title, bool isCenter) {
  return AppBar(
    title: Text(
      title,
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    centerTitle: true,
    clipBehavior: Clip.hardEdge,
    // backgroundColor: Colors.blue,
    // foregroundColor: Colors.white,
    toolbarOpacity: 1,

    actions: [
      Builder(builder: (context) {
        return IconButton(
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
            icon: CircleAvatar(
              maxRadius: 25,
              child: MyImages.user_image,
            ));
      }),
      SizedBox.fromSize(
        size: const Size.square(12),
      ),
    ],

  );
}
