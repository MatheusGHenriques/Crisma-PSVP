# Crisma PSVP

Instagram: [@crismapsvp](https://instagram.com/crismapsvp)

Durante o retiro de Crisma da Paróquia São Vicente de Paulo de Belo Horizonte, a comunicação entre líderes e participantes dependia de rádios comunicadores — equipamentos limitados em quantidade, que exigiam que as pessoas permanecessem próximas a um dos rádios para ouvir as mensagens, e que permitiam a comunicação direta de apenas alguns membros da equipe.

O app **Crisma PSVP** busca resolver essa limitação: um app para múltiplos dispositivos que utiliza uma rede local Wi-Fi para oferecer comunicação fluida e em tempo real, permitindo a troca de mensagens, tarefas, enquetes e PDFs sem depender de conexão com a internet, estando disponível a todos os membros da equipe, em seus próprios smartphones ou computadores.

## Imagens

<table>
    <tr>
        <td><img src="home_main_theme.jpeg" width="200" style="display:none;"/></td>
        <td><img src="home_blue_theme.jpeg" width="200" style="display:none;"/></td>
        <td><img src="home_green_theme.jpeg" width="200" style="display:none;"/></td>
    </tr>
    <tr>
        <td><img src="login_page.jpeg" width="200" style="display:none;"/></td>
        <td><img src="chat_page.jpeg" width="200" style="display:none;"/></td>
        <td><img src="tasks_page.jpeg" width="200" style="display:none;"/></td>
    </tr>
</table>

## Funcionalidades

- **Comunicação via rede local**
  - Permite envio de mensagens e comunicação em rede local, sem necessidade de internet.
  - Descoberta de outros usuários na rede via broadcast utilizando o protocolo UDP.
  - Conexão via TCP para envio confiável de mensagens, tarefas, enquetes e PDFs.
  - Reconexão automática e remoção de peers inativos.
  - Indicador em tempo real do número de usuários (peers) conectados.

- **Login e autenticação de grupos**
  - Cada usuário pode se autenticar com seu nome.
  - Para acessar um grupo, o usuário deve digitar uma senha exclusiva daquele grupo, garantindo a segurança e a exclusividade do acesso.
  - Botão de logout para trocar de usuário/grupo sem reiniciar o app.

- **Mensagens organizadas por grupo e tags**
  - As mensagens são separadas por tags, permitindo organização clara e eficiente da comunicação.
  - Confirmação de leitura: cada mensagem mostra quem já a visualizou.
  - Opção de deletar para todos usuários mensagens enviadas manualmente.
  - Notificações locais para novas mensagens.

- **Gerenciamento de tarefas**
  - Os usuários podem criar, aceitar e concluir tarefas.
  - As tarefas são também organizadas por tags.
  - Expiração automática: tarefas com mais de 24h são removidas ao iniciar o app.
  - Dashboard na Home exibe contador de tarefas pendentes.
  - Notificações locais para novas tarefas.

- **Gerenciamento de enquetes**
  - Os usuários podem criar e votar em enquetes.
  - Suporte a respostas customizadas e voto único por dispositivo.
  - Organização por tags e dashboard com contador de enquetes ativas.
  - Expiração automática: enquetes com mais de 24h são removidas ao iniciar o app.
  - Notificações locais para novas enquetes.

- **Cronograma em PDF**
  - Visualização do cronograma atualizado em formato PDF.
  - Possibilidade de atualizar o cronograma diretamente pelo aplicativo (upload em rede local).
  - Notificação local quando um novo cronograma é recebido.

- **Envio de novos PDFs (Grupo da Música)**
  - Página exclusiva para o grupo de música adicionar novos PDFs de cifras.
  - Sincronização automática de cifras entre os peers.

- **Temas de cor**
  - Disponibilidade de 3 temas de cor, cada um com versões claras e escuras.
  - Botão para alternar tema e troca em tempo real.
  - Lotties customizadas para cada tema.

## Segurança e Criptografia

O app **Crisma PSVP** evoluirá para oferecer comunicação segura entre os membros, mesmo em ambientes totalmente offline, por meio de criptografia ponta a ponta baseada em senha de grupo.  
As etapas planejadas para a implementação da segurança são:

- **Derivação de chave a partir da senha do grupo**  
  Será utilizado o algoritmo **Argon2id** (Password-Hashing Competition winner) para derivar, de forma segura, uma chave de 256 bits a partir da senha compartilhada de cada grupo, usando um *salt* fixo embutido no app.  
  A derivação ocorrerá em um *isolate* (ou thread de background) para não travar a interface.  
  A chave resultante (`groupKey`) será armazenada no **Secure Storage** (Android Keystore / iOS Keychain) e **sobreviverá** a fechamentos do app e reinicializações do dispositivo.  
  Em logout, a `groupKey` será removida do Secure Storage para garantir que não haja uso indevido.

- **Criptografia e descriptografia de mensagens**  
  Cada mensagem será cifrada com uma **contentKey** aleatória, usando **AES-GCM (Advanced Encryption Standard no modo Galois/Counter Mode)**, garantindo confidencialidade e integridade.  
  Em seguida, essa `contentKey` será “envelopada” (cifrada) com cada `groupKey` dos grupos destinatários (multi-wrap).  
  Apenas peers que possuírem a `groupKey` correta conseguirão decifrar a `contentKey` e, depois, o conteúdo da mensagem.

- **Segurança no canal de comunicação (conexão TCP ponto a ponto)**  
  Toda conexão TCP fará um handshake via **ECDH (Elliptic Curve Diffie-Hellman)** sobre curva P-256 para gerar uma chave de sessão efêmera.  
  Após o handshake, o canal será cifrado com **AES-GCM**, garantindo sigilo, integridade e *forward secrecy* em todas as trocas de pacotes.

- **Armazenamento seguro e sincronização offline**  
  Todas as mensagens recebidas serão armazenadas no banco **Hive** **sempre cifradas**, exatamente como vieram do peer.  
  A descriptografia só ocorrerá no momento da exibição, e somente se o usuário tiver a `groupKey` correspondente ao grupo daquela mensagem.  
  O sistema operará **sem depender de internet ou servidores externos**, usando UDP para descoberta e TCP para dados na rede local.

- **Proteção de configuração e integridade do app**  
  Os arquivos de configuração que contêm *salt* e *hash* de validação serão protegidos por um HMAC, cuja chave será mantida no Secure Storage, evitando adulterações.

- **Proteção do dispositivo e controle de acesso**  
  Em dispositivos roteados (root) ou jailbroken, o Secure Storage pode ser comprometido.  
  Por isso, o app oferecerá proteções adicionais, como bloqueio de app via PIN ou biometria, para impedir acesso não autorizado.

- **Persistência do login e experiência do usuário**  
  Após inserir a senha do grupo pela primeira vez, a `groupKey` permanecerá no Secure Storage, permitindo que o usuário permaneça autenticado mesmo após fechar ou reiniciar o app.  
  A derivação por Argon2id será parametrizada para levar cerca de 300–500 ms em dispositivos médios, executando sempre em background, garantindo fluidez na interface.

Com essa arquitetura em camadas, o **Crisma PSVP** garantirá confidencialidade, integridade e boa experiência ao usuário, mesmo em redes totalmente offline.

## Bibliotecas e Tecnologias Utilizadas

- **hive_ce e hive_ce_flutter**: Bancos de dados locais para armazenamento eficiente.
- **flutter_secure_storage**: Acesso ao Secure Storage (Android Keystore e iOS Keychain).
- **cryptography e cryptography_flutter**: Algoritmos de criptografia e derivação de chave, com implementações nativas.
- **flutter_pdfview**: Para visualização de arquivos PDF.
- **file_picker**: Para seleção e upload de novos PDFs.
- **flutter_local_notifications**: Para notificações locais.
- **lottie**: Para renderização de animações.
- **path_provider**: Para gerenciamento de caminhos de arquivos.
- **collection**: Helpers para comparação profunda de listas e hashing.
- **google_nav_bar**: Barra de navegação inferior personalizável.
- **convert**: Codificação e decodificação de dados.

## Como Rodar o Projeto

- Instale o APK adequado ao seu dispositivo, disponível na pasta [`/apks`](./apks).

- Ou, se preferir:
1. Clone este repositório:
   ```sh
   git clone https://github.com/MatheusGHenriques/Crisma-PSVP.git
   cd Crisma-PSVP
   ```
2. Instale as dependências:
   ```sh
   flutter pub get
   ```
3. Execute o aplicativo:
   ```sh
   flutter run
   ```

## Licença

Este software é protegido por direitos autorais. Para mais detalhes, consulte o arquivo [LICENSE](./LICENSE).

Somente a Paróquia São Vicente de Paulo de Belo Horizonte e suas pastorais podem utilizar o app sem necessidade de autorização escrita.

Testes para avaliar o funcionamento do app também podem ser feitos sem autorização.

Qualquer outro uso exige autorização prévia do autor.

Contate matheusghenriques@proton.me para permissões.
