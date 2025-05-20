import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final blogs = [
      {
        'title': 'The importance of farming, Benefits and Challenges',
        'date': '02 Feb 2025',
        'image': 'assets/images/farm1.jpg'
      },
      {
        'title': 'Challenges facing Somalia farmers to tackle Climate Issues.',
        'date': '02 Feb 2025',
        'image': 'assets/images/farm2.jpg'
      },
      {
        'title': 'Did you know? farming is easy now a Green House...',
        'date': '03 Feb 2025',
        'image': 'assets/images/farm3.jpg'
      },
      {
        'title': 'DIY, How to fertilize your soil in home without money..',
        'date': '05 Feb 2025',
        'image': 'assets/images/farm4.jpg'
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Blog"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              blogs[0]['image']!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const Gap(12),
          Text(
            blogs[0]['title']!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Gap(4),
          Text(blogs[0]['date']!, style: const TextStyle(color: Colors.grey)),
          const Gap(20),
          ...blogs.sublist(1).map((blog) => _blogItem(blog)),
        ],
      ),
    );
  }

  Widget _blogItem(Map<String, String> blog) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              blog['image']!,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blog['title']!,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(4),
                Text(blog['date']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
