-- Database initialization script
-- This script runs when the PostgreSQL container starts

-- Create the database if it doesn't exist
SELECT 'CREATE DATABASE cicd_dashboard'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'cicd_dashboard')\gexec

-- Connect to the database
\c cicd_dashboard;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create organizations table
CREATE TABLE IF NOT EXISTS organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create users table
CREATE TABLE IF NOT EXISTS users (
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

-- Create projects table
CREATE TABLE IF NOT EXISTS projects (
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

-- Create pipelines table
CREATE TABLE IF NOT EXISTS pipelines (
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

-- Insert sample data
INSERT INTO organizations (name, slug, description) VALUES
('Sample Organization', 'sample-org', 'A sample organization for testing purposes')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO users (organization_id, email, username, first_name, last_name, role) VALUES
(
    (SELECT id FROM organizations WHERE slug = 'sample-org'),
    'admin@example.com',
    'admin',
    'Admin',
    'User',
    'admin'
)
ON CONFLICT (email) DO NOTHING;

INSERT INTO projects (organization_id, name, platform, external_id, description) VALUES
(
    (SELECT id FROM organizations WHERE slug = 'sample-org'),
    'Sample Project',
    'github',
    'owner/repo',
    'A sample GitHub repository for testing'
)
ON CONFLICT (organization_id, external_id) DO NOTHING;

INSERT INTO pipelines (project_id, name, external_id, status, started_at, completed_at, duration) VALUES
(
    (SELECT id FROM projects WHERE external_id = 'owner/repo'),
    'CI Pipeline',
    '12345',
    'success',
    CURRENT_TIMESTAMP - INTERVAL '1 hour',
    CURRENT_TIMESTAMP,
    3600
)
ON CONFLICT (project_id, external_id) DO NOTHING;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_pipelines_project_status ON pipelines(project_id, status);
CREATE INDEX IF NOT EXISTS idx_pipelines_created_at ON pipelines(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_pipelines_status_created ON pipelines(status, created_at DESC);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at trigger to relevant tables
DROP TRIGGER IF EXISTS update_organizations_updated_at ON organizations;
CREATE TRIGGER update_organizations_updated_at BEFORE UPDATE ON organizations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_projects_updated_at ON projects;
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_pipelines_updated_at ON pipelines;
CREATE TRIGGER update_pipelines_updated_at BEFORE UPDATE ON pipelines
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;

-- Print completion message
SELECT 'Database initialization completed successfully!' as message;
