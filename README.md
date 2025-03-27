# Crisma PSVP

Um app em Flutter para a Crisma da Paróquia São Vicente de Paulo de Belo Horizonte.

## Funcionalidades

- **Comunicação via rede local**:
   - Permite envio de mensagens e comunicação em rede local, sem necessidade de internet.
   - Descoberta de outros usuários na rede via broadcast utilizando o protocolo UDP.
   - Conexão via TCP para envio confiável de mensagens, tarefas, enquetes e PDFs.
- **Login e autenticação de grupos**:
   - Cada usuário pode se autenticar com seu nome.
   - Para acessar um grupo, o usuário deve digitar uma senha exclusiva daquele grupo, garantindo a segurança e a exclusividade do acesso.
- **Mensagens organizadas por grupo e tags**:
   - As mensagens são separadas por tags, permitindo uma organização clara e eficiente da comunicação entre os participantes.
- **Gerenciamento de tarefas**:
   - Os usuários podem criar, aceitar e concluir tarefas.
   - As tarefas são também organizadas por tags, facilitando o acompanhamento e a priorização das atividades.
- **Gerenciamento de enquetes**:
   - Os usuários podem criar e votar em enquetes.
   - As enquetes são também organizadas por tags, facilitando o destino ao público alvo, e podem permitir respostas customizadas.
- **Cronograma em PDF**:
   - Visualização do cronograma atualizado em formato PDF.
   - Possibilidade de atualizar o cronograma diretamente pelo aplicativo.
- **Artes animadas**:
   - Utiliza Lotties para apresentar artes animadas e melhorar a experiência visual do usuário.
- **Temas de cor**:
   - Disponibilidade de 3 temas de cor, cada um com versões claras e escuras, permitindo personalização da interface de acordo com a preferência do usuário.

## Tecnologias Utilizadas

- **Flutter**: Framework para desenvolvimento do app.
- **Dart**: Linguagem de programação utilizada no desenvolvimento.
- **Hive_CE e Hive_CE_Flutter**: Bancos de dados locais para armazenamento eficiente das mensagens, tarefas e demais informações.
- **flutter_pdfview**: Para visualização de arquivos PDF dentro do aplicativo.
- **Lottie**: Para renderização de animações vetoriais.
- **Path Provider**: Para gerenciamento de caminhos do sistema de arquivos.

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