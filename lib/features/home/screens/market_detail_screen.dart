import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class MarketDetailScreen extends StatelessWidget {
  const MarketDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF73964A),
        title: const Text('Market Details'),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF1F4F8),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/images/basal.jpeg', height: 200, width: double.infinity, fit: BoxFit.cover),
            ),
            const Gap(16),
            const Text(
              'Basal - Afgooye',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            const Text(
              'Price: \$5.99/KG',
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
            const Gap(16),
            const Text(
              'Description:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            const Text(
              'Fresh organic onions from Afgooye farms. Grown without harmful chemicals and delivered daily to ensure top quality.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
