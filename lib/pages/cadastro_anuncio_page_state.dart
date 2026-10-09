import 'package:flutter/material.dart';

import '../models/anuncio.dart';
import 'cadastro_anuncio_page.dart';

class CadastroAnuncioPageState extends State<CadastroAnuncioPage> {
  final formKey = GlobalKey<FormState>();
  final tituloController = TextEditingController();
  final descricaoController = TextEditingController();
  final precoController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.anuncio != null) {
      tituloController.text = widget.anuncio!.titulo;
      descricaoController.text = widget.anuncio!.descricao;
      precoController.text = widget.anuncio!.preco.toString();
    }
  }

  @override
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    precoController.dispose();
    super.dispose();
  }

  void salvarAnuncio() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final preco = double.parse(precoController.text.replaceAll(',', '.'));

    final anuncio = Anuncio(
      titulo: tituloController.text,
      descricao: descricaoController.text,
      preco: preco,
    );

    Navigator.pop(context, anuncio);
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.anuncio != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE600),
        title: Text(editando ? 'Editar anuncio' : 'Cadastrar anuncio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: tituloController,
                decoration: const InputDecoration(
                  labelText: 'Titulo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o titulo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descricao',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a descricao';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: precoController,
                decoration: const InputDecoration(
                  labelText: 'Preco',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o preco';
                  }

                  final preco = double.tryParse(value.replaceAll(',', '.'));
                  if (preco == null || preco <= 0) {
                    return 'Informe um preco valido';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE600),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: salvarAnuncio,
                  child: Text(editando ? 'Salvar alteracoes' : 'Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
