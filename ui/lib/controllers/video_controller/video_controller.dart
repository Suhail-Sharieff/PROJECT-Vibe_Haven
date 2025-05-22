import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:ui/controllers/auth_controllers/auth_methods.dart';
import 'package:ui/network/http_exception_handler.dart';
import 'package:ui/network/uri.constants.dart';

import '../../models/User/user.dart';

class VideoController extends GetxController {
  Future<bool> publishVideo(BuildContext context,
  File? videoFile,File? thumbNail,List<String>hashTags,String title,String description
      ) async {
    try{
      final uri=Uri.http(main_uri,'/api/videoService/createVideo');
      final request = http.MultipartRequest('POST', uri);
      if(videoFile!=null && thumbNail!=null){
        request.files.add(
          await http.MultipartFile.fromPath(
            'videoFile',
            videoFile.path,
            contentType: MediaType('video', 'mp4'),
          )
        );
        request.files.add(
            await http.MultipartFile.fromPath(
              'thumbNail',
              thumbNail.path,
              contentType: MediaType('image', 'jpeg'),
            )
        );

        request.fields['title'] = title;
        request.fields['description'] = description;
        request.fields['hashtags'] = hashTags.join(',');
        final AuthController controller=Get.find();
        final String refToken=controller.user.value.refreshToken!;
        request.headers['Authorization'] = 'Bearer $refToken';

        final response = await request.send().timeout(
            const Duration(seconds: 40));

        if (response.statusCode == 200) {
          log('Video uploaded suceessfully');
          return true;
        } else {
          HttpExceptionHandler.handle(Exception("Upload failed!"), context);
        }

        // log(hashTags.toString());

      }
    }on Exception catch(e){
      HttpExceptionHandler.handle(e, context);
    }
    return false;
  }
}
