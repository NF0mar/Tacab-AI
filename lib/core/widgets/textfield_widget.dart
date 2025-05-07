import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {super.key,
      required this.hintText,
      required this.icon,
      required this.isPassword,
      required this.controller});

  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 351,
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none, // when not focused
                focusedBorder: InputBorder.none,
                hintText: hintText,
              ),
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
        ],
      ),
    );
  }
}
