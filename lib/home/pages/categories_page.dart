import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocab_master/home/pages/categorywords_page.dart';
import 'package:vocab_master/providers/words_provider.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  final List<String> categories = const [
    "Daily English",
    "Pop Culture",
    "Sports",
    "Literature",
    "Philosophy",
    "Mythology",
    "Tech & Science",
    "Business",
    "Travel & Culture",
    "Fun & Challenge",
  ];

  final List<List<Color>> gradients = const [
    [Color(0xFF6EC6FF), Color(0xFFB3E5FC)],
    [Color(0xFFFFA726), Color(0xFFFFCC80)],
    [Color(0xFF66BB6A), Color(0xFFA5D6A7)],
    [Color(0xFFAB47BC), Color(0xFFCE93D8)],
    [Color(0xFFFF7043), Color(0xFFFFAB91)],
    [Color(0xFF26C6DA), Color(0xFF80DEEA)],
    [Color(0xFF42A5F5), Color(0xFF90CAF9)],
    [Color(0xFFFFCA28), Color(0xFFFFF59D)],
    [Color(0xFF8D6E63), Color(0xFFD7CCC8)],
    [Color(0xFFEC407A), Color(0xFFF48FB1)],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
        backgroundColor: Colors.lightBlue,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3 / 2,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return InkWell(
              onTap: () async {
                // Load category words from provider
                final provider =
                    Provider.of<WordsProvider>(context, listen: false);
                await provider.loadCategoryWords(category);

                // Navigate to category words page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryWordsPage(category: category),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradients[index % gradients.length],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    category,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black38,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
