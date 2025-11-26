import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocab_master/providers/words_provider.dart';
import 'word_detail_page.dart';

class CategoryWordsPage extends StatefulWidget {
  final String category;

  const CategoryWordsPage({super.key, required this.category});

  @override
  State<CategoryWordsPage> createState() => _CategoryWordsPageState();
}

class _CategoryWordsPageState extends State<CategoryWordsPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryWords();
  }

  Future<void> _loadCategoryWords() async {
    final wordsProvider =
        Provider.of<WordsProvider>(context, listen: false);
    await wordsProvider.loadCategoryWords(widget.category);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wordsProvider = Provider.of<WordsProvider>(context);
    final words = wordsProvider.getWordsByCategory(widget.category);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Colors.lightBlue,
        elevation: 4,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.lightBlue),
              ),
            )
          : words.isEmpty
              ? const Center(
                  child: Text(
                    "No words found in this category",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      final word = words[index];
                      final List<String> synonyms = word["synonyms"] != null
                          ? List<String>.from(word["synonyms"])
                          : [];
                      final List<String> antonyms = word["antonyms"] != null
                          ? List<String>.from(word["antonyms"])
                          : [];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WordDetailPage(word: word),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.lightBlue.shade200,
                                Colors.lightBlue.shade50
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                word["word"],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                word["meaning"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              if (word["example"] != null &&
                                  word["example"].toString().isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    "Example: ${word["example"]}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              if (synonyms.isNotEmpty)
                                Text(
                                  "Synonyms: ${synonyms.join(', ')}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.green,
                                  ),
                                ),
                              if (antonyms.isNotEmpty)
                                Text(
                                  "Antonyms: ${antonyms.join(', ')}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.redAccent,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
