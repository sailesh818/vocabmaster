import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:vocab_master/home/pages/home_pages.dart';
import 'package:vocab_master/navigation_bar/pages/navigationbar.dart';
//import 'package:vocab_master/home/pages/test_json_page.dart';
import 'package:vocab_master/providers/words_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WordsProvider()..loadWords(), // Load JSON on start
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vocab Master',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Navigationbar()
      ),
    );
  }
}
