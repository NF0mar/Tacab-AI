import 'package:flutter/material.dart';
import 'package:tacab_ai/features/home/screens/languagescreen.dart';
import 'package:tacab_ai/features/home/screens/ConfirmDialogs.dart';



class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Setting"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        children: [

_buildTile(
  icon: Icons.language,
  title: "Language",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LanguageScreen()),
    );
  },
),
          _buildTile(icon: Icons.privacy_tip, title: "Privacy Policy", onTap: () {}),
          _buildTile(icon: Icons.star_border, title: "Rate us", onTap: () {}),
          _buildTile(icon: Icons.share, title: "Share App", onTap: () {}),
_buildTile(
  icon: Icons.delete_outline,
  title: "Delete Account",
  onTap: () {
    ConfirmDialogs.showDeleteAccountDialog(context);
  },
),
        ],
      ),
    );
  }

  Widget _buildTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Color(0xFF73964A)),
          title: Text(title, style: const TextStyle(fontSize: 16)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 0.4, indent: 16, endIndent: 16),
      ],
    );
  }
}
