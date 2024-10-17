import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TranslationsScreen extends StatefulWidget {
  const TranslationsScreen({Key? key}) : super(key: key);

  @override
  State<TranslationsScreen> createState() => _TranslationsScreenState();
}

class _TranslationsScreenState extends State<TranslationsScreen> {
  String? _speakLanguage;
  String? _hearLanguage;
  bool _offlineMode = false;
  Set<String> _downloadedLanguages = {};

  final List<Map<String, dynamic>> languages = [
    {'name': 'Arabic', 'icon': '🇸🇦'},
    {'name': 'English', 'icon': '🇺🇸'},
    {'name': 'Hindi', 'icon': '🇮🇳'},
    {'name': 'Mandarin', 'icon': '🇨🇳'},
    {'name': 'Spanish', 'icon': '🇪🇸'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Select Language", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLanguageSelector("Language to Speak In", _speakLanguage, (value) => setState(() => _speakLanguage = value)),
            const SizedBox(height: 16),
            _buildLanguageSelector("Language to Hear In", _hearLanguage, (value) => setState(() => _hearLanguage = value)),
            const SizedBox(height: 16),
            _buildOfflineModeSwitch(),
            const SizedBox(height: 16),
            Text(
              "Speech to speech translation is also available in offline mode. Download languages to avail offline translation service.",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Languages Available",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                TextButton(
                  onPressed: _downloadAllLanguages,
                  child: const Text("Download all", style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListView.separated(
                  itemCount: languages.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final language = languages[index]['name'] as String;
                    final isDownloaded = _downloadedLanguages.contains(language);
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(languages[index]['icon'] as String, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      title: Text(language, style: const TextStyle(fontWeight: FontWeight.w500)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isDownloaded)
                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              isDownloaded ? Icons.delete : Icons.download,
                              color: isDownloaded ? Colors.red : Colors.blue,
                            ),
                            onPressed: () => _toggleLanguageDownload(language),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildLanguageSelector(String label, String? value, Function(String?) onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: const Text(
              "Choose",
              style: TextStyle(color: Colors.pink), // Change hint color to pink
            ),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
            onChanged: onChanged,
            items: languages.map<DropdownMenuItem<String>>((lang) {
              return DropdownMenuItem<String>(
                value: lang['name'] as String,
                child: Text(
                  lang['name'] as String,
                  style: TextStyle(color: value == lang['name'] ? Colors.pink : Colors.black), // Change selected item color to pink
                ),
              );
            }).toList(),
          ),
        ),
      ),
    ],
  );
}


  Widget _buildOfflineModeSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.offline_bolt, color: Colors.blue),
              SizedBox(width: 12),
              Text("Offline Mode", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
          CupertinoSwitch(
            value: _offlineMode,
            onChanged: (value) {
              setState(() {
                _offlineMode = value;
              });
            },
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  void _toggleLanguageDownload(String language) {
    setState(() {
      if (_downloadedLanguages.contains(language)) {
        _downloadedLanguages.remove(language);
      } else {
        _downloadedLanguages.add(language);
      }
    });
  }

  void _downloadAllLanguages() {
    setState(() {
      _downloadedLanguages = Set.from(languages.map((lang) => lang['name'] as String));
    });
  }
}