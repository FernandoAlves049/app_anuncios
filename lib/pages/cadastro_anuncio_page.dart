import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/anuncio.dart';

class CadastroAnuncioPage extends StatefulWidget {
  final Anuncio? anuncio;

  const CadastroAnuncioPage({super.key, this.anuncio});

  @override
  State<CadastroAnuncioPage> createState() => _CadastroAnuncioPageState();
}

class _CadastroAnuncioPageState extends State<CadastroAnuncioPage> {
  final formKey = GlobalKey<FormState>();
  final tituloController = TextEditingController();
  final descricaoController = TextEditingController();
  final precoController = TextEditingController();
  final imagePicker = ImagePicker();

  XFile? imagemSelecionada;
  Uint8List? imagemSelecionadaBytes;
  String? imagemPath;
  String? imagemData;
  bool removerImagem = false;
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    final anuncio = widget.anuncio;
    if (anuncio != null) {
      tituloController.text = anuncio.titulo;
      descricaoController.text = anuncio.descricao;
      precoController.text = anuncio.preco.toString();
      imagemPath = anuncio.imagemPath;
      imagemData = anuncio.imagemData;
    }
  }

  @override
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    precoController.dispose();
    super.dispose();
  }

  Future<void> selecionarImagem(ImageSource origem) async {
    try {
      final arquivo = await imagePicker.pickImage(
        source: origem,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (arquivo == null || !mounted) return;
      final bytes = await arquivo.readAsBytes();
      if (!mounted) return;
      setState(() {
        imagemSelecionada = arquivo;
        imagemSelecionadaBytes = bytes;
        removerImagem = false;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível selecionar a imagem.')),
      );
    }
  }

  Future<void> escolherOrigemDaImagem() async {
    final origem = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Tirar uma foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (origem != null) await selecionarImagem(origem);
  }

  Future<({String? caminho, String? dados})> persistirImagem() async {
    if (removerImagem) return (caminho: null, dados: null);
    final selecionada = imagemSelecionada;
    if (selecionada == null) {
      return (caminho: imagemPath, dados: imagemData);
    }

    final bytes = imagemSelecionadaBytes ?? await selecionada.readAsBytes();
    if (kIsWeb) {
      return (caminho: null, dados: base64Encode(bytes));
    }

    final diretorio = await getApplicationDocumentsDirectory();
    final extensao = path.extension(selecionada.path).isEmpty
        ? '.jpg'
        : path.extension(selecionada.path);
    final destino = File(
      path.join(
        diretorio.path,
        'anuncio_${DateTime.now().microsecondsSinceEpoch}$extensao',
      ),
    );
    await File(selecionada.path).copy(destino.path);
    return (caminho: destino.path, dados: null);
  }

  Future<void> salvarAnuncio() async {
    if (!formKey.currentState!.validate() || salvando) return;

    setState(() => salvando = true);
    try {
      final preco = double.parse(precoController.text.replaceAll(',', '.'));
      final imagemPersistida = await persistirImagem();
      final anuncio = Anuncio(
        id: widget.anuncio?.id,
        titulo: tituloController.text.trim(),
        descricao: descricaoController.text.trim(),
        preco: preco,
        imagemPath: imagemPersistida.caminho,
        imagemData: imagemPersistida.dados,
      );
      if (mounted) Navigator.pop(context, anuncio);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar o anúncio.')),
      );
      setState(() => salvando = false);
    }
  }

  Widget construirImagem() {
    final bytesSelecionados = imagemSelecionadaBytes;
    if (bytesSelecionados != null) {
      return Image.memory(
        bytesSelecionados,
        width: double.infinity,
        height: 190,
        fit: BoxFit.cover,
      );
    }
    if (kIsWeb && !removerImagem && imagemData != null) {
      return Image.memory(
        base64Decode(imagemData!),
        width: double.infinity,
        height: 190,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported),
      );
    }
    final caminhoAtual = removerImagem ? null : imagemPath;
    if (!kIsWeb && caminhoAtual != null && File(caminhoAtual).existsSync()) {
      return Image.file(
        File(caminhoAtual),
        width: double.infinity,
        height: 190,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported),
      );
    }
    return const SizedBox(
      height: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 42),
          SizedBox(height: 8),
          Text('Adicionar uma imagem'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.anuncio != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE600),
        title: Text(editando ? 'Editar anúncio' : 'Novo anúncio'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InkWell(
              onTap: escolherOrigemDaImagem,
              borderRadius: BorderRadius.circular(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: construirImagem(),
                ),
              ),
            ),
            if (imagemSelecionada != null ||
                (!removerImagem && (imagemPath != null || imagemData != null)))
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(() {
                    imagemSelecionada = null;
                    imagemSelecionadaBytes = null;
                    removerImagem = true;
                  }),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remover imagem'),
                ),
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Digite o título'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Digite a descrição'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: precoController,
              decoration: const InputDecoration(
                labelText: 'Preço',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite o preço';
                }
                final preco = double.tryParse(value.replaceAll(',', '.'));
                if (preco == null || preco <= 0) {
                  return 'Preço inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: salvando ? null : salvarAnuncio,
              icon: salvando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(salvando ? 'Salvando...' : 'Salvar anúncio'),
            ),
          ],
        ),
      ),
    );
  }
}
