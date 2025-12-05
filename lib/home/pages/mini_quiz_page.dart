import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocab_master/providers/words_provider.dart';

class MiniQuizPage extends StatefulWidget {
  final bool isBusinessQuiz;
  final String? category;
  const MiniQuizPage({super.key, this.isBusinessQuiz = false, this.category});

  @override
  State<MiniQuizPage> createState() => _MiniQuizPageState();
}

class _MiniQuizPageState extends State<MiniQuizPage> {
  List<Map<String, dynamic>> quizWords = [];
  int currentIndex = 0;
  int score = 0;
  bool answered = false;
  String selectedOption = '';

  @override
  void initState() {
    super.initState();
    final wordsProvider = Provider.of<WordsProvider>(context, listen: false);
    List<Map<String, dynamic>> allWords;

    if (widget.category != null) {
      allWords = wordsProvider.getWordsByCategory(widget.category!);
    } else {
      allWords = List<Map<String, dynamic>>.from(wordsProvider.words);
    }

    allWords.shuffle();
    quizWords = allWords.take(5).toList(); // 5-word quiz
  }

  void checkAnswer(String selected) {
    if (answered) return;
    setState(() {
      answered = true;
      selectedOption = selected;
      if (selected == quizWords[currentIndex]["word"]) score++;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (currentIndex < quizWords.length - 1) {
        setState(() {
          currentIndex++;
          answered = false;
          selectedOption = '';
        });
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text("Quiz Completed!"),
            content: Text(
              "Your score: $score/${quizWords.length}\nGreat job! 🎉",
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (quizWords.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.lightBlue)),
      );
    }

    final currentWord = quizWords[currentIndex];

    List<String> options = [currentWord["word"]];
    final allWords = Provider.of<WordsProvider>(context, listen: false).words;
    final random = Random();
    while (options.length < 4) {
      final option = allWords[random.nextInt(allWords.length)]["word"];
      if (!options.contains(option)) options.add(option);
    }
    options.shuffle();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mini Quiz"),
        backgroundColor: Colors.lightBlue,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress Bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (currentIndex + 1) / quizWords.length,
                      minHeight: 10,
                      backgroundColor: Colors.lightBlue.shade100,
                      color: Colors.lightBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "${((currentIndex + 1) / quizWords.length * 100).toInt()}%",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Question Card
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.lightBlue.shade50,
              shadowColor: Colors.blue.shade100,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Question ${currentIndex + 1}/${quizWords.length}",
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Meaning:",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentWord["meaning"],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Options
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  Color btnColor = Colors.lightBlue.shade200;

                  if (answered) {
                    if (option == currentWord["word"]) {
                      btnColor = Colors.green.shade400;
                    } else if (option == selectedOption) {
                      btnColor = Colors.red.shade400;
                    } else {
                      btnColor = Colors.grey.shade300;
                    }
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        textStyle: const TextStyle(fontSize: 18),
                        elevation: 4,
                      ),
                      onPressed: () => checkAnswer(option),
                      child: Text(option),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Score Display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade100,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    "Score: $score",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
