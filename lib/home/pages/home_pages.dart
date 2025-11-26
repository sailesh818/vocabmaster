import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocab_master/providers/words_provider.dart';
import 'package:vocab_master/home/pages/test_json_page.dart'; // All Words
import 'package:vocab_master/home/pages/favorites_page.dart'; // Favorites
import 'package:vocab_master/home/pages/mini_quiz_page.dart'; // Mini Quiz
import 'package:vocab_master/home/pages/word_detail_page.dart'; // Word Detail

class HomePages extends StatefulWidget {
  const HomePages({super.key});

  @override
  State<HomePages> createState() => _HomePagesState();
}

class _HomePagesState extends State<HomePages> {
  int dailyWordIndex = 0;

  @override
  void initState() {
    super.initState();
    final wordsProvider = Provider.of<WordsProvider>(context, listen: false);

    // Safely pick a random word after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (wordsProvider.words.isNotEmpty) {
        setState(() {
          dailyWordIndex = Random().nextInt(wordsProvider.words.length);
        });
      }
    });
  }

  void showNextWord() {
    final wordsProvider = Provider.of<WordsProvider>(context, listen: false);
    if (wordsProvider.words.isEmpty) return;

    setState(() {
      dailyWordIndex = (dailyWordIndex + 1) % wordsProvider.words.length;
    });
  }

  void addToFavorites(Map<String, dynamic> word) {
    final wordsProvider = Provider.of<WordsProvider>(context, listen: false);
    wordsProvider.addFavorite(word);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Added to Favorites")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wordsProvider = Provider.of<WordsProvider>(context);

    if (wordsProvider.words.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final word = wordsProvider.words[dailyWordIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vocab Master"),
        backgroundColor: Colors.lightBlue,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MiniQuizPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesPage()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Daily Word Section
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.lightBlue.shade200, Colors.lightBlue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Word of the Day",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      word["word"],
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      word["meaning"],
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Example: ${word["example"]}",
                      style: const TextStyle(
                          fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 16),
                    // Flow buttons scrollable
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _gradientButton("Next Word", showNextWord,
                              Colors.blueAccent, Colors.lightBlueAccent),
                          const SizedBox(width: 12),
                          _gradientButton("Add to Favorites",
                              () => addToFavorites(word), Colors.pink, Colors.redAccent),
                          const SizedBox(width: 12),
                          _gradientButton(
                              "View Details",
                              () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            WordDetailPage(word: word)),
                                  ),
                              Colors.green,
                              Colors.lightGreenAccent),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _quickAction(
                  icon: Icons.list_alt,
                  label: "All Words",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TestJsonPage()),
                    );
                  },
                ),
                _quickAction(
                  icon: Icons.favorite,
                  label: "Favorites",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FavoritesPage()),
                    );
                  },
                ),
                _quickAction(
                  icon: Icons.quiz,
                  label: "Mini Quiz",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MiniQuizPage()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Streak / Progress
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.lightBlue.shade100, Colors.lightBlue.shade50],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Streak",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "3 days",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Points: 50",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Quick Action Widget
  Widget _quickAction(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.lightBlue.shade300,
            child: Icon(icon, size: 28, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Gradient Button for actions
  Widget _gradientButton(
      String text, VoidCallback onTap, Color startColor, Color endColor) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [startColor, endColor]),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
