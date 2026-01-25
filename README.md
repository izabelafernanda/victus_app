# 🏋️‍♀️ Victus App

Aplicação móvel de **fitness e nutrição**, desenvolvida em **Flutter** com backend em **PHP nativo**.  
O projeto é focado na experiência do utilizador, autenticação segura e consumo dinâmico de dados, seguindo fielmente o design system proposto.

---

## 📂 Estrutura do Projeto

A solução está organizada em dois diretórios principais, separando claramente as responsabilidades entre frontend e backend:

```text
victus_app/
├── api/                  # Backend (PHP Nativo + SQL)
│   ├── config/           # Configuração da Base de Dados
│   ├── db/               # Script SQL (Schema + Seeds)
│   ├── models/           # Classes de dados (User, Library, etc.)
│   ├── utils/            # Utilitários (ex: Gerador de JWT)
│   └── *.php             # Endpoints da API REST
│
├── app/                  # Frontend (Flutter Mobile/Web)
│   ├── lib/
│   │   ├── core/         # Configurações globais (ApiClient)
│   │   ├── data/         # Repositórios e Modelos
│   │   └── ui/           # Telas e Widgets (Login, Dashboard, etc.)
│   └── pubspec.yaml      # Dependências do projeto
│
└── README.md             # Documentação do projeto
```

---

## 📱 Funcionalidades Principais

* **Autenticação Completa:** Login, Registo de Nova Conta e Interface de Recuperação de Password.
* **Dashboard Dinâmico:** Exibe o nome do utilizador, dicas de saúde diárias, progresso de peso e próximos eventos, tudo alimentado pela API em tempo real.
* **Biblioteca de Treinos:** Listagem de cursos via API com navegação integrada e tratamento de estados (loading/vazio).
* **Player de Vídeo:** Reprodução de aulas com interface personalizada.
* **Segurança:** Sistema de autenticação via **JWT (JSON Web Token)** implementado manualmente.

---

## 🛠️ Tecnologias Utilizadas

* **Frontend:** Flutter (Dart)
* **Backend:** PHP (Vanilla/Nativo) - Sem frameworks
* **Base de Dados:** MySQL / MariaDB
* **Comunicação:** REST API (JSON)
* **HTTP Client:** Dio

---

## ⚙️ Instruções de Setup (Passo a Passo)

### 1. Configuração do Backend (API & Base de Dados)

1.  Certifique-se de ter um servidor local (ex: **XAMPP**, MAMP ou Docker) com PHP e MySQL.
2.  Coloque a pasta do projeto dentro do diretório público do servidor (ex: `C:\xampp\htdocs\victus_app`).
3.  Inicie o **Apache** e o **MySQL**.
4.  Aceda ao seu gestor de base de dados (ex: phpMyAdmin):
    * Crie uma base de dados chamada: `victus_db`
    * Importe o ficheiro SQL localizado em: `/api/db/schema.sql` (contém a estrutura e dados iniciais).
5.  Configure as credenciais de conexão em `/api/config/database.php` se necessário (Padrão configurado: root/sem senha).

### 2. Configuração do Frontend (App)

1.  Certifique-se de ter o **Flutter SDK** instalado e configurado.
2.  Abra o terminal na pasta `/app`.
3.  Instale as dependências:
    ```bash
    flutter pub get
    ```
4.  Execute a aplicação:
    ```bash
    flutter run
    ```
    *Nota: Se utilizar o emulador Android, verifique o `baseUrl` em `lib/core/api_client.dart` (padrão configurado para web/local: localhost).*

---

## 🧪 Credenciais de Teste

Para testar rapidamente sem criar conta:

* **Email:** `cristiana@victus.pt`
* **Password:** `123456`

*(Também pode utilizar a opção "Criar nova conta" na tela de login para gerar um novo utilizador).*

---

## 🏗️ Decisões de Arquitetura & Notas Técnicas

Para este projeto, foram tomadas as seguintes decisões técnicas focadas na entrega de valor, funcionalidade robusta e cumprimento dos requisitos:

* **HTTP Client (Dio):** Utilizado para todas as requisições, com implementação de *Interceptors* para injetar automaticamente o Token JWT nos cabeçalhos de autorização.
* **Gestão de Estado:** Optou-se pelo uso nativo de `setState` e `StatefulWidgets`.
* **Segurança PHP:** Implementação de headers CORS no backend para permitir o funcionamento correto em ambientes de desenvolvimento (Flutter Web/Localhost).

### 🔮 Melhorias Futuras (Roadmap)

Com o objetivo de evoluir o projeto para um ambiente de produção em larga escala, os próximos passos planeados seriam:

1.  **Arquitetura & Estado:** Migração completa para **Riverpod** ou **BLoC** e implementação estrita de **Clean Architecture**.
2.  **Testes Automatizados:** Implementação de testes unitários (backend e lógica Dart) e testes de integração (Frontend).
3.  **Funcionalidades Avançadas:**
    * Cache local de dados (Offline-first).
    * Upload de foto de perfil real.
    * Notificações Push (Firebase).
4.  **Backend:** Migração para um framework PHP robusto (ex: Laravel ou Symfony) para maior segurança e facilidade de manutenção.
