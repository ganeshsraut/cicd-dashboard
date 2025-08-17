// Common types used throughout the application

export interface User {
  id: string;
  email: string;
  username: string;
  first_name?: string;
  last_name?: string;
  role: 'admin' | 'manager' | 'developer' | 'viewer';
  organization_id: string;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface Organization {
  id: string;
  name: string;
  slug: string;
  description?: string;
  settings: Record<string, any>;
  created_at: Date;
  updated_at: Date;
}

export interface Project {
  id: string;
  organization_id: string;
  name: string;
  description?: string;
  platform: 'github' | 'jenkins' | 'gitlab' | 'azure-devops';
  external_id: string;
  external_url?: string;
  config: Record<string, any>;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface Pipeline {
  id: string;
  project_id: string;
  name: string;
  external_id: string;
  branch?: string;
  status: 'pending' | 'running' | 'success' | 'failure' | 'cancelled' | 'skipped';
  started_at?: Date;
  completed_at?: Date;
  duration?: number; // in seconds
  commit_hash?: string;
  commit_message?: string;
  author_name?: string;
  author_email?: string;
  metadata: Record<string, any>;
  created_at: Date;
  updated_at: Date;
}

export interface PipelineLog {
  id: string;
  pipeline_id: string;
  level: 'debug' | 'info' | 'warning' | 'error';
  message: string;
  timestamp: Date;
  metadata: Record<string, any>;
}

export interface Alert {
  id: string;
  project_id: string;
  name: string;
  description?: string;
  condition: Record<string, any>;
  channels: string[]; // ['slack', 'email']
  is_active: boolean;
  created_by?: string;
  created_at: Date;
  updated_at: Date;
}

export interface AlertHistory {
  id: string;
  alert_id: string;
  pipeline_id: string;
  status: 'triggered' | 'resolved' | 'acknowledged';
  message?: string;
  triggered_at: Date;
  resolved_at?: Date;
  acknowledged_by?: string;
  acknowledged_at?: Date;
  notification_sent: boolean;
  notification_channels: string[];
}

export interface WebhookEvent {
  id: string;
  project_id: string;
  event_type: string;
  payload: Record<string, any>;
  processed: boolean;
  processed_at?: Date;
  created_at: Date;
}

export interface Metrics {
  id: string;
  organization_id: string;
  project_id?: string;
  metric_type: string;
  metric_value: number;
  metric_unit?: string;
  tags: Record<string, any>;
  recorded_at: Date;
}

// API Response types
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    total_pages: number;
  };
}

// WebSocket event types
export interface WebSocketEvent {
  type: string;
  data: any;
  timestamp: Date;
}

export interface PipelineStatusEvent {
  pipelineId: string;
  status: string;
  timestamp: Date;
}

export interface PipelineLogEvent {
  pipelineId: string;
  level: string;
  message: string;
  timestamp: Date;
}

export interface AlertEvent {
  alertId: string;
  pipelineId: string;
  message: string;
  timestamp: Date;
}

// Environment configuration
export interface Config {
  port: number;
  nodeEnv: string;
  databaseUrl: string;
  redisUrl: string;
  jwtSecret: string;
  sessionSecret: string;
  corsOrigin: string;
  githubToken?: string;
  jenkinsUrl?: string;
  jenkinsUsername?: string;
  jenkinsApiToken?: string;
  slackWebhookUrl?: string;
  smtpHost?: string;
  smtpPort?: number;
  smtpUser?: string;
  smtpPass?: string;
  smtpFrom?: string;
}
