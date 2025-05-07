import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tacab_ai/core/widgets/textfield_widget.dart';
import 'package:tacab_ai/core/widgets/custom_button.dart';
import 'package:tacab_ai/core/widgets/socialmedia_buttons.dart';
import 'package:get/get.dart';
import 'package:tacab_ai/routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
 
 LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFF1F4F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(21),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(50),
              Text(
                'TACAB AI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF73964A),
                  fontSize: 35,
                  fontFamily: 'JejuGothic',
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.17,
                ),
              ),
              Gap(42),
              Text(
                'Welcome Back!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 35,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.17,
                ),
              ),
              Gap(7),
              Text(
                'Please fillout the below form to login',
                // textAlign: TextAlign.left,
                style: TextStyle(
                  color: const Color(0xFF646464),
                  fontSize: 13,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w300,
                  height: 1.20,
                  letterSpacing: -0.17,
                ),
              ),
              Gap(20),
              CustomTextField(
                hintText: 'Enter your email or phone no',
                icon: Icons.email_outlined,
                isPassword: false,
                controller: emailController,
              ),
              Gap(20),
              CustomTextField(
                hintText: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
                controller: passwordController,
              ),
              Gap(30),
              CustomButton(
                text: 'Log In',
                backgroundColor: Color(0xFF73964A),
                textColor: Colors.white,
                onPressed: () => Get.offNamed(AppRoutes.HOME),
              ),
              Gap(20),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Color(0xFFEFEFEF),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: const Color(0xFF646464),
                        fontSize: 15,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w300,
                        height: 1.20,
                        letterSpacing: -0.17,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Color(0xFFEFEFEF),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomIconButton(
                    assetPath: 'assets/icons/facebook_ic.svg',
                    onPressed: () {/* ... */},
                  ),
                  CustomIconButton(
                    assetPath: 'assets/icons/google_ic.svg',
                    onPressed: () {/* ... */},
                  ),
                  // CustomIconButton(
                  //   assetPath: 'assets/icons/cib_apple.svg',
                  //   onPressed: () {/* ... */},
                  // ),
                ],
              ),
              Gap(14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don’t have an account?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF7F7F7E),
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w300,
                      letterSpacing: -0.30,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.offNamed('/signup'),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: const Color(0xFF73964A),
                      padding: EdgeInsets.only(left: 7),
                      textStyle: TextStyle(
                        color: const Color(0xFF73964A),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.30,
                      ),
                    ),
                    child: Text('Sign Up'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
