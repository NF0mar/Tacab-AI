// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     const headerHeight = 202.0;
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Stack(
//         children: [
//           // 1) two‐tone background
//           Positioned.fill(
//             child: Column(
//               children: [
//                 Container(height: headerHeight, color: Color(0xFF73964A)),
//                 Expanded(child: Container(color: Color(0xFFD9D9D9))),
//               ],
//             ),
//           ),

//           // 2) your header text
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Row(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start, // align everything at the top
//                 children: [
//                   // 1) The two‐line text on the left
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: const [
//                         Text(
//                           'Hello, Nur',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                         SizedBox(height: 3),
//                         Text(
//                           'It’s a sunny day',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 25,
//                             fontWeight: FontWeight.w200,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // 2) The location pill on the right
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: Colors.white24,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       // center the icon and text together
//                       children: const [
//                         Icon(Icons.location_on, size: 16, color: Colors.white),
//                         SizedBox(width: 4),
//                         Text(
//                           'Banaadir, Somalia',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 10,
//                             fontFamily: 'Roboto',
//                             fontWeight: FontWeight.w400,
//                             letterSpacing: -0.17,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // 3) the overlapping white card
//           Positioned(
//             top: headerHeight - 50, // overlap 20px
//             left: 16,
//             right: 16,
//             child: Container(
//               height: 176,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Center(child: Text('Weather card goes here')),
//             ),
//           ),

//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Color(0xFF7DBB3A),
//                   Color(0xFFB2E5A1)
//                 ], // Green gradient colors
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.shade300,
//                   blurRadius: 4,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       Icons
//                           .star, // Placeholder icon, replace with your custom icon
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                     const SizedBox(width: 10),
//                     Text(
//                       'Check our new AI recommended Platform Tacab AI',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Icon(
//                   Icons.arrow_forward_ios, // Right arrow icon
//                   color: Colors.white,
//                   size: 20,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const headerHeight = 202.0;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1) Two-tone background
          Positioned.fill(
            child: Column(
              children: [
                Container(height: headerHeight, color: Color(0xFF73964A)),
                Expanded(child: Container(color: Color(0xFFD9D9D9))),
              ],
            ),
          ),

          // 2) Header with Text
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1) Left text block
                  Expanded(
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
                        SizedBox(height: 3),
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
                  // 2) Location pill on the right
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(Icons.location_on, size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Banaadir, Somalia',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3) White card for Weather
          Positioned(
            top: headerHeight - 50, // Overlap by 50px
            left: 16,
            right: 16,
            child: Container(
              height: 176,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(child: Text('Weather card goes here')),
            ),
          ),

          // 4) Recommendation banner at the bottom
          Positioned(
            top: headerHeight + 150, // Position it below the weather card
            left: 16,
            right: 16,
            child: Container(
              width: 351,
              height: 79,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.00, 0.50),
                  end: Alignment(1.00, 0.50),
                  colors: [const Color(0xFFE5E5E5), const Color(0xFF73964A)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Check our new AI recommended Platform Tacab AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.17,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
