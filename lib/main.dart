import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocab_master/navigation_bar/pages/navigationbar.dart';
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
          create: (_) => WordsProvider()..loadWords(),
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
