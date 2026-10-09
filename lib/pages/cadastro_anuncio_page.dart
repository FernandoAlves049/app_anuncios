import 'package:flutter/material.dart';

import '../models/anuncio.dart';

part 'cadastro_anuncio_page_state.dart';

class CadastroAnuncioPage extends StatefulWidget {
  final Anuncio? anuncio;

  const CadastroAnuncioPage({super.key, this.anuncio});

  @override
  State<CadastroAnuncioPage> createState() => _CadastroAnuncioPageState();
}
