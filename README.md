# MrFix
> LDAMD - PUC Minas | 2026/1

## Sobre o Projeto

**MrFix** é uma plataforma que conecta clientes que precisam de serviços de manutenção doméstica com profissionais especializados (eletricistas, encanadores, pedreiros, pintores, etc.).

**Diferencial de segurança:** o app permite que clientes, especialmente mulheres, filtrem prestadores por gênero, garantindo mais conforto e segurança ao solicitar serviços dentro de casa.

---

## Stack

- **Runtime:** Node.js 20+
- **Framework:** Express 4
- **Banco de dados:** SQLite (via Sequelize ORM)
- **Autenticação:** JWT (jsonwebtoken + bcryptjs)
- **Validação:** express-validator

---

## Como Rodar

```bash
# 1. Instalar dependências
npm install

# 2. Configurar ambiente
cp .env.example .env

# 3. Iniciar servidor (com seed automático)
npm run dev
# ou
npm start
```

O servidor inicia em `http://localhost:3000` e popula o banco automaticamente com dados de teste.

**Credenciais de teste (senha: `senha123`):**
| Usuário | Email | Perfil |
|---------|-------|--------|
| Ana Oliveira | ana@mrfix.com | Cliente (feminino) |
| Carlos Mendes | carlos@mrfix.com | Cliente (masculino) |
| Julia Santos | julia@mrfix.com | Prestadora (feminino) |
| Marcos Lima | marcos@mrfix.com | Prestador (masculino) |

---

## Endpoints da API

### Base URL: `http://localhost:3000/api`

### 🔐 Autenticação
| Método | Rota | Descrição | Auth |
|--------|------|-----------|------|
| POST | `/auth/register` | Cadastro de usuário | ❌ |
| POST | `/auth/login` | Login e recebimento de token | ❌ |
| GET | `/auth/me` | Dados do usuário logado | ✅ |

### 🔧 Solicitações de Serviço
| Método | Rota | Descrição | Auth |
|--------|------|-----------|------|
| POST | `/service-requests` | Criar solicitação | ✅ cliente |
| GET | `/service-requests` | Listar solicitações | ✅ |
| GET | `/service-requests/:id` | Detalhe de solicitação | ✅ |
| PATCH | `/service-requests/:id/status` | Atualizar status | ✅ |

### 👷 Prestadores
| Método | Rota | Descrição | Auth |
|--------|------|-----------|------|
| GET | `/providers` | Listar prestadores (filtro gênero/categoria) | ❌ |
| GET | `/providers/:id` | Perfil do prestador | ❌ |
| POST | `/providers/specialties` | Adicionar especialidade | ✅ prestador |
| GET | `/providers/me/specialties` | Minhas especialidades | ✅ prestador |

### ⭐ Avaliações
| Método | Rota | Descrição | Auth |
|--------|------|-----------|------|
| POST | `/ratings` | Avaliar após serviço concluído | ✅ |
| GET | `/ratings/user/:userId` | Ver avaliações recebidas | ❌ |

### 📋 Categorias
| Método | Rota | Descrição | Auth |
|--------|------|-----------|------|
| GET | `/categories` | Listar categorias de serviço | ❌ |
| GET | `/categories/:id` | Detalhe de categoria | ❌ |

---

## Fluxo de Status de uma Solicitação

```
pending → accepted → in_progress → completed
                   ↘ cancelled
        ↘ cancelled (pelo cliente)
```

---

## Schema do Banco de Dados

### users
| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID | PK |
| name | STRING | Nome completo |
| email | STRING | E-mail único |
| password_hash | STRING | Senha criptografada |
| phone | STRING | Telefone |
| role | ENUM | `client` ou `provider` |
| gender | ENUM | `male`, `female`, `other`, `prefer_not_to_say` |
| average_rating | FLOAT | Média de avaliações |
| rating_count | INTEGER | Quantidade de avaliações |
| is_active | BOOLEAN | Conta ativa |

### service_categories
| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID | PK |
| name | STRING | Ex: "Eletricista" |
| description | TEXT | Descrição do serviço |
| icon | STRING | Nome do ícone (para o app Flutter) |

### provider_specialties
| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID | PK |
| provider_id | UUID | FK → users |
| category_id | UUID | FK → service_categories |
| average_price | DECIMAL | Preço médio em R$ |
| experience_years | INTEGER | Anos de experiência |
| is_available | BOOLEAN | Disponível para serviços |

### service_requests
| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID | PK |
| client_id | UUID | FK → users |
| provider_id | UUID | FK → users (null até aceite) |
| category_id | UUID | FK → service_categories |
| title | STRING | Título da solicitação |
| status | ENUM | `pending`, `accepted`, `in_progress`, `completed`, `cancelled` |
| preferred_gender | ENUM | `male`, `female`, `any` — **filtro de segurança** |
| address | STRING | Endereço do serviço |
| agreed_price | DECIMAL | Valor acordado |
| verification_token | STRING | Token OTP (Sprint 4) |
| payment_method | ENUM | `credit_card`, `debit_card`, `pix` (Sprint 4) |

### ratings
| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID | PK |
| service_request_id | UUID | FK → service_requests |
| rater_id | UUID | Quem avaliou |
| rated_id | UUID | Quem recebeu a avaliação |
| score | INTEGER | 1 a 5 |
| comment | TEXT | Comentário opcional |

---

## Preparação para Sprints Futuras

**Sprint 2 (MOM):** Os controllers contêm comentários `// Sprint 2 hook` nos pontos de publicação de eventos (criação de solicitação, mudança de status). Basta implementar o producer do RabbitMQ nesses hooks.

**Sprint 3 (Flutter Cliente):** Todos os endpoints já retornam dados formatados para consumo direto no app Flutter, com paginação e includes necessários.

**Sprint 4 (Flutter Prestador + Pagamento):** Os campos `verification_token`, `payment_method` e `payment_status` já existem no schema, prontos para ativação.
