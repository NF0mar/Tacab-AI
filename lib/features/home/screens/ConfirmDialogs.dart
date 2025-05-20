import 'package:flutter/material.dart';

class ConfirmDialogs {
  static void showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Delete Account", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Are you sure, you want to delete account"),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton(
              onPressed: () {
                // TODO: Add delete logic
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF73964A)),
              child: const Text("Yes"),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF73964A)),
              ),
              child: const Text("No", style: TextStyle(color: Color(0xFF73964A))),
            ),
          ],
        );
      },
    );
  }

  // static void showLogoutDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext ctx) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //         title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
  //         content: const Text("Are you sure, you want to logout"),
  //         actionsAlignment: MainAxisAlignment.spaceEvenly,
  //         actions: [
  //           ElevatedButton(
  //             onPressed: () {
  //               // TODO: Add logout logic
  //               Navigator.pop(ctx);
  //             },
  //             style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF73964A)),
  //             child: const Text("Yes"),
  //           ),
  //           OutlinedButton(
  //             onPressed: () => Navigator.pop(ctx),
  //             style: OutlinedButton.styleFrom(
  //               side: const BorderSide(color: Color(0xFF73964A)),
  //             ),
  //             child: const Text("No", style: TextStyle(color: Color(0xFF73964A))),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }



  static Future<bool> showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Logout",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Are you sure you want to logout?"),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF73964A)),
              child: const Text("Yes"),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF73964A)),
              ),
              child:
                  const Text("No", style: TextStyle(color: Color(0xFF73964A))),
            ),
          ],
        );
      },
    );

    return result ??
        false; // default to false if user closes dialog without choosing
  }

}
