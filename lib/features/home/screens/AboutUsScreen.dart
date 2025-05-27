import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: const Color(0xFF73964A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About Tacab AI',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tacab AI is a Somali language-based AI platform designed to empower farmers and agropastoralists by providing them with accessible, accurate, and real-time agricultural information. Our mission is to bridge the technology gap and improve agricultural productivity and sustainability across Somalia.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Our Team',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _teamMember('Nur Farah Omar', 'Project Lead'),
            _teamMember('Siham Shuriye Hassan', 'Project Co-Lead'),
            _teamMember('Zakaria Hassan Abdi', 'Dataset and Model Engineer'),
            _teamMember('Ayub Abdinur Mohamed', 'Dataset voice Engineer'),
            _teamMember('Abdullahi Osman Ali', 'Frontend Developer'),
            const SizedBox(height: 24),
            const Text(
              'Contact Us',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Email: info@tacab.ai', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            const Text('Phone: +252 61 210 9656',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            const Text('Website: https://www.tacab.ai',
                style: TextStyle(fontSize: 16, color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  Widget _teamMember(String name, String role) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.person, size: 28, color: Color(0xFF73964A)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              Text(role,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}
