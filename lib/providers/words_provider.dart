import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WordsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> words = []; // all words (main + categories)
  List<Map<String, dynamic>> favoriteWords = [];

  // Dynamic category storage
  Map<String, List<Map<String, dynamic>>> categoryWords = {};
  Map<String, bool> categoryLoading = {};

  // Map categories → JSON files
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

  /// ---------------------------
  /// Load main words.json (Home)
  /// ---------------------------
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

  /// ----------------------------------------------------
  /// Load words of a specific category (like Business)
  /// ----------------------------------------------------
  Future<void> loadCategoryWords(String category) async {
    if (categoryWords.containsKey(category)) return; // already loaded

    categoryLoading[category] = true;
    notifyListeners();

    final String? fileName = categoryFileMap[category];
    if (fileName == null) {
      categoryWords[category] = [];
      categoryLoading[category] = false;
      notifyListeners();
      return;
    }

    try {
      final String response = await rootBundle.loadString('assets/$fileName');
      final List data = json.decode(response);
      categoryWords[category] = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      categoryWords[category] = [];
    } finally {
      categoryLoading[category] = false;
      notifyListeners();
    }
  }

  /// -------------------------------------------------------------
  /// Load main words first, then all category words in parallel
  /// -------------------------------------------------------------
  Future<void> loadAllWords({bool includeCategories = true}) async {
    await loadWords(); // load main words first
    if (!includeCategories) return;

    // Load all category words in parallel
    await Future.wait(
      categoryFileMap.keys.map((category) => loadCategoryWords(category)),
    );

    // Combine main + all categories for search / explore
    List<Map<String, dynamic>> allCategoryWords = [];
    for (var catList in categoryWords.values) {
      allCategoryWords.addAll(catList);
    }

    words = [...words, ...allCategoryWords];
    notifyListeners();
  }

  /// Get words by category name
  List<Map<String, dynamic>> getWordsByCategory(String category) {
    return List<Map<String, dynamic>>.from(categoryWords[category] ?? []);
  }

  /// Check if a category is loading
  bool isCategoryLoading(String category) {
    return categoryLoading[category] ?? false;
  }

  /// -------------------------
  /// Favorite Words Management
  /// -------------------------
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
