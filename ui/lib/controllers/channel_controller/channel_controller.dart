import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:ui/controllers/auth_controllers/auth_methods.dart';
import 'package:ui/models/Channel/Channel.dart';
import 'package:ui/models/Video/video.model.dart';
import 'package:ui/network/http_exception_handler.dart';
import 'package:ui/network/response_handler.dart';
import 'package:ui/network/uri.constants.dart';
import "package:http/http.dart" as http;

import '../../models/User/user.dart';

class ChannelController extends GetxController{

  AuthController authController=Get.find();


   Future<Channel?> getChannelDetails(String channelName,BuildContext context)async{
      try{
        final uri=Uri.http(main_uri,'/api/users/getChannelInfo/$channelName');
        final res=await http.post(uri);
        if(ResponseHandler.is_good_response(res, context)){
          Channel c= Channel.fromJson(jsonDecode(res.body)['data']);
          // log(c.toString());/
          return c;
        }
      }on Exception catch(e){
        HttpExceptionHandler.handle(e, context);
      }
      return null;
  }


  Future<List<Video>> getUserWatchistory(BuildContext context)async{
     try{
       var uri=Uri.http(main_uri,'/api/users/getWatchHistory');
       final User user=authController.user.value;
       final res=await http.get(uri,headers: {
         'Authorization':'Bearer ${user.refreshToken}'
       });

       if(ResponseHandler.is_good_response(res, context)){
         var data=jsonDecode(res.body)["data"];
         // log(data.toString());
         List<Video> ans=[];
         for(var e in data) {
           ans.add(Video.fromJson(e));
         }
         // log(ans.toString());
         return ans;
       }
       return [];
     }on Exception catch(e){
       HttpExceptionHandler.handle(e, context);
     }throw  Exception("Cant fetch watch history!");
}
}