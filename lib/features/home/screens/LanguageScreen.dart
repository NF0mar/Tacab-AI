import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final List<String> languages = ['English', 'Somali'];
  String? selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selected_language') ?? 'English';
    });
  }

  Future<void> _selectLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', lang);
    setState(() {
      selectedLanguage = lang;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Language"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: languages.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, thickness: 0.4),
        itemBuilder: (context, index) {
          final lang = languages[index];
          return ListTile(
            title: Text(lang, style: const TextStyle(fontSize: 16)),
            trailing: lang == selectedLanguage
                ? const Icon(Icons.check_circle, color: Color(0xFF73964A))
                : null,
            onTap: () => _selectLanguage(lang),
          );
        },
      ),
    );
  }
}
