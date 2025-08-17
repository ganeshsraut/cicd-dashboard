# CI/CD Pipeline Health Dashboard

A comprehensive dashboard for monitoring CI/CD pipeline health across multiple platforms including GitHub Actions and Jenkins.

## 🚀 Features

- **Real-time Monitoring**: Track pipeline success/failure rates, build times, and status
- **Multi-Platform Support**: GitHub Actions, Jenkins, and extensible for other CI/CD tools
- **Smart Alerting**: Slack and email notifications for failed builds
- **Modern UI**: Responsive dashboard with real-time updates
- **AI-Powered Insights**: Leverage AI tools for development and optimization

## 🏗️ Architecture

- **Backend**: Node.js with Express.js
- **Frontend**: React with TypeScript
- **Database**: PostgreSQL for metrics storage
- **Real-time**: WebSocket connections for live updates
- **Containerization**: Docker for easy deployment

## 🛠️ Tech Stack

- **Backend**: Node.js, Express.js, TypeScript
- **Frontend**: React, TypeScript, Tailwind CSS
- **Database**: PostgreSQL, Prisma ORM
- **Real-time**: Socket.io
- **Monitoring**: Prometheus, Grafana (optional)
- **CI/CD**: GitHub Actions for self-hosting

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- Docker and Docker Compose
- PostgreSQL (or use Docker)
- GitHub Personal Access Token
- Jenkins API credentials (if using Jenkins)

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd assignment-2
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Start with Docker**
   ```bash
   docker-compose up -d
   ```

4. **Access the dashboard**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000
   - Database: localhost:5432

## 📁 Project Structure

```
assignment-2/
├── backend/                 # Node.js backend API
├── frontend/               # React frontend application
├── database/               # Database migrations and schemas
├── docker/                 # Docker configuration files
├── docs/                   # Documentation and design docs
├── scripts/                # Utility scripts
└── tests/                  # Test files
```

## 🤖 AI Tools Usage Summary

This project was developed with assistance from:

- **Cursor IDE**: Primary development environment with AI-powered code completion
- **GitHub Copilot**: Code suggestions and best practices
- **GPT-4**: Architecture design, problem-solving, and code review

### AI-Assisted Development Areas

1. **Architecture Design**: Initial system design and component breakdown
2. **Code Generation**: Boilerplate code, API endpoints, and UI components
3. **Best Practices**: Security considerations, error handling, and performance optimization
4. **Problem Solving**: Debugging assistance and alternative implementation approaches

## 📊 Dashboard Features

- **Pipeline Overview**: Success/failure rates, average build times
- **Real-time Status**: Live updates of running builds
- **Historical Data**: Trends and performance analytics
- **Alert Management**: Configure and manage notification rules
- **Log Viewer**: Search and filter build logs
- **Team Collaboration**: Share insights and reports

## 🔧 Configuration

### Environment Variables

```env
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/cicd_dashboard

# GitHub
GITHUB_TOKEN=your_github_token
GITHUB_WEBHOOK_SECRET=your_webhook_secret

# Jenkins
JENKINS_URL=http://jenkins.example.com
JENKINS_USERNAME=username
JENKINS_API_TOKEN=api_token

# Notifications
SLACK_WEBHOOK_URL=your_slack_webhook
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email
SMTP_PASS=your_password

# Security
JWT_SECRET=your_jwt_secret
SESSION_SECRET=your_session_secret
```

## 🧪 Testing

```bash
# Backend tests
cd backend && npm test

# Frontend tests
cd frontend && npm test

# Integration tests
npm run test:integration
```

## 📈 Monitoring

The dashboard includes built-in monitoring for:
- API response times
- Database query performance
- WebSocket connection health
- External API rate limits

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

## 🆘 Support

For issues and questions:
- Create an issue in the GitHub repository
- Check the documentation in the `docs/` folder
- Review the troubleshooting guide

---

**Built with ❤️ and AI assistance**
