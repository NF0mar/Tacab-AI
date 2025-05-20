import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:tacab_ai/features/authentication/controllers/auth.dart';
import 'package:tacab_ai/features/authentication/controllers/app_data.dart';
import 'package:tacab_ai/features/home/screens/settingscreen.dart';
import 'package:tacab_ai/features/home/screens/ConfirmDialogs.dart';
import 'package:tacab_ai/features/home/screens/blogscreen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void logout() async {
      try {
        await authService.value.signOut();
        AppData.navbarCurrentIndexNotifier.value = 0;
        AppData.onboardingPageNotifier.value = true;
        Get.offNamed('/login');
      } on FirebaseAuthException catch (e) {
        Get.snackbar(
            "Logout Error", e.message ?? "An error occurred during logout.");
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          const Gap(10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF73964A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/profile.jpg'),
                ),
                const Gap(12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Nur Farah",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Text("Banaadir",
                        style: TextStyle(color: Colors.white70, fontSize: 14))
                  ],
                ),
                const Spacer(),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white24,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                )
              ],
            ),
          ),
          const Gap(30),
          _buildTile(
            icon: Icons.article_outlined,
            title: "Blog",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BlogScreen()),
              );
            },
          ),
          _buildTile(
            icon: Icons.settings,
            title: "Setting",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingScreen()),
              );
            },
          ),
          _buildTile(icon: Icons.info_outline, title: "About Us", onTap: () {}),
          _buildTile(
            icon: Icons.logout,
            title: "Logout",
            onTap: () async {
              bool confirmed = await ConfirmDialogs.showLogoutDialog(context);
              if (confirmed) {
                await authService.value.signOut();
                AppData.navbarCurrentIndexNotifier.value = 0;
                AppData.onboardingPageNotifier.value = true;
                logout();
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: const Color(0xFF73964A),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          // TODO: Handle navigation to other tabs
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.show_chart), label: 'Market'),
          BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome), label: 'Chat AI'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildTile(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black87),
          ),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
      ],
    );
  }
}
