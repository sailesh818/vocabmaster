import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WordsProvider extends ChangeNotifier {
  // All words (for Home / Daily Words)
  List<Map<String, dynamic>> words = [];

  // Favorites
  List<Map<String, dynamic>> favoriteWords = [];

  // Category-specific words
  Map<String, List<Map<String, dynamic>>> categoryWords = {};

  // Track loading state per category
  Map<String, bool> categoryLoading = {};

  // Map category names to their JSON filenames
  final Map<String, String> categoryFileMap = {
    "Daily English": "daily_english.json",
    "Pop Culture": "pop_culture.json",
    "Sports": "sports.json",
    "Literature": "literature.json",
    "Philosophy": "philosophy.json",
    "Mythology": "mythology.json",
    "Tech & Science": "tech_science.json",
    "Business": "business.json",
    "Travel & Culture": "travel_culture.json",
    "Fun & Challenge": "fun_challenge.json",
  };

  /// Load main words.json (for Home / Daily Word)
  Future<void> loadWords() async {
    try {
      final String response = await rootBundle.loadString('assets/words.json');
      final List data = json.decode(response);
      words = List<Map<String, dynamic>>.from(data);
      notifyListeners();
    } catch (e) {
      words = [];
      notifyListeners();
    }
  }

  /// Load words for a specific category from assets/<category_file>
  Future<void> loadCategoryWords(String category) async {
    if (categoryWords.containsKey(category)) return; // Already loaded
    categoryLoading[category] = true;
    notifyListeners();

    final String? fileName = categoryFileMap[category];
    if (fileName == null) {
      // No file mapped for this category
      categoryWords[category] = [];
      categoryLoading[category] = false;
      notifyListeners();
      return;
    }

    try {
      final String response =
          await rootBundle.loadString('assets/$fileName');
      final List data = json.decode(response);
      categoryWords[category] = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      categoryWords[category] = []; // If file not found or error
    } finally {
      categoryLoading[category] = false;
      notifyListeners();
    }
  }

  /// Get words by category (returns a copy to prevent external mutation)
  List<Map<String, dynamic>> getWordsByCategory(String category) {
    return List<Map<String, dynamic>>.from(categoryWords[category] ?? []);
  }

  /// Check if a category is loading
  bool isCategoryLoading(String category) {
    return categoryLoading[category] ?? false;
  }

  /// Favorites management
  void addFavorite(Map<String, dynamic> word) {
    if (!favoriteWords.any((w) => w["word"] == word["word"])) {
      favoriteWords.add(Map<String, dynamic>.from(word));
      notifyListeners();
    }
  }

  void removeFavorite(Map<String, dynamic> word) {
    favoriteWords.removeWhere((w) => w["word"] == word["word"]);
    notifyListeners();
  }
}
