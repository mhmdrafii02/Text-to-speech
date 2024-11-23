import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart'; // Import translator

void main() {
  runApp(TextToSpeechApp());
}

class TextToSpeechApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: TextToSpeechScreen(),
    );
  }
}

class TextToSpeechScreen extends StatefulWidget {
  @override
  _TextToSpeechScreenState createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController textController = TextEditingController();
  String storyText = "";
  double volume = 0.5; // Tambahkan variabel volume
  String selectedLanguage = 'id-ID'; // Default ke bahasa Indonesia
  String translationDirection =
      'id-en'; // Default terjemahkan dari Indonesia ke Inggris
  bool isLoading = false; // Menambahkan indikator loading

  final String malinKundangStory =
      "Malin Kundang adalah seorang anak yang durhaka kepada ibunya. "
      "Dia pergi merantau dan menjadi kaya raya, tetapi saat kembali ke kampung halamannya, dia tidak "
      "mengakui ibunya. Sang ibu yang kecewa mengutuknya menjadi batu.";

  final translator = GoogleTranslator(); // Inisialisasi GoogleTranslator

  Future<void> _speak() async {
    if (textController.text.isNotEmpty) {
      await flutterTts
          .setLanguage(selectedLanguage); // Menentukan bahasa sesuai pilihan
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setPitch(1.0);
      await flutterTts.setVolume(volume); // Atur volume

      if (textController.text.toLowerCase() == "malin kundang") {
        setState(() {
          storyText = malinKundangStory;
        });
        await flutterTts.speak(malinKundangStory);
      } else {
        setState(() {
          storyText = textController.text;
        });
        await flutterTts.speak(textController.text);
      }
    }
  }

  Future<void> _stop() async {
    await flutterTts.stop();
  }

  // Fungsi untuk terjemahkan teks berdasarkan pilihan
  Future<void> _translateText() async {
    setState(() {
      isLoading = true; // Menandakan proses terjemahan sedang berlangsung
    });

    // Mengecek arah terjemahan
    String fromLang = translationDirection.split('-')[0];
    String toLang = translationDirection.split('-')[1];

    try {
      final translation = await translator.translate(textController.text,
          from: fromLang, to: toLang);
      setState(() {
        storyText = translation.text; // Menampilkan teks terjemahan
      });
      await flutterTts.speak(storyText); // Membaca teks terjemahan
    } catch (e) {
      setState(() {
        storyText =
            "Error during translation: $e"; // Menangani error terjemahan
      });
    }

    setState(() {
      isLoading = false; // Menandakan proses terjemahan selesai
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'IDX Text to Speech',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: 'Masukkan teks (contoh: Malin Kundang)',
                labelStyle: TextStyle(color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
                ),
              ),
              maxLines: 4,
              minLines: 2,
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Volume: ${volume.toStringAsFixed(1)}",
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                ),
                Slider(
                  value: volume,
                  onChanged: (newValue) {
                    setState(() {
                      volume = newValue;
                    });
                  },
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  label: "${(volume * 100).toInt()}%",
                  activeColor: Colors.deepPurple,
                  inactiveColor: Colors.deepPurple[100],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _speak,
                  icon: Icon(Icons.volume_up),
                  label: Text('Speak'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white, // Warna teks putih
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _stop,
                  icon: Icon(Icons.stop),
                  label: Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Tombol untuk terjemahkan dari Indonesia ke Inggris
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  translationDirection = 'id-en'; // Atur arah terjemahan
                });
                _translateText();
              },
              icon: Icon(Icons.language),
              label: Text('Translate to English'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.orangeAccent,
              ),
            ),
            const SizedBox(height: 10),
            // Tombol untuk terjemahkan dari Inggris ke Indonesia
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  translationDirection = 'en-id'; // Atur arah terjemahan
                });
                _translateText();
              },
              icon: Icon(Icons.language),
              label: Text('Translate to Indonesian'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.greenAccent,
              ),
            ),
            const SizedBox(height: 30),
            isLoading
                ? CircularProgressIndicator() // Indikator loading saat terjemahan sedang berlangsung
                : Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.deepPurple),
                    ),
                    child: Text(
                      storyText,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.justify,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
