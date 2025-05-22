import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:ui/models/Channel/Channel.dart';
import 'package:ui/network/http_exception_handler.dart';
import 'package:ui/network/response_handler.dart';
import 'package:ui/network/uri.constants.dart';
import "package:http/http.dart" as http;

class ChannelController extends GetxController{
   Future<Channel?> getChannelDetails(String channelName,BuildContext context)async{
      try{
        final uri=Uri.http(main_uri,'/api/users/getChannelInfo/$channelName');
        final res=await http.post(uri);
        if(ResponseHandler.is_good_response(res, context)){
          Channel c= Channel.fromJson(jsonDecode(res.body)['data']);
          log(c.toString());
          return c;
        }
      }on Exception catch(e){
        HttpExceptionHandler.handle(e, context);
      }
      return null;
  }
}