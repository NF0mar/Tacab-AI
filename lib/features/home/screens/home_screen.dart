import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tacab_ai/features/home/screens/BlogDetailScreen.dart';
import 'package:tacab_ai/features/home/screens/MarketDetailScreenInner.dart';
// import 'package:tacab_ai/features/home/screens/market_detail_screen.dart';
// import 'package:tacab_ai/features/home/screens/market_products.dart';
import 'weather_service.dart';
import 'package:tacab_ai/features/home/models/market_product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Map<String, dynamic>>? weatherFuture;
  String userLocation = "Banaadir, Somalia";
  String weatherDescription = "";
  List<MarketProduct> marketProducts = [];
  List<Map<String, dynamic>> recentBlogs = [];
  bool isLoadingBlogs = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      weatherFuture = WeatherService().fetchFullForecast(2.0469, 45.3182);
      _determinePosition();
      fetchMarketProducts();
      fetchRecentBlogs();
    });
    // weatherFuture = WeatherService().fetchFullForecast(2.0469, 45.3182);
    // _determinePosition();
    // fetchMarketProducts();
  }

  Future<void> fetchRecentBlogs() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('blogs')
        .orderBy('date', descending: true)
        .limit(2) // only last 2 blogs
        .get();

    setState(() {
      recentBlogs = snapshot.docs.map((doc) => doc.data()).toList();
      isLoadingBlogs = false;
    });
  }

  Future<void> fetchMarketProducts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('marketProducts').get();

    setState(() {
      marketProducts = snapshot.docs
          .map((doc) => MarketProduct.fromJson(doc.data()))
          .toList();
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        userLocation = "Location services are disabled.";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          userLocation = "Location permission denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        userLocation =
            "Location permissions are permanently denied. Please enable them in settings.";
      });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      final place = placemarks.first;

      setState(() {
        userLocation = "${place.locality ?? ''}, ${place.country ?? ''}".trim();
        weatherFuture = WeatherService()
            .fetchFullForecast(position.latitude, position.longitude);
      });
    } catch (e) {
      setState(() {
        userLocation = "Failed to get location: $e";
      });
    }
  }

  // Optional: map API descriptions to user-friendly phrases
  String friendlyWeather(String desc) {
    final lower = desc.toLowerCase();
    if (lower.contains('clear')) return "It's a sunny day";
    if (lower.contains('rain')) return "It's raining outside";
    if (lower.contains('cloud')) return "It's cloudy today";
    if (lower.contains('snow')) return "Snow is falling";
    if (lower.contains('storm')) return "Stormy weather";
    return desc[0].toUpperCase() + desc.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'Guest';
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF73964A),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Hello, $name",
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const Gap(4),
                    FutureBuilder<Map<String, dynamic>>(
                      future: weatherFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final description =
                              (snapshot.data!['weather'] as List)
                                  .first['description'] as String;
                          return Text(
                            friendlyWeather(description),
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white70),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Text(
                            "Unable to load weather",
                            style:
                                TextStyle(fontSize: 18, color: Colors.white70),
                          );
                        }
                        return const Text(
                          "Loading weather...",
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        );
                      },
                    ),
                    const Gap(10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.white),
                          const Gap(6),
                          Flexible(
                            child: Text(userLocation,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(16),
              FutureBuilder<Map<String, dynamic>>(
                future: weatherFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = snapshot.data!;
                  final temp = (data['main']['temp'] as num).toDouble();
                  final humidity = (data['main']['humidity'] as num).toDouble();
                  final wind = (data['wind']['speed'] as num).toDouble();
                  final rain = (data['rain']?['1h'] as num?)?.toDouble() ?? 0.0;

                  return weatherOverview(
                      temp, humidity, rain, wind, screenWidth);
                },
              ),
              const Gap(16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFB7D5A5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => Get.toNamed('/chat'),
                  child: Row(
                    children: const [
                      Icon(Icons.recommend),
                      Gap(10),
                      Expanded(
                          child: Text(
                              "Check our new AI recommended Platform Tacab AI")),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
              ),
              const Gap(20),
              _sectionHeader("Market Price",
                  onTap: () => Get.toNamed('/marketdetail')),
              const Gap(10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  children: marketProducts.map((product) {
                    return Container(
                      width: 160, // fixed width for each card
                      margin: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          Get.to(
                              () => MarketDetailScreenInner(product: product));
                        },
                        child: _marketCard(
                          product.title,
                          product.location,
                          product.imageUrl,
                          "\$${product.price}/${product.unit}",
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Gap(25),
              _sectionHeader("Recently Posted",
                  onTap: () => Get.toNamed('/blog')),
              const Gap(10),

              isLoadingBlogs
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      children: recentBlogs.map((blog) {
                        return GestureDetector(
                          onTap: () {
                            // Navigate to blog detail page and pass blog data
                            Get.to(() => BlogDetailScreen(blog: blog));
                          },
                          child: _postCard(
                            blog['title'] ?? '',
                            blog['date'] ?? '',
                            blog['imageUrl'] ?? '',
                          ),
                        );
                      }).toList(),
                    ),
              // _postCard("Why do green house is important in this decade",
              //     "21 Jan 2025", "assets/images/post1.jpeg"),
              // const Gap(10),
              // _postCard("The importance of farming and it's benefits",
              //     "21 Jan 2025", "assets/images/post2.jpeg"),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF73964A),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.toNamed('/home');
              break;
            case 1:
              Get.toNamed('/marketdetail');
              break;
            case 2:
              Get.toNamed('/blog');
              break;
            case 3:
              Get.toNamed('/chat');
              break;
            case 4:
              Get.toNamed('/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.show_chart), label: 'Market'),
          BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined), label: 'Blog'),
          BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome), label: 'Chat AI'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: onTap,
            child:
                const Text("View All", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Widget _marketCard(
      String title, String location, String image, String price) {
    return Container(
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
              image,
              height: 90,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 90);
              },
            ),
          ),
          const Gap(8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Gap(2),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(location,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const Gap(4),
          Text(price,
              style: const TextStyle(
                  color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _postCard(String title, String date, String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 80,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 80),
                  )
                : const Icon(Icons.broken_image, size: 80),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const Gap(4),
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _postCard(String title, String date, String image) {
  //   return GestureDetector(
  //     onTap: () => Get.toNamed('/post-detail'),
  //     child: Container(
  //       padding: const EdgeInsets.all(10),
  //       decoration: BoxDecoration(
  //           color: Colors.white, borderRadius: BorderRadius.circular(12)),
  //       child: Row(
  //         children: [
  //           ClipRRect(
  //               borderRadius: BorderRadius.circular(12),
  //               child: Image.asset(image,
  //                   height: 80, width: 100, fit: BoxFit.cover)),
  //           const Gap(12),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(date,
  //                     style: const TextStyle(color: Colors.grey, fontSize: 12)),
  //                 const Gap(4),
  //                 Text(title,
  //                     style: const TextStyle(fontWeight: FontWeight.bold)),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _weatherItem(String emoji, String value, String label,
      {Color? bgColor}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: bgColor ?? Colors.grey.shade200, shape: BoxShape.circle),
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget weatherOverview(double temp, double humidity, double rain, double wind,
      double screenWidth) {
    return Container(
      width: screenWidth,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.spaceAround,
        children: [
          _weatherItem('🌡️', '${temp.toStringAsFixed(0)}°F', 'Temperature',
              bgColor: Colors.green.shade200),
          _weatherItem('💧', '${humidity.toStringAsFixed(0)}%', 'Humidity',
              bgColor: Colors.blue.shade300),
          _weatherItem('🌧️', '${rain.toStringAsFixed(1)}mm', 'Rainfall',
              bgColor: Colors.purple.shade200),
          _weatherItem('💨', '${wind.toStringAsFixed(1)}m/s', 'Wind Speed',
              bgColor: Colors.orange.shade200),
        ],
      ),
    );
  }
}
