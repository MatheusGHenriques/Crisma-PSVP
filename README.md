# Crisma PSVP

Um app em Flutter para a Crisma da Paróquia São Vicente de Paulo de Belo Horizonte.

## Funcionalidades

- **Envio de mensagens sem internet**: Permite a comunicação via rede local sem necessidade de conexão com a internet.
- **Login de usuário**: Cada usuário pode se autenticar fornecendo seu nome e as tags que representam os grupos dos quais faz parte.
- **Mensagens organizadas por grupo**: As mensagens são separadas por tags, garantindo uma comunicação mais organizada entre os participantes.
- **Histórico de mensagens**: O app armazena as mensagens localmente por um período determinado.

## Tecnologias Utilizadas

- **Flutter**: Framework para desenvolvimento do app.
- **Dart**: Linguagem de programação utilizada no desenvolvimento.
- **Hive_CE**: Banco de dados local para armazenamento eficiente das mensagens.

## Como Rodar o Projeto

1. Clone este repositório:
   ```sh
   git clone https://github.com/seu-usuario/crisma-psvp.git
   cd crisma-psvp
   ```
2. Instale as dependências:
   ```sh
   flutter pub get
   ```
3. Execute o aplicativo:
   ```sh
   flutter run
   ```