import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:tacab_ai/features/authentication/controllers/auth.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final User? user = Auth().currentUser;
  // Widget _userid() {
  //   return Text(user?.email ?? 'user email');
  // }

  Future<Map<String, dynamic>>? weatherFuture;
  String userLocation = "Banaadir, Somalia";

  @override
  void initState() {
    super.initState();
    weatherFuture = WeatherService().fetchFullForecast(2.0469, 45.3182);
    _determinePosition();
  }

  // Future<void> _determinePosition() async {
  //   try {
  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) return;

  //     LocationPermission permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.denied) return;
  //     }
  //     if (permission == LocationPermission.deniedForever) return;

  //     final position = await Geolocator.getCurrentPosition();
  //     final placemarks =
  //         await placemarkFromCoordinates(position.latitude, position.longitude);
  //     final place = placemarks.first;

  //     setState(() {
  //       // Show only country or a full label as needed
  //       // userLocation = "${place.locality}, ${place.country}";
  //       // userLocation = "${place.administrativeArea}, ${place.country}";
  //       userLocation = place.country ?? "Unknown Country";
  //       weatherFuture = WeatherService()
  //           .fetchWeather(position.latitude, position.longitude);
  //     });
  //     // setState(() {
  //     //   userLocation = "${place.administrativeArea}, ${place.country}";
  //     //   weatherFuture = WeatherService()
  //     //       .fetchWeather(position.latitude, position.longitude);
  //     // });
  //   } catch (e) {
  //     print("Location error: $e");
  //     setState(() {
  //       userLocation = "Location unavailable";
  //     });
  //   }
  // }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        userLocation = "Location services are disabled.";
      });
      return;
    }

    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request permission
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
      // Get current position
      final position = await Geolocator.getCurrentPosition();

      // Convert lat/lon to human-readable address
      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      final place = placemarks.first;

      setState(() {
        // Customize location display as you like:
        userLocation = "${place.locality ?? ''}, ${place.country ?? ''}".trim();
      });
    } catch (e) {
      setState(() {
        userLocation = "Failed to get location: $e";
      });
    }
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
                    const Text("It’s a sunny day",
                        style: TextStyle(fontSize: 18, color: Colors.white70)),
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
                  onTap: () => Get.toNamed('/market-detail')),
              const Gap(10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                      width: (screenWidth - 48) / 2,
                      child: _marketCard("Basal", "Afgooye",
                          "assets/images/basal.jpg", "\$5.99/KG")),
                  SizedBox(
                      width: (screenWidth - 48) / 2,
                      child: _marketCard("Yaanyo", "Afgooye",
                          "assets/images/yaanyo.jpg", "\$5.99/KG")),
                ],
              ),
              const Gap(25),
              _sectionHeader("Recently Posted",
                  onTap: () => Get.toNamed('/posts')),
              const Gap(10),
              _postCard("Why do green house is important in this decade",
                  "21 Jan 2025", "assets/images/post1.jpeg"),
              const Gap(10),
              _postCard("The importance of farming and it's benefits",
                  "21 Jan 2025", "assets/images/post2.jpeg"),
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
              Get.toNamed('/market-detail');
              break;
            case 2:
              Get.toNamed('/chat');
              break;
            case 3:
              Get.toNamed('/profile');
              break;
          }
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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              image,
              height: 90,
              width: double.infinity,
              fit: BoxFit.cover,
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

  Widget _postCard(String title, String date, String image) {
    return GestureDetector(
      onTap: () => Get.toNamed('/post-detail'),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  Image.asset(image, height: 80, width: 100, fit: BoxFit.cover),
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
      ),
    );
  }

  Widget _weatherItem(String emoji, String value, String label,
      {Color? bgColor}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor ?? Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
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
