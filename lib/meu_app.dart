import 'package:flutter/material.dart';

import 'pages/lista_anuncios_page.dart';

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anúncios',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFE600)),
        useMaterial3: true,
      ),
      home: const ListaAnunciosPage(),
    );
  }
}
