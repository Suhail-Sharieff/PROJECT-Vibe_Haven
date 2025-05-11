import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ui/Utils/show_toast.dart';
import 'package:ui/models/User/user.dart';
import 'package:ui/network/http_exception_handler.dart';
import 'package:ui/network/response_handler.dart';
import 'package:ui/network/uri.constants.dart';

class AuthMethods {
  /// {"statusCode":200,"data":{"user":{"_id":"681b4849995d33c7b494580a","userName":"suhail","email":"suhailsharieffsharieff@gmail.com","fullName":"Suhail Beta","avatar":"http://res.cloudinary.com/diioxxov8/image/upload/v1746689778/j39fjsnrsg3knsvhuvjy.png","coverImage":"http://res.cloudinary.com/diioxxov8/image/upload/v1746618441/trdzp2sfy0oupddvaftn.jpg","watchHistory":[],"password":"$2b$10$CZaKeNYM5HVTjlJxds4wBOIsG.B4cn81tKuBWHal.cbRrG7g8y04y","createdAt":"2025-05-07T11:47:21.772Z","updatedAt":"2025-05-11T16:36:54.933Z","__v":0,"refreshToken":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2ODFiNDg0OTk5NWQzM2M3YjQ5NDU4MGEiLCJpYXQiOjE3NDY5ODE0MTQsImV4cCI6MTc0NzU4NjIxNH0.uiqzxlCqHxoqiiqZogGUJlESKJq_utM-_VxB6mF_v_Y"},"accessToken":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2ODFiNDg0OTk5NWQzM2M3YjQ5NDU4MGEiLCJlbWFpbCI6InN1aGFpbHNoYXJpZWZmc2hhcmllZmZAZ21haWwuY29tIiwiZnVsbE5hbWUiOiJTdWhhaWwgQmV0YSIsImlhdCI6MTc0Njk4MTg0MSwiZXhwIjoxNzQ3MDY4MjQxfQ.HjhhrLhHj97LPgLjO4y6YVY5mEM1N4GJ2Ung2d45aWk","refreshToken":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2ODFiNDg0OTk5NWQzM2M3YjQ5NDU4MGEiLCJpYXQiOjE3NDY5ODE4NDEsImV4cCI6MTc0NzU4NjY0MX0.LKHAlqNUFZ-etDSPQQIsTlZuyTdA-ugkyYl9DrAPJVc"},"message":"Login session created!","success":true}
  static Future<User?> loginWithEmailAndPassword(
    String? email,
    String? password,
    String? userName,
    BuildContext context,
  ) async {
    try {
      var url = Uri.http(main_uri, '/api/users/login');
      var res = await post(
        url,
        body: {"userName": userName, "password": password, "email": email},
      ).timeout(const Duration(seconds: 10));
      if (!ResponseHandler.is_good_response(res, context)) {
        return null;
      }
      var json = jsonDecode(res.body)['data']['user'];
      var user = User.fromJson(json);
      log('Logged in user: ${user.toString()}');
      return user;
    } on Exception catch (e) {
      HttpExceptionHandler.handle(e, context);
    }
    return null;
  }
}
