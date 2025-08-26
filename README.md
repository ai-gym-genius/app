# GymGenius 🏋️‍♂️

*Offline-first workout tracker with AI-powered feedback and a full web admin console.*

## Expressive and Simple design

![Intro](pics/intro.png)
![Product](pics/product.png)
![Mobile](pics/mobile.png)

## Dynamic Theming

![Themes](pics/themes.png)

## Backend Synchronization
![Sync](pics/sync.png)

## AI support
![AI](pics/ai.png)

---

## Table of Contents
1. [Monorepo Layout](#monorepo-layout)
2. [Key Features](#key-features)
3. [Tech Stack](#tech-stack)
4. [Getting Started](#getting-started)
5. [License](#license)

---

## Monorepo Layout

```text
.
├─ mobile/               # Flutter app (Android & iOS)
│  └─ lib/
├─ api/                  # Go services (gin + gRPC)
│  ├─ cmd/
│  └─ internal/
├─ admin/                # Vue-TS web console
│  └─ src/
├─ scripts/              # helper bash/PowerShell helpers
└─ docs/                 # ADRs, diagrams, onboarding
```

---

## Key Features

| Mobile                                                                                                                                               | Backend                                                                                                                                         | Admin                                                                                                                                           |
| ---------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| -  Start/stop workouts, add sets/reps/weight-  Heat-map statistics and graphs-  ❄️ **Offline-first** (local DB → async sync)-  AI "Get Feedback" button | -  gRPC + REST API-  Delta-sync algorithm-  PostgreSQL + SQLC-  Stripe web-hooks for subscriptions-  OpenAI-powered workout analysis | -  Metrics dashboard (PromQL via Grafana)-  Role-based access control |

---

## Tech Stack

| Layer  | Tech                                          |
| ------ | --------------------------------------------- |
| Mobile | Flutter 3.22 / Dart 3 · Bloc · Sqlite     |
| API    | Go 1.22 · gin · gRPC-Gateway · PostgreSQL >14 |
| Admin  | React 18 (Vite) · TypeScript 5 · shadcn/ui · TanStack Query |
| AI     | OpenAI API · Golang concurrency workers |
| DevOps | Docker-Compose · GitHub Actions CI · Terraform (Linodes) |

---

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed on your machine:

- **Docker & Docker Compose** - [Install Docker](https://docs.docker.com/get-docker/)
- **Git** - [Install Git](https://git-scm.com/downloads)
- **Node.js 18+** - [Install Node.js](https://nodejs.org/) (for local development)
- **Go 1.22+** - [Install Go](https://golang.org/dl/) (for API development)
- **Flutter 3.22+** - [Install Flutter](https://docs.flutter.dev/get-started/install) (for mobile development)

### Quick Start (Docker Compose - Recommended)

This is the fastest way to get the entire project running:

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd gym-genius
   ```

2. **Set up environment variables**
   ```bash
   cp .env_example .env
   # Edit .env file with your preferred values (defaults work for local development)
   ```

3. **Build and start all services**
   ```bash
   docker-compose up --build
   ```

4. **Access the applications**
   - **Admin Frontend**: http://localhost:8080
   - **Admin Backend API**: http://localhost:3000
   - **Mobile Web App**: http://localhost:8088
   - **Main API**: http://localhost:8000 (if running separately)
   - **MinIO Console**: http://localhost:9001 (minio/minio)
   - **PostgreSQL**: localhost:5432

### Component-by-Component Setup

#### 1. Database Setup

**Option A: Using Docker (Recommended)**
```bash
docker-compose up postgres -d
```

**Option B: Local PostgreSQL**
```bash
# Install PostgreSQL 15+
# Create databases
createdb admindb
createdb gym_genius
```

#### 2. Admin Panel (Backend + Frontend)

**Using Docker:**
```bash
# Start backend and frontend
docker-compose up backend frontend postgres -d
```

**Local Development:**
```bash
# Backend (Go)
cd admin/backend
cp .env.example .env
go mod download
go run app/main.go

# Frontend (Nuxt.js) - in another terminal
cd admin/frontend
npm install
npm run dev
```

Access: Frontend at http://localhost:3000, Backend API at http://localhost:3000

#### 3. Main API Service

```bash
cd api/gym-genius
go mod download

# Update config/config.local.yaml with your database URL
# Default: postgres://postgres:postgres@localhost:5432/gym_genius

go run cmd/main.go
```

Access: API at http://localhost:8000

#### 4. Mobile App

**Option A: Web Version (Docker)**
```bash
docker-compose up mobile -d
```
Access: http://localhost:8088

**Option B: Local Development**
```bash
cd mobile/
flutter pub get

# For web development
flutter run -d chrome --web-port 8080

# For Android (requires Android Studio/SDK)
flutter run

# For iOS (requires Xcode, macOS only)
flutter run
```

### Environment Configuration

The project uses environment variables for configuration. Key variables include:

```bash
# Database
DB_HOST=postgres
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=admindb
DB_PORT=5432

# Authentication
AUTH_SECRET=your-auth-secret
JWT_SECRET=your-jwt-secret

# MinIO (Object Storage)
MINIO_ROOT_USER=minio
MINIO_ROOT_PASSWORD=minio123

# Application
APP_ENV=DEV
```

### Development Workflow

#### Running Individual Services

**Admin Backend Only:**
```bash
docker-compose up postgres -d
cd admin/backend && go run app/main.go
```

**Admin Frontend Only:**
```bash
cd admin/frontend && npm run dev
```

**API Service Only:**
```bash
docker-compose up postgres -d
cd api/gym-genius && go run cmd/main.go
```

**Mobile Development:**
```bash
cd mobile/
flutter run -d chrome  # Web
flutter run            # Native mobile
```

#### Hot Reload Development

For active development with hot reload:

1. **Start dependencies:**
   ```bash
   docker-compose up postgres minio -d
   ```

2. **Run services locally:**
   ```bash
   # Terminal 1: Admin Backend
   cd admin/backend && go run app/main.go
   
   # Terminal 2: Admin Frontend
   cd admin/frontend && npm run dev
   
   # Terminal 3: Main API
   cd api/gym-genius && go run cmd/main.go
   
   # Terminal 4: Mobile (web)
   cd mobile && flutter run -d chrome
   ```

### Testing

```bash
# Backend tests
cd admin/backend && go test ./...

# Frontend tests
cd admin/frontend && npm test

# API tests
cd api/gym-genius && go test ./...

# Mobile tests
cd mobile && flutter test
```

### Troubleshooting

#### Common Issues

1. **Port conflicts**: Ensure ports 3000, 5432, 8000, 8080, 8088, 9000, 9001 are available
2. **Docker permission issues**: Run `docker-compose` with `sudo` if needed
3. **Database connection errors**: Verify PostgreSQL is running and credentials match
4. **Flutter web issues**: Ensure Flutter web is enabled: `flutter config --enable-web`

#### Logs

```bash
# View all service logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f postgres
```

#### Reset Everything

```bash
# Stop all services and remove volumes
docker-compose down -v

# Remove built images
docker-compose down --rmi all

# Start fresh
docker-compose up -d --build
```

### Production Deployment

For production deployment, see the individual component READMEs:
- [Admin Backend README](admin/backend/README.md)
- [Admin Frontend README](admin/frontend/README.md)
- [API README](api/gym-genius/README.md)
- [Mobile README](mobile/README.md)
