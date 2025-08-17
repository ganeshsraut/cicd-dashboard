# Quick Start Guide

## CI/CD Pipeline Health Dashboard

Get up and running in 10 minutes! 🚀

### Prerequisites

- **Node.js 18+** and npm
- **Docker** and Docker Compose
- **Git** for version control

### 1. Clone and Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd assignment-2

# Copy environment variables
cp env.example .env

# Edit .env with your configuration
# (See environment variables section below)
```

### 2. Start with Docker (Recommended)

```bash
# Start all services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f backend
```

### 3. Access the Application

- **Frontend Dashboard**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **Database**: localhost:5432
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3001 (admin/admin)

### 4. Manual Setup (Alternative)

#### Backend Setup
```bash
cd backend
npm install
npm run dev
```

#### Frontend Setup
```bash
cd frontend
npm install
npm run dev
```

#### Database Setup
```bash
# Install PostgreSQL or use Docker
# Run the schema file
psql -U postgres -d cicd_dashboard -f database/schema.sql
```

### 5. Environment Variables

Edit `.env` file with your configuration:

```env
# Required: Database
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/cicd_dashboard

# Required: Security
JWT_SECRET=your-super-secret-jwt-key
SESSION_SECRET=your-super-secret-session-key

# Optional: GitHub Integration
GITHUB_TOKEN=your_github_personal_access_token

# Optional: Jenkins Integration
JENKINS_URL=http://jenkins.example.com
JENKINS_USERNAME=your_username
JENKINS_API_TOKEN=your_api_token

# Optional: Notifications
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK
SMTP_HOST=smtp.gmail.com
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password
```

### 6. First Steps

1. **Access the dashboard** at http://localhost:3000
2. **Create an organization** through the API or database
3. **Add a project** (GitHub repository or Jenkins job)
4. **Configure webhooks** for real-time updates
5. **Set up alerts** for failed builds

### 7. API Testing

```bash
# Test the API health
curl http://localhost:8000/health

# Test authentication
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"password"}'
```

### 8. Development Commands

```bash
# Backend development
cd backend
npm run dev          # Start development server
npm run test         # Run tests
npm run db:migrate   # Run database migrations
npm run db:studio    # Open Prisma Studio

# Frontend development
cd frontend
npm run dev          # Start development server
npm run build        # Build for production
npm run test         # Run tests
npm run lint         # Lint code
```

### 9. Common Issues & Solutions

#### Port Already in Use
```bash
# Find and kill process using port 3000
lsof -ti:3000 | xargs kill -9

# Or use different ports in .env
FRONTEND_PORT=3001
BACKEND_PORT=8001
```

#### Database Connection Issues
```bash
# Check if PostgreSQL is running
docker-compose ps postgres

# Restart database service
docker-compose restart postgres

# Check database logs
docker-compose logs postgres
```

#### Docker Build Issues
```bash
# Clean Docker cache
docker system prune -a

# Rebuild without cache
docker-compose build --no-cache
```

### 10. Next Steps

1. **Read the documentation** in the `docs/` folder
2. **Follow the implementation plan** for step-by-step development
3. **Set up your CI/CD tools** (GitHub Actions, Jenkins)
4. **Configure webhooks** for real-time monitoring
5. **Customize the dashboard** for your team's needs

### 11. Getting Help

- **Documentation**: Check the `docs/` folder
- **Issues**: Create an issue in the GitHub repository
- **Discussions**: Use GitHub Discussions for questions
- **Code Review**: Submit pull requests for improvements

### 12. Production Deployment

```bash
# Build production images
docker-compose -f docker-compose.prod.yml build

# Deploy to production
docker-compose -f docker-compose.prod.yml up -d

# Set production environment variables
export NODE_ENV=production
export DATABASE_URL=your_production_db_url
```

---

**Need help?** Check the full documentation or create an issue! 🆘

**Happy monitoring!** 📊✨
