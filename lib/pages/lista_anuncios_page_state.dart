import 'package:flutter/material.dart';

import '../models/anuncio.dart';
import 'cadastro_anuncio_page.dart';
import 'lista_anuncios_page.dart';

class ListaAnunciosPageState extends State<ListaAnunciosPage> {
  final List<Anuncio> anuncios = [
    Anuncio(
      titulo: 'Celular Motorola',
      descricao: 'Aparelho conservado, com carregador.',
      preco: 850,
    ),
    Anuncio(
      titulo: 'Servico de pintura automotiva',
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

    if (resultado == null) {
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Anuncio removido com sucesso')),
    );
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
          'Mercado Simples',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: anuncios.isEmpty
          ? const Center(
              child: Text(
                'Nenhum anuncio cadastrado.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: anuncios.length,
              itemBuilder: (context, index) {
                final anuncio = anuncios[index];

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE600),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shopping_bag),
                    ),
                    title: Text(
                      anuncio.titulo,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(anuncio.descricao),
                          const SizedBox(height: 6),
                          Text(
                            formatarPreco(anuncio.preco),
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: SizedBox(
                      width: 96,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              abrirTelaCadastro(anuncio: anuncio, index: index);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removerAnuncio(index),
                          ),
                        ],
                      ),
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
