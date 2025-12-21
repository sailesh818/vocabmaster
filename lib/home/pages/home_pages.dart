import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocab_master/providers/words_provider.dart';
import 'package:vocab_master/home/pages/test_json_page.dart';
import 'package:vocab_master/home/pages/favorites_page.dart';
import 'package:vocab_master/home/pages/mini_quiz_page.dart';
import 'package:vocab_master/home/pages/word_detail_page.dart';

class HomePages extends StatefulWidget {
  const HomePages({super.key});

  @override
  State<HomePages> createState() => _HomePagesState();
}

class _HomePagesState extends State<HomePages> {
  int dailyWordIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final wordsProvider = Provider.of<WordsProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await wordsProvider.loadAllWords();
      if (wordsProvider.words.isNotEmpty) {
        setState(() {
          dailyWordIndex = Random().nextInt(wordsProvider.words.length);
          isLoading = false;
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

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.lightBlue),
        ),
      );
    }

    final word = wordsProvider.words[dailyWordIndex];
    final categories = wordsProvider.categoryWords.keys.toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Vocab Master",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.lightBlueAccent,
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
            // ------------------------
            // Daily Word Card
            // ------------------------
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              shadowColor: Colors.blue.shade200,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.lightBlue.shade300, Colors.lightBlue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Word of the Day",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      word["word"],
                      style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      word["meaning"],
                      style: const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Example: ${word["example"]}",
                      style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _gradientButton(
                              "Next Word",
                              showNextWord,
                              Colors.blueAccent.shade400,
                              Colors.lightBlueAccent.shade100),
                          const SizedBox(width: 12),
                          _gradientButton(
                              "Add to Favorites",
                              () => addToFavorites(word),
                              Colors.pinkAccent.shade400,
                              Colors.redAccent.shade200),
                          const SizedBox(width: 12),
                          _gradientButton(
                              "View Details",
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => WordDetailPage(word: word))),
                              Colors.green.shade400,
                              Colors.lightGreenAccent.shade100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // ------------------------
            // Quick Actions Row
            // ------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _quickAction(
                  icon: Icons.list_alt,
                  label: "All Words",
                  color: Colors.blueAccent.shade400,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TestJsonPage()),
                    );
                  },
                ),
                _quickAction(
                  icon: Icons.favorite,
                  label: "Favorites",
                  color: Colors.pinkAccent.shade400,
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
                  color: Colors.greenAccent.shade400,
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

            // ------------------------
            // Category Quiz Cards
            // ------------------------
            Column(
              children: categories.map((category) {
                return _categoryQuizBox(category, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MiniQuizPage(
                        isBusinessQuiz: category == "Business",
                        category: category,
                      ),
                    ),
                  );
                });
              }).toList(),
            ),
            //const SizedBox(height: 30),

            // ------------------------
            // Streak / Progress Card
            // ------------------------
            // Card(
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   elevation: 6,
            //   child: Container(
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(20),
            //       gradient: LinearGradient(
            //           colors: [Colors.lightBlue.shade100, Colors.lightBlue.shade50]),
            //     ),
            //     padding: const EdgeInsets.all(20),
            //     // child: Row(
            //     //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //     //   children: const [
            //     //     // Column(
            //     //     //   children: [
            //     //     //     Text("Streak",
            //     //     //         style: TextStyle(
            //     //     //             fontSize: 16, fontWeight: FontWeight.bold)),
            //     //     //     SizedBox(height: 6),
            //     //     //     Text("3 days", style: TextStyle(fontSize: 16)),
            //     //     //   ],
            //     //     // ),
            //     //     // Column(
            //     //     //   children: [
            //     //     //     Text("Points",
            //     //     //         style: TextStyle(
            //     //     //             fontSize: 16, fontWeight: FontWeight.bold)),
            //     //     //     SizedBox(height: 6),
            //     //     //     Text("50", style: TextStyle(fontSize: 16)),
            //     //     //   ],
            //     //     // ),
            //     //   ],
            //     // ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // ------------------------
  // Quick Action Widget
  // ------------------------
  Widget _quickAction(
      {required IconData icon,
      required String label,
      required VoidCallback onTap,
      required Color color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(icon, size: 28, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  // ------------------------
  // Gradient Button Widget
  // ------------------------
  Widget _gradientButton(
      String text, VoidCallback onTap, Color startColor, Color endColor) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [startColor, endColor]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  // ------------------------
  // Category Quiz Box Widget
  // ------------------------
  Widget _categoryQuizBox(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.lightBlue.shade400, Colors.lightBlue.shade200],
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.quiz, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
