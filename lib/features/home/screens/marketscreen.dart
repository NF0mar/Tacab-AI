// import 'package:flutter/material.dart';
// import '../models/market_product.dart';
// import 'market_detail_screen.dart';

// class MarketScreen extends StatelessWidget {
//   final List<MarketProduct> marketProducts;

//   const MarketScreen({super.key, required this.marketProducts});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Market'),
//         backgroundColor: const Color(0xFF73964A),
//       ),
//       body: GridView.builder(
//         padding: const EdgeInsets.all(12),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2, // two items per row
//           crossAxisSpacing: 12,
//           mainAxisSpacing: 12,
//           childAspectRatio: 0.75, // adjust based on your design
//         ),
//         itemCount: marketProducts.length,
//         itemBuilder: (context, index) {
//           final product = marketProducts[index];
//           return GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => MarketDetailScreen(product: product),
//                 ),
//               );
//             },
//             child: _marketCard(product),
//           );
//         },
//       ),
//     );
//   }

//   Widget _marketCard(MarketProduct product) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               blurRadius: 6,
//               offset: const Offset(0, 3))
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//             child: Image.asset(product.imagePath,
//                 height: 120, width: double.infinity, fit: BoxFit.cover),
//           ),
//           const SizedBox(height: 8),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             child: Text(product.title,
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             child: Text(product.price,
//                 style: const TextStyle(
//                     color: Colors.green, fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }
// }
