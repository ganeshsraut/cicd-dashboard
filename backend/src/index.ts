import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { createServer } from 'http';
import { Server } from 'socket.io';
import dotenv from 'dotenv';
import { rateLimit } from 'express-rate-limit';
import compression from 'compression';

// Load environment variables
dotenv.config();

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.CORS_ORIGIN || "http://localhost:3000",
    methods: ["GET", "POST"]
  }
});

const PORT = process.env.PORT || 8000;

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'), // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'), // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.'
});

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGIN || "http://localhost:3000",
  credentials: true
}));
app.use(morgan('combined'));
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(limiter);

// Health check endpoint
app.get('/health', (_req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// Basic API routes
app.get('/api', (_req, res) => {
  res.json({
    message: 'CI/CD Pipeline Health Dashboard API',
    version: '1.0.0',
    status: 'running'
  });
});

// Organizations routes
app.get('/api/organizations', (_req, res) => {
  res.json({
    organizations: [
      {
        id: '1',
        name: 'Sample Organization',
        slug: 'sample-org',
        description: 'A sample organization for testing purposes'
      }
    ]
  });
});

// Projects routes
app.get('/api/projects', (_req, res) => {
  res.json({
    projects: [
      {
        id: '1',
        name: 'Sample Project',
        platform: 'github',
        external_id: 'owner/repo',
        status: 'active'
      }
    ]
  });
});

// Pipelines routes
app.get('/api/pipelines', (_req, res) => {
  res.json({
    pipelines: [
      {
        id: '1',
        name: 'CI Pipeline',
        status: 'success',
        started_at: new Date(Date.now() - 3600000).toISOString(),
        completed_at: new Date().toISOString(),
        duration: 3600
      }
    ]
  });
});

// Metrics endpoint
app.get('/api/metrics/summary', (_req, res) => {
  res.json({
    total_pipelines: 100,
    successful_pipelines: 85,
    failed_pipelines: 15,
    success_rate: 85.0,
    avg_duration: 1800,
    last_updated: new Date().toISOString()
  });
});

// WebSocket connection handling
io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);

  // Send initial data
  socket.emit('pipeline:status', {
    pipelineId: '1',
    status: 'running',
    timestamp: new Date().toISOString()
  });

  // Handle pipeline status updates
  socket.on('pipeline:status:update', (data) => {
    // Broadcast to all clients
    io.emit('pipeline:status', data);
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });
});

// Error handling middleware
app.use((err: any, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Something went wrong!',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Internal server error'
  });
});

// 404 handler
app.use('*', (_req, res) => {
  res.status(404).json({
    error: 'Route not found',
    path: _req.originalUrl
  });
});

// Start server
server.listen(PORT, () => {
  console.log(`🚀 CI/CD Dashboard Backend running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`🔌 WebSocket server ready`);
});

export default app;
