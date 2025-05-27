// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';

// class MarketDetailScreen extends StatelessWidget {
//   const MarketDetailScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF73964A),
//         title: const Text('Market Details'),
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       backgroundColor: const Color(0xFFF1F4F8),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.asset('assets/images/basal.jpeg', height: 200, width: double.infinity, fit: BoxFit.cover),
//             ),
//             const Gap(16),
//             const Text(
//               'Basal - Afgooye',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const Gap(8),
//             const Text(
//               'Price: \$5.99/KG',
//               style: TextStyle(fontSize: 16, color: Colors.green),
//             ),
//             const Gap(16),
//             const Text(
//               'Description:',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const Gap(8),
//             const Text(
//               'Fresh organic onions from Afgooye farms. Grown without harmful chemicals and delivered daily to ensure top quality.',
//               style: TextStyle(fontSize: 14, color: Colors.black87),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tacab_ai/features/home/models/market_product.dart';
import 'package:tacab_ai/features/home/screens/MarketDetailScreenInner.dart';

class MarketDetailScreen extends StatefulWidget {
  const MarketDetailScreen({Key? key}) : super(key: key);

  @override
  State<MarketDetailScreen> createState() => _MarketDetailScreenState();
}

class _MarketDetailScreenState extends State<MarketDetailScreen> {
  List<MarketProduct> marketProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMarketProducts();
  }

  Future<void> fetchMarketProducts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('marketProducts').get();

    setState(() {
      marketProducts = snapshot.docs
          .map((doc) => MarketProduct.fromJson(doc.data()))
          .toList();
      isLoading = false;
    });
  }

  Widget _marketCard(MarketProduct product) {
    return GestureDetector(
      onTap: () {
        Get.to(() => MarketDetailScreenInner(product: product));
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.imageUrl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )),
            const SizedBox(height: 8),
            Text(product.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(product.location,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text("\$${product.price}/${product.unit}",
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Market Products"),
        backgroundColor: const Color(0xFF73964A),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: marketProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 columns
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                return _marketCard(marketProducts[index]);
              },
            ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:tacab_ai/features/home/models/market_product.dart';
// import 'package:tacab_ai/features/home/screens/MarketDetailScreenInner.dart';
// import 'package:tacab_ai/features/home/screens/market_detail_screen.dart';
// import 'package:get/get.dart';

// class MarketDetailScreen extends StatefulWidget {
//   const MarketDetailScreen({Key? key}) : super(key: key);

//   @override
//   State<MarketDetailScreen> createState() => _MarketDetailScreenState();
// }

// class _MarketDetailScreenState extends State<MarketDetailScreen> {
//   List<MarketProduct> marketProducts = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchMarketProducts();
//   }

//   Future<void> fetchMarketProducts() async {
//     final snapshot =
//         await FirebaseFirestore.instance.collection('marketProducts').get();

//     setState(() {
//       marketProducts = snapshot.docs
//           .map((doc) => MarketProduct.fromJson(doc.data()))
//           .toList();
//       isLoading = false;
//     });
//   }

//   Widget _marketCard(MarketProduct product) {
//     return GestureDetector(
//       onTap: () {
//         Get.to(() => MarketDetailScreenInner(product: product));
//       },
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.grey.withOpacity(0.1),
//                 blurRadius: 6,
//                 offset: const Offset(0, 3))
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.network(
//                   product.imageUrl,
//                   height: 100,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 )),
//             const SizedBox(height: 8),
//             Text(product.title,
//                 style: const TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 4),
//             Text(product.location,
//                 style: const TextStyle(fontSize: 12, color: Colors.grey)),
//             const SizedBox(height: 4),
//             Text("\$${product.price}/${product.unit}",
//                 style: const TextStyle(
//                     color: Colors.green, fontWeight: FontWeight.bold)),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Market Products"),
//         backgroundColor: const Color(0xFF73964A),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : GridView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: marketProducts.length,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2, // 2 columns
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12,
//                 childAspectRatio: 0.75,
//               ),
//               itemBuilder: (context, index) {
//                 final product = marketProducts[index];
//                 return _marketCard(product);
//               },
//             ),
//     );
//   }
// }
