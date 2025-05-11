import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ui/Utils/show_toast.dart';

class HttpExceptionHandler{
  static void handle(Exception error, BuildContext context) {
    if (error is SocketException) {
      showErrorMsg("No Internet connection: $error", context);
    } else if (error is TimeoutException) {
      showErrorMsg("Server timed out: $error", context);
    } else {
      log("Unknown error: $error");
      showErrorMsg("Something went wrong: $error", context);
    }
    throw Exception(error.toString());
  }


}
