# PostgreSQL & PgAdmin

## Quick Start

```bash
docker compose up -d
```

## Environment Variables

Create a `.env` file to override defaults:

| Variable | Default |
|----------|---------|
| `POSTGRES_USER` | postgres |
| `POSTGRES_PASSWORD` | postgres |
| `POSTGRES_DB` | postgres |
| `PGADMIN_PORT` | 5050 |
| `PGADMIN_DEFAULT_EMAIL` | admin@local.dev |
| `PGADMIN_DEFAULT_PASSWORD` | admin |

## Access

**PostgreSQL:** `localhost:5432`

**PgAdmin:** http://localhost:5050

## Connect PgAdmin to PostgreSQL

1. Add New Server
2. **Host:** `postgres` (container name, not localhost)
3. **Port:** `5432`
4. **Username/Password:** your configured credentials
