import 'package:flutter/material.dart';

import '../models/anuncio.dart';
import 'cadastro_anuncio_page.dart';

class ListaAnunciosPage extends StatefulWidget {
  const ListaAnunciosPage({super.key});

  @override
  State<ListaAnunciosPage> createState() => _ListaAnunciosPageState();
}

class _ListaAnunciosPageState extends State<ListaAnunciosPage> {
  final List<Anuncio> anuncios = [
    Anuncio(
      titulo: 'Celular Motorola',
      descricao: 'Aparelho conservado, com carregador.',
      preco: 850,
    ),
    Anuncio(
      titulo: 'Serviço de pintura automotiva',
      descricao: 'Pintura, polimento e pequenos reparos.',
      preco: 300,
    ),
  ];

  Future<void> abrirTelaCadastro({Anuncio? anuncio, int? index}) async {
    final resultado = await Navigator.push<Anuncio>(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroAnuncioPage(anuncio: anuncio),
      ),
    );

    if (!mounted || resultado == null) {
      return;
    }

    setState(() {
      if (index == null) {
        anuncios.add(resultado);
      } else {
        anuncios[index] = resultado;
      }
    });
  }

  void removerAnuncio(int index) {
    setState(() {
      anuncios.removeAt(index);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Anúncio removido')));
  }

  String formatarPreco(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
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
      body: anuncios.isEmpty
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
                    title: Text(anuncio.titulo),
                    subtitle: Text(
                      '${anuncio.descricao}\n${formatarPreco(anuncio.preco)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            abrirTelaCadastro(anuncio: anuncio, index: index);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => removerAnuncio(index),
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
        onPressed: abrirTelaCadastro,
        child: const Icon(Icons.add),
      ),
    );
  }
}
