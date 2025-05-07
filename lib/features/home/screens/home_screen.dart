// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           // fit: StackFit.expand,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 color: Color(0xFFD9D9D9),
//               ),
//             ),
//             Container(
//               width: 393,
//               height: 202,
//               decoration: BoxDecoration(
//                 color: Color(0XFF73964A),
//               ),
//               child: Row(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Hello, Nur',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontFamily: 'Roboto',
//                             fontWeight: FontWeight.w400,
//                             letterSpacing: -0.17,
//                           ),
//                         ),
//                         Gap(3),
//                         Text(
//                           'It’s a sunny day',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 25,
//                             fontFamily: 'Roboto',
//                             fontWeight: FontWeight.w200,
//                             letterSpacing: -0.17,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Positioned(
//               top: 146,
//               left: 21,
//               child: Container(
//                 width: 351,
//                 height: 176,
//                 decoration: BoxDecoration(
//                   color: Color(0xFFFFFFFF),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ① set scaffold’s background to the grey
      backgroundColor: const Color(0xFFD9D9D9),
      body: Stack(
        children: [
          // ② Green header at the top
          Container(
            height: 202,
            width: double.infinity,
            color: const Color(0xFF73964A),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Hello, Nur',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Gap(3),
                Text(
                  'It’s a sunny day',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ],
            ),
          ),

          // ③ White card overlapping the green
          Positioned(
            top: 202 - 30, // overlap by 20px (the card’s top radius)
            left: 16,
            right: 16,
            child: Container(
              height: 176,
              decoration: BoxDecoration(
                color: Colors.white,
                // only round the top corners:
                borderRadius: BorderRadius.circular(20),
              ),
              // ✅ drop your weather‐card UI here later
              child: const Center(child: Text('Weather card goes here')),
            ),
          ),
        ],
      ),
    );
  }
}
