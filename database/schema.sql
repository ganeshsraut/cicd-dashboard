-- CI/CD Dashboard Database Schema
-- PostgreSQL 13+ compatible

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Organizations table
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    avatar_url TEXT,
    role VARCHAR(50) DEFAULT 'developer' CHECK (role IN ('admin', 'manager', 'developer', 'viewer')),
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Projects table
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    platform VARCHAR(50) NOT NULL CHECK (platform IN ('github', 'jenkins', 'gitlab', 'azure-devops')),
    external_id VARCHAR(255) NOT NULL,
    external_url TEXT,
    config JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(organization_id, external_id)
);

-- Pipelines table
CREATE TABLE pipelines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    external_id VARCHAR(255) NOT NULL,
    branch VARCHAR(255),
    status VARCHAR(50) NOT NULL CHECK (status IN ('pending', 'running', 'success', 'failure', 'cancelled', 'skipped')),
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    duration INTEGER, -- in seconds
    commit_hash VARCHAR(40),
    commit_message TEXT,
    author_name VARCHAR(255),
    author_email VARCHAR(255),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(project_id, external_id)
);

-- Pipeline logs table
CREATE TABLE pipeline_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pipeline_id UUID REFERENCES pipelines(id) ON DELETE CASCADE,
    level VARCHAR(20) NOT NULL CHECK (level IN ('debug', 'info', 'warning', 'error')),
    message TEXT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

-- Alerts table
CREATE TABLE alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    condition JSONB NOT NULL,
    channels JSONB NOT NULL, -- ['slack', 'email']
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Alert history table
CREATE TABLE alert_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    alert_id UUID REFERENCES alerts(id) ON DELETE CASCADE,
    pipeline_id UUID REFERENCES pipelines(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL CHECK (status IN ('triggered', 'resolved', 'acknowledged')),
    message TEXT,
    triggered_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP WITH TIME ZONE,
    acknowledged_by UUID REFERENCES users(id),
    acknowledged_at TIMESTAMP WITH TIME ZONE,
    notification_sent BOOLEAN DEFAULT false,
    notification_channels JSONB DEFAULT '[]'
);

-- Webhook events table
CREATE TABLE webhook_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    event_type VARCHAR(100) NOT NULL,
    payload JSONB NOT NULL,
    processed BOOLEAN DEFAULT false,
    processed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Metrics table for aggregated data
CREATE TABLE metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    metric_type VARCHAR(100) NOT NULL,
    metric_value DECIMAL(10, 4) NOT NULL,
    metric_unit VARCHAR(50),
    tags JSONB DEFAULT '{}',
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX idx_pipelines_project_status ON pipelines(project_id, status);
CREATE INDEX idx_pipelines_created_at ON pipelines(created_at DESC);
CREATE INDEX idx_pipelines_status_created ON pipelines(status, created_at DESC);
CREATE INDEX idx_pipelines_external_id ON pipelines(external_id);

CREATE INDEX idx_pipeline_logs_pipeline_timestamp ON pipeline_logs(pipeline_id, timestamp DESC);
CREATE INDEX idx_pipeline_logs_level_timestamp ON pipeline_logs(level, timestamp DESC);

CREATE INDEX idx_alerts_project_active ON alerts(project_id, is_active);
CREATE INDEX idx_alerts_created_by ON alerts(created_by);

CREATE INDEX idx_alert_history_alert_status ON alert_history(alert_id, status);
CREATE INDEX idx_alert_history_triggered_at ON alert_history(triggered_at DESC);

CREATE INDEX idx_webhook_events_project_processed ON webhook_events(project_id, processed);
CREATE INDEX idx_webhook_events_created_at ON webhook_events(created_at DESC);

CREATE INDEX idx_metrics_org_project_type ON metrics(organization_id, project_id, metric_type);
CREATE INDEX idx_metrics_recorded_at ON metrics(recorded_at DESC);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at trigger to relevant tables
CREATE TRIGGER update_organizations_updated_at BEFORE UPDATE ON organizations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pipelines_updated_at BEFORE UPDATE ON pipelines
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_alerts_updated_at BEFORE UPDATE ON alerts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create functions for common operations
CREATE OR REPLACE FUNCTION get_pipeline_stats(
    p_project_id UUID,
    p_days INTEGER DEFAULT 30
)
RETURNS TABLE (
    total_pipelines BIGINT,
    successful_pipelines BIGINT,
    failed_pipelines BIGINT,
    success_rate DECIMAL(5,2),
    avg_duration DECIMAL(10,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*)::BIGINT as total_pipelines,
        COUNT(*) FILTER (WHERE status = 'success')::BIGINT as successful_pipelines,
        COUNT(*) FILTER (WHERE status = 'failure')::BIGINT as failed_pipelines,
        ROUND(
            (COUNT(*) FILTER (WHERE status = 'success')::DECIMAL / COUNT(*)::DECIMAL) * 100, 2
        ) as success_rate,
        ROUND(AVG(duration), 2) as avg_duration
    FROM pipelines 
    WHERE project_id = p_project_id 
    AND created_at >= CURRENT_TIMESTAMP - INTERVAL '1 day' * p_days;
END;
$$ LANGUAGE plpgsql;

-- Create views for common queries
CREATE VIEW pipeline_summary AS
SELECT 
    p.id,
    p.name,
    p.status,
    p.started_at,
    p.completed_at,
    p.duration,
    p.commit_hash,
    p.commit_message,
    p.author_name,
    pr.name as project_name,
    pr.platform,
    o.name as organization_name
FROM pipelines p
JOIN projects pr ON p.project_id = pr.id
JOIN organizations o ON pr.organization_id = o.id;

-- Insert sample data for testing
INSERT INTO organizations (name, slug, description) VALUES
('Sample Organization', 'sample-org', 'A sample organization for testing purposes');

INSERT INTO users (organization_id, email, username, first_name, last_name, role) VALUES
(
    (SELECT id FROM organizations WHERE slug = 'sample-org'),
    'admin@example.com',
    'admin',
    'Admin',
    'User',
    'admin'
);

-- Create a function to clean up old data
CREATE OR REPLACE FUNCTION cleanup_old_data(p_days INTEGER DEFAULT 90)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    -- Delete old pipeline logs
    DELETE FROM pipeline_logs 
    WHERE timestamp < CURRENT_TIMESTAMP - INTERVAL '1 day' * p_days;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    -- Delete old webhook events
    DELETE FROM webhook_events 
    WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '1 day' * p_days;
    
    GET DIAGNOSTICS deleted_count = deleted_count + ROW_COUNT;
    
    -- Delete old metrics (keep only last 30 days)
    DELETE FROM metrics 
    WHERE recorded_at < CURRENT_TIMESTAMP - INTERVAL '1 day' * 30;
    
    GET DIAGNOSTICS deleted_count = deleted_count + ROW_COUNT;
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;
