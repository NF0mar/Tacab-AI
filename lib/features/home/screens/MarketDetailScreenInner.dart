// import 'package:flutter/material.dart';
// import 'package:tacab_ai/features/home/models/market_product.dart';
// import 'package:gap/gap.dart';

// class MarketDetailScreenInner extends StatelessWidget {
//   final MarketProduct product;

//   const MarketDetailScreenInner({Key? key, required this.product})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(product.title),
//         backgroundColor: const Color(0xFF73964A),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.network(product.imageUrl,
//                     height: 200, width: double.infinity, fit: BoxFit.cover)),
//             const Gap(16),
//             Text("${product.title} - ${product.location}",
//                 style:
//                     const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//             const Gap(8),
//             Text("Price: \$${product.price}/${product.unit}",
//                 style: const TextStyle(fontSize: 16, color: Colors.green)),
//             const Gap(16),
//             const Text("Description:",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             const Gap(8),
//             const Text(
//               "Fresh organic product. Grown without harmful chemicals and delivered daily to ensure top quality.",
//               style: TextStyle(fontSize: 14, color: Colors.black87),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tacab_ai/features/home/models/market_product.dart';

class MarketDetailScreenInner extends StatelessWidget {
  final MarketProduct product;

  const MarketDetailScreenInner({Key? key, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        backgroundColor: const Color(0xFF73964A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, size: 200);
                },
              ),
            ),
            const Gap(16),
            Text("${product.title} - ${product.location}",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Gap(8),
            Text("Price: \$${product.price}/${product.unit}",
                style: const TextStyle(fontSize: 16, color: Colors.green)),
            const Gap(16),
            const Text("Description:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Gap(8),
            const Text(
              "Fresh organic product. Grown without harmful chemicals and delivered daily to ensure top quality.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
