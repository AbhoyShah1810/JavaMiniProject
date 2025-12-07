#!/bin/bash

# LogicLab Database Setup - Create User and Initialize Database
# This script creates a dedicated MySQL user for LogicLab and sets up the database

echo "=== LogicLab Database Setup ==="
echo ""
echo "This script will:"
echo "  1. Create a MySQL user 'logiclab' with password 'logiclab123'"
echo "  2. Grant privileges on the logiclab database"
echo "  3. Initialize the database with tables and sample data"
echo ""

# Check if MySQL is running
if ! pgrep -x mysqld > /dev/null; then
    echo "ERROR: MySQL is not running!"
    echo "Please start MySQL first."
    exit 1
fi

echo "MySQL is running."
echo ""

# Prompt for MySQL root password
read -sp "Enter MySQL root password: " ROOT_PASSWORD
echo ""

# Create user and database setup SQL
SQL_SETUP=$(cat <<EOF
-- Create user if not exists
CREATE USER IF NOT EXISTS 'logiclab'@'localhost' IDENTIFIED BY 'logiclab123';

-- Grant privileges
GRANT ALL PRIVILEGES ON logiclab.* TO 'logiclab'@'localhost';
FLUSH PRIVILEGES;

-- Create database
CREATE DATABASE IF NOT EXISTS logiclab;
USE logiclab;

-- Table 1: users
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL,
    current_level_id INT DEFAULT 1,
    role VARCHAR(10) DEFAULT 'STUDENT'
);

-- Table 2: levels
CREATE TABLE IF NOT EXISTS levels (
    level_id INT PRIMARY KEY,
    description VARCHAR(255),
    grid_layout TEXT,
    solution_key TEXT,
    grid_size INT DEFAULT 5
);

-- Insert sample admin user
INSERT INTO users (username, password, current_level_id, role) 
VALUES ('admin', 'admin123', 1, 'ADMIN')
ON DUPLICATE KEY UPDATE username = username;

-- Insert sample student user
INSERT INTO users (username, password, current_level_id, role) 
VALUES ('student', 'student123', 1, 'STUDENT')
ON DUPLICATE KEY UPDATE username = username;

-- Insert sample levels
INSERT INTO levels (level_id, description, grid_layout, solution_key, grid_size) 
VALUES 
    (1, 'Welcome to LogicLab! Move Steve to the goal.', '0,0,START; 2,2,GOAL', 'moveRight(2);moveDown(2);', 5),
    (2, 'Avoid the wall! Find the path to the goal.', '0,0,START; 1,1,WALL; 2,2,GOAL', 'moveRight(1);moveDown(2);moveRight(1);', 5),
    (3, 'Navigate through the maze to reach the emerald!', '0,0,START; 0,2,WALL; 1,2,WALL; 2,2,WALL; 4,4,GOAL', 'moveRight(1);moveDown(4);moveRight(3);', 5)
ON DUPLICATE KEY UPDATE level_id = level_id;

-- Verify setup
SELECT 'Database setup complete!' AS Status;
SELECT COUNT(*) AS 'Users Created' FROM users;
SELECT COUNT(*) AS 'Levels Created' FROM levels;
EOF
)

# Execute SQL
echo "$SQL_SETUP" | mysql -u root -p"$ROOT_PASSWORD" 2>&1

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Database setup successful!"
    echo ""
    echo "Credentials for your application:"
    echo "  Username: logiclab"
    echo "  Password: logiclab123"
    echo ""
    echo "Now update src/main/java/com/logiclab/db/DBConnection.java:"
    echo "  DB_USERNAME = \"logiclab\""
    echo "  DB_PASSWORD = \"logiclab123\""
    echo ""
    echo "Test accounts created:"
    echo "  Admin:   username=admin,   password=admin123"
    echo "  Student: username=student, password=student123"
else
    echo ""
    echo "❌ Setup failed. Please check:"
    echo "  1. MySQL root password is correct"
    echo "  2. MySQL is running"
    echo "  3. You have proper permissions"
fi

