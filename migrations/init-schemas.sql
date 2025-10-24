-- Initialize PostgreSQL Schemas for Microservices
-- Each service has its own schema for data isolation

-- Create auth_schema for Auth Service
CREATE SCHEMA IF NOT EXISTS auth_schema;

-- Create post_schema for Post Service
CREATE SCHEMA IF NOT EXISTS post_schema;

-- Grant permissions (adjust as needed for your setup)
-- GRANT ALL ON SCHEMA auth_schema TO your_user;
-- GRANT ALL ON SCHEMA post_schema TO your_user;

