# Victus App

## Estrutura do Projeto

```
victus_app/
├── api/                  <-- Toda a lógica do Back-end
│   ├── config/           <-- Configuração do Banco de Dados
│   ├── db/               <-- Onde guardaremos o script SQL (backup)
│   ├── models/           <-- As "Classes" (Usuario, Curso, Aula)
│   └── uploads/          <-- Para guardar imagens (se precisarmos)
├── app/                  <-- Onde ficará o código Flutter (Front-end)
└── README.md             <-- Arquivo de texto para documentação
```

## Descrição

Este projeto contém a estrutura base para o desenvolvimento do Victus App, separando o back-end (API) do front-end (Flutter).

### Back-end (api/)
- **config/**: Configurações do banco de dados e outras configurações do servidor
- **db/**: Scripts SQL e backups do banco de dados
- **models/**: Modelos de dados (Usuario, Curso, Aula, etc.)
- **uploads/**: Armazenamento de arquivos e imagens enviados pelos usuários

### Front-end (app/)
- Código Flutter para a aplicação mobile
