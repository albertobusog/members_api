# Members API + SPA

Monorepo con:

- **Backend**: API Ruby on Rails 8 (API-only) con GraphQL en `POST /graphql`, autenticación Devise + JWT y roles `client` / `admin`.
- **Frontend** (`frontend/`): SPA React 19 + Vite + TypeScript + Apollo Client, probada con Vitest y Testing Library.

## Requisitos

- Ruby 3.3.0 (ver `.ruby-version` / `mise.toml`)
- Node.js 22+
- SQLite (development/test) y PostgreSQL (qa/production)

## Backend en local

```bash
bundle install
bin/rails db:prepare
bin/rails server            # http://localhost:3000
```

Endpoints:

- `POST /graphql` — API GraphQL. `signIn` y `signUp` son públicas; el resto exige
  `Authorization: Bearer <token>` (si falta o es inválido la API responde `401`).
- `GET /health` — health check con estado de la base de datos (usado por el hosting).
- `GET /up` — health check estándar de Rails.

### Tests del backend

```bash
bundle exec rspec
bin/rubocop
```

## Frontend en local

```bash
cd frontend
npm install
npm run dev                 # http://localhost:5173
```

### Tests del frontend (TDD)

```bash
cd frontend
npm test                    # vitest run
npm run test:watch
npm run test:coverage
npm run typecheck
npm run lint
```

Cada funcionalidad se implementó escribiendo primero el test con Vitest +
Testing Library, mockeando GraphQL con `MockedProvider` de Apollo.

## Los tres ambientes

| Ambiente     | Backend                                   | Frontend                                  |
| ------------ | ----------------------------------------- | ----------------------------------------- |
| development  | `bin/rails server` (SQLite)                | `npm run dev` (usa `.env.development`)    |
| qa           | `RAILS_ENV=qa` (PostgreSQL vía `DATABASE_URL`) | `npm run build:qa` (usa `.env.qa`)    |
| production   | `RAILS_ENV=production` (PostgreSQL)        | `npm run build:production` (`.env.production`) |

QA es un ambiente tipo producción con logging y eager load configurables
(`config/environments/qa.rb`):

```bash
RAILS_ENV=qa DATABASE_URL=postgres://... bin/rails db:prepare
RAILS_ENV=qa DATABASE_URL=postgres://... RAILS_LOG_LEVEL=debug bin/rails server
```

### Variables de entorno

Backend:

| Variable                 | Uso                                                                     |
| ------------------------ | ----------------------------------------------------------------------- |
| `RAILS_ENV`              | `development`, `qa` o `production`                                       |
| `RAILS_MASTER_KEY`       | Desencripta `config/credentials.yml.enc`                                 |
| `DATABASE_URL`           | Conexión PostgreSQL en qa/production                                     |
| `DEVISE_JWT_SECRET_KEY`  | Secreto para firmar los JWT (obligatorio en qa/production)               |
| `FRONTEND_ORIGINS`       | Orígenes CORS extra, separados por coma (`https://app.vercel.app,...`)   |
| `RAILS_ALLOWED_HOSTS`    | Hosts permitidos, separados por coma (además del host del proveedor)     |
| `RAILS_LOG_LEVEL`        | Nivel de log (por defecto `info`)                                        |

En development se permiten por defecto `http://localhost:5173`, `http://127.0.0.1:5173`
y los puertos 4173 del `vite preview`.

Frontend (`frontend/.env.development`, `.env.qa`, `.env.production`):

| Variable            | Uso                                              |
| ------------------- | ------------------------------------------------ |
| `VITE_GRAPHQL_URL`  | URL completa del endpoint GraphQL de ese ambiente |
| `VITE_APP_ENV`      | Nombre del ambiente                               |

## Despliegue gratuito

### Backend en Render

`render.yaml` define dos servicios Docker (`members-api-qa` y `members-api`) y
dos bases PostgreSQL en plan free.

1. En Render: *New → Blueprint* apuntando a este repositorio.
2. Completar los valores marcados como `sync: false`: `RAILS_MASTER_KEY` y
   `FRONTEND_ORIGINS` (URLs del frontend en Vercel/Netlify).
   `DEVISE_JWT_SECRET_KEY` se genera automáticamente y `DATABASE_URL` se
   inyecta desde la base asociada.
3. `bin/docker-entrypoint` ejecuta `bin/rails db:prepare` en cada arranque, así
   que las migraciones corren solas.
4. Health check configurado en `/health`.

El `Dockerfile` usa Ruby 3.3.0 e instala `libpq`/`postgresql-client`; la gema
`pg` está en los grupos `production` y `qa`.

### Frontend en Vercel

`frontend/vercel.json` deja listo el proyecto (root directory `frontend`):

- Producción: `npm run build:production`.
- QA: crear un segundo proyecto (o un branch deploy) con build command
  `npm run build:qa`.
- Definir `VITE_GRAPHQL_URL` en el panel de Vercel por ambiente para apuntar al
  backend correcto (por ejemplo `https://members-api-qa.onrender.com/graphql` y
  `https://members-api.onrender.com/graphql`). Los valores del panel
  sobrescriben los archivos `.env.*` del repo.

### Frontend en Netlify (alternativa)

`netlify.toml` en la raíz: base `frontend`, publish `frontend/dist`, build de
producción en la rama principal y build de QA en deploy previews / branch
deploys, con redirect SPA a `index.html`.

Después de desplegar, añadir las URLs finales del frontend a `FRONTEND_ORIGINS`
en Render para que CORS las acepte.
