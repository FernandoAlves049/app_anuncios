# Mercado de Anúncios

Aplicativo Flutter para cadastrar e gerenciar anúncios localmente. Cada anúncio pode ter título, descrição, preço e uma imagem.

## Requisitos

- Flutter e Dart compatíveis com o SDK `^3.12.2` definido no `pubspec.yaml`.
- Android com versão mínima 24.
- Navegador compatível com WebAssembly para executar a versão web.

## Como executar

No terminal, na pasta do projeto, instale as dependências e inicie o app:

```bash
flutter pub get
flutter run
```

Para executar no Chrome, prepare uma vez os arquivos do SQLite Web e use sempre a mesma porta para manter os dados locais do navegador:

```bash
dart run sqflite_common_ffi_web:setup
flutter run -d chrome --web-port 8080
```

## Funcionalidades

- Cadastrar, editar e excluir anúncios.
- Salvar os anúncios em um banco SQLite local. Os dados continuam disponíveis quando o app é fechado e aberto novamente.
- Escolher uma imagem da galeria ou tirar uma foto durante o cadastro. No Android, a imagem é copiada para o armazenamento permanente do app; no navegador, ela fica salva junto aos dados locais do SQLite.
- Compartilhar título, descrição e preço por SMS, e-mail ou WhatsApp. O app abre o aplicativo correspondente para concluir o envio.

## Organização do código

- `lib/models/anuncio.dart`: modelo e conversão dos anúncios para registros do banco.
- `lib/database/database_helper.dart`: abertura do banco e operações de inserir, consultar, atualizar e excluir.
- `lib/pages/cadastro_anuncio_page.dart`: formulário, seleção de imagem e validação.
- `lib/pages/lista_anuncios_page.dart`: listagem, ações dos anúncios e compartilhamento.

## Pacotes principais

- [`sqflite`](https://pub.dev/packages/sqflite): persistência em SQLite.
- [`sqflite_common_ffi_web`](https://pub.dev/packages/sqflite_common_ffi_web): implementação web experimental do SQLite, com persistência no IndexedDB.
- [`image_picker`](https://pub.dev/packages/image_picker): seleção de imagem da galeria ou câmera.
- [`path_provider`](https://pub.dev/packages/path_provider): diretório permanente para as imagens.
- [`path`](https://pub.dev/packages/path): montagem dos caminhos de arquivos e do banco.
- [`url_launcher`](https://pub.dev/packages/url_launcher): abertura de SMS, e-mail e WhatsApp.
