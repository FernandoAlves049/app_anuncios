import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/database_helper.dart';
import '../models/anuncio.dart';
import 'cadastro_anuncio_page.dart';

enum AcaoAnuncio { editar, excluir, sms, email, whatsapp }

class ListaAnunciosPage extends StatefulWidget {
  const ListaAnunciosPage({super.key});

  @override
  State<ListaAnunciosPage> createState() => _ListaAnunciosPageState();
}

class _ListaAnunciosPageState extends State<ListaAnunciosPage> {
  final List<Anuncio> anuncios = [];
  bool carregando = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarAnuncios();
  }

  Future<void> carregarAnuncios() async {
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      final dados = await DatabaseHelper.instance.buscarTodos();
      if (!mounted) return;
      setState(() {
        anuncios
          ..clear()
          ..addAll(dados);
        carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        erro = 'Não foi possível carregar os anúncios.';
        carregando = false;
      });
    }
  }

  Future<void> abrirTelaCadastro({Anuncio? anuncio}) async {
    final resultado = await Navigator.push<Anuncio>(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroAnuncioPage(anuncio: anuncio),
      ),
    );
    if (!mounted || resultado == null) return;

    try {
      if (resultado.id == null) {
        await DatabaseHelper.instance.inserir(resultado);
      } else {
        await DatabaseHelper.instance.atualizar(resultado);
      }
      await apagarImagemAntigaSeNecessario(
        anuncio?.imagemPath,
        resultado.imagemPath,
      );
      await carregarAnuncios();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              anuncio == null ? 'Anúncio cadastrado.' : 'Anúncio atualizado.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      await apagarImagemAntigaSeNecessario(
        resultado.imagemPath,
        anuncio?.imagemPath,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar o anúncio.')),
      );
    }
  }

  Future<void> apagarImagemAntigaSeNecessario(
    String? caminhoAntigo,
    String? caminhoNovo,
  ) async {
    if (caminhoAntigo == null || caminhoAntigo == caminhoNovo) return;
    try {
      final arquivo = File(caminhoAntigo);
      if (await arquivo.exists()) await arquivo.delete();
    } catch (_) {
      // A imagem órfã pode ser removida depois; não desfaz a operação no banco.
    }
  }

  Future<void> removerAnuncio(Anuncio anuncio) async {
    try {
      if (anuncio.id == null) return;
      await DatabaseHelper.instance.excluir(anuncio.id!);
      await apagarImagemAntigaSeNecessario(anuncio.imagemPath, null);
      await carregarAnuncios();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Anúncio removido.')));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível remover o anúncio.')),
      );
    }
  }

  String formatarPreco(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String textoParaCompartilhar(Anuncio anuncio) {
    return '${anuncio.titulo}\n${anuncio.descricao}\nPreço: ${formatarPreco(anuncio.preco)}';
  }

  Future<void> compartilhar(Anuncio anuncio, AcaoAnuncio acao) async {
    final mensagem = textoParaCompartilhar(anuncio);
    late final Uri uri;
    switch (acao) {
      case AcaoAnuncio.sms:
        uri = Uri(scheme: 'sms', queryParameters: {'body': mensagem});
        break;
      case AcaoAnuncio.email:
        uri = Uri(
          scheme: 'mailto',
          queryParameters: {
            'subject': 'Anúncio: ${anuncio.titulo}',
            'body': mensagem,
          },
        );
        break;
      case AcaoAnuncio.whatsapp:
        uri = Uri.https('wa.me', '/', {'text': mensagem});
        break;
      case AcaoAnuncio.editar:
      case AcaoAnuncio.excluir:
        return;
    }

    try {
      final abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!abriu && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível abrir o aplicativo de compartilhamento.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível abrir o aplicativo de compartilhamento.',
          ),
        ),
      );
    }
  }

  Future<void> executarAcao(Anuncio anuncio, AcaoAnuncio acao) async {
    switch (acao) {
      case AcaoAnuncio.editar:
        await abrirTelaCadastro(anuncio: anuncio);
        break;
      case AcaoAnuncio.excluir:
        await removerAnuncio(anuncio);
        break;
      case AcaoAnuncio.sms:
      case AcaoAnuncio.email:
      case AcaoAnuncio.whatsapp:
        await compartilhar(anuncio, acao);
        break;
    }
  }

  Widget miniatura(Anuncio anuncio) {
    if (kIsWeb) {
      final dados = anuncio.imagemData;
      if (dados == null) {
        return const CircleAvatar(child: Icon(Icons.image_outlined));
      }
      try {
        return CircleAvatar(
          backgroundImage: MemoryImage(base64Decode(dados)),
          onBackgroundImageError: (_, _) {},
        );
      } catch (_) {
        return const CircleAvatar(child: Icon(Icons.image_not_supported));
      }
    }
    final caminho = anuncio.imagemPath;
    if (caminho == null || !File(caminho).existsSync()) {
      return const CircleAvatar(child: Icon(Icons.image_outlined));
    }
    return CircleAvatar(
      backgroundImage: FileImage(File(caminho)),
      onBackgroundImageError: (_, _) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE600),
        title: const Text(
          'Mercado de Anúncios',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : erro != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(erro!),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: carregarAnuncios,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          : anuncios.isEmpty
          ? const Center(
              child: Text(
                'Nenhum anúncio cadastrado',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: anuncios.length,
              itemBuilder: (context, index) {
                final anuncio = anuncios[index];
                return Card(
                  child: ListTile(
                    leading: miniatura(anuncio),
                    title: Text(anuncio.titulo),
                    subtitle: Text(
                      '${anuncio.descricao}\n${formatarPreco(anuncio.preco)}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<AcaoAnuncio>(
                      tooltip: 'Ações do anúncio',
                      onSelected: (acao) => executarAcao(anuncio, acao),
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: AcaoAnuncio.editar,
                          child: ListTile(
                            dense: true,
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Editar'),
                          ),
                        ),
                        PopupMenuItem(
                          value: AcaoAnuncio.excluir,
                          child: ListTile(
                            dense: true,
                            leading: Icon(Icons.delete_outline),
                            title: Text('Excluir'),
                          ),
                        ),
                        PopupMenuItem(
                          value: AcaoAnuncio.sms,
                          child: ListTile(
                            dense: true,
                            leading: Icon(Icons.sms_outlined),
                            title: Text('Compartilhar por SMS'),
                          ),
                        ),
                        PopupMenuItem(
                          value: AcaoAnuncio.email,
                          child: ListTile(
                            dense: true,
                            leading: Icon(Icons.email_outlined),
                            title: Text('Compartilhar por e-mail'),
                          ),
                        ),
                        PopupMenuItem(
                          value: AcaoAnuncio.whatsapp,
                          child: ListTile(
                            dense: true,
                            leading: Icon(Icons.chat_outlined),
                            title: Text('Compartilhar no WhatsApp'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFE600),
        foregroundColor: Colors.black,
        onPressed: () => abrirTelaCadastro(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
