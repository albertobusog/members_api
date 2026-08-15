# Frontend (React + Vite + TypeScript + Apollo)

SPA que consume la API GraphQL de este repositorio.

```bash
npm install
npm run dev                 # development, usa .env.development
npm test                    # Vitest + Testing Library
npm run build:qa            # usa .env.qa
npm run build:production    # usa .env.production
```

La documentación completa (ambientes, variables y despliegue) está en el
[README raíz](../README.md).

## Estructura

- `src/apollo/` — cliente Apollo con `authLink` (JWT en `Authorization: Bearer`) y manejo de errores.
- `src/auth/` — sesión en `localStorage` y contexto de autenticación.
- `src/graphql/operations.ts` — todas las queries/mutations de la API.
- `src/pages/` — pantallas de autenticación, cliente y administración.
- `src/routes/ProtectedRoute.tsx` — protección de rutas por rol.
