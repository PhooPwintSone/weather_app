import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ui/curve_ui/themes/theme_color.dart';
import 'package:ui/curve_ui/widgets/curved_header.dart';

class CurveLoginUi extends StatelessWidget {
  const CurveLoginUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // header
            const CurvedHeader(),

            //
            const SizedBox(height: 20),

            // Main title
            Text(
              "Hungry? Get it Fast",
              style: TextStyle(
                color: ThemeColor.bgColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            //
            const SizedBox(height: 15),

            // second title
            Text(
              'Zesty flavors, straight to your door',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),

            //
            const SizedBox(height: 15),

            //  textfield Column
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // email text field
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: ThemeColor.bgColor),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: ThemeColor.bgColor),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: ThemeColor.bgColor),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      prefixIcon: Icon(CupertinoIcons.mail),
                      prefixIconColor: ThemeColor.bgColor,
                      hintText: "email address",
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                  ),

                  //
                  const SizedBox(height: 20),

                  // password text field
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: ThemeColor.bgColor),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: ThemeColor.bgColor),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: ThemeColor.bgColor),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      prefixIcon: Icon(CupertinoIcons.lock),
                      prefixIconColor: ThemeColor.bgColor,
                      hintText: "passwords",
                      hintStyle: const TextStyle(color: Colors.grey),
                      suffixIcon: Icon(Icons.visibility_off),
                    ),
                  ),

                  //
                  const SizedBox(height: 20),
                  //
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          log("User clicked");
                        },
                        child: Text(
                          "Forgot Password ?",
                          style: TextStyle(color: ThemeColor.bgColor),
                        ),
                      ),
                    ],
                  ),
                  //
                  const SizedBox(height: 20),

                  //
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColor.bgColor,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),

                    child: const Text(
                      "Log In",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  //
                  const SizedBox(height: 20),

                  //
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account ?",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          log("Navigating to register page");
                        },
                        child: Text(
                          'Register here',
                          style: TextStyle(color: ThemeColor.bgColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
