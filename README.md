# Laravel React Application with Docker Setup

This is an empty Laravel application with React frontend. It can be quickly hosted by using Docker Compose. Two GitHub Actions workflows are included: one for running tests and another for building and deploying to GitHub Container Registry.

## Docker Compose Setup

The infrastructure consists of:

- **Laravel application** (uses custom built image)
- **Caddy** (`caddy:latest` image) - HTTP server
- **Redis** (`redis:latest` image) - cache service
- **Postgres** (`postgres:latest` image) - SQL database

This setup uses bridge network for interaction between containers and shared file volumes.

### Running the Infrastructure

To run this infrastructure:

```bash
cd docker
docker compose -f compose.yaml up --build
```

## GitHub Actions Workflows

### 1. Example App CI/CD

Workflow triggered on:
- Push to master branch
- Closed pull request to master branch

Actions:
- Logs in to GitHub Container Registry (GHCR)
- Builds `ghcr.io/oudrius/example-app:latest` docker image in QEMU environment
- Pushes the image to GHCR

### 2. Run Tests

Workflow triggered on:
- Push to master branch
- Pull request on master branch

Actions:
- Installs Composer, npm and required dependencies
- Runs Laravel tests using `php artisan test` command
