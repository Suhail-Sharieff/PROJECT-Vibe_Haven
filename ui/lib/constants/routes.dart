
import 'package:flutter/material.dart';

import '../landing_page.dart';
import '../pages/Home_page/home_page.dart';
import '../pages/Leaderboard_page/leader_board.dart';
import '../pages/Profile_Page/edit_name.dart';
import '../pages/Profile_Page/edit_phone.dart';
import '../pages/Profile_Page/profile_page.dart';
import '../pages/auth_pages/forgot_password.dart';
import '../pages/auth_pages/login_page.dart';
import '../pages/auth_pages/sign_up.dart';
import '../pages/auth_pages/splash_screen.dart';
import '../pages/auth_pages/verfify_email.dart';

const splash_route='/splash/';
//---------auth pages

const login_route='/login/';
const signup_route='/signup/';
const verify_email_route='/verify_email/';
const forgot_password_route='forgot_password/';
//-------after login pages
const landing_route='/landing/';
const home_route='/home/';
const discover_route='/discover/';
const leader_board_route='/leader_board/';
const profile_route='/profile/';
const edit_user_name='/edit_user_name/';
const edit_user_ph_no='/edit_user_ph_no/';




final Map<String, WidgetBuilder> routes = {
  SplashScreen.route_name:(_)=>const SplashScreen(home_route: home_route,),
  Landing_page.route_name:(_)=>const Landing_page(),
  HomePage.route_name:(_)=>const HomePage(),
  LoginPage.route_name:(_)=>const LoginPage(),
  SignupPage.route_name:(_)=>const SignupPage(),
  VerifyEmailPage.route_name:(_)=>const VerifyEmailPage(),
  ForgotPassWordPage.route_name:(_)=>const ForgotPassWordPage(),
  LeaderBoardPage.route_name:(_)=>const LeaderBoardPage(),
  ProfilePage.route_name:(_)=>const ProfilePage(),
  EditNameFormPage.route_name:(_)=>const EditNameFormPage(),
  EditPhoneFormPage.route_name:(_)=>const EditPhoneFormPage(),
};