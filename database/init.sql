-- LogicLab Database Initialization Script
-- Run this script to set up the database schema and initial data

-- Create the database
CREATE DATABASE IF NOT EXISTS logiclab;
USE logiclab;

-- Table 1: users
-- Stores student credentials and current progress
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL, 
    current_level_id INT DEFAULT 1,
    role VARCHAR(10) DEFAULT 'STUDENT' -- 'STUDENT' or 'ADMIN'
);

-- Table 2: levels
-- Stores the game configuration. As ID increases, difficulty increases.
CREATE TABLE IF NOT EXISTS levels (
    level_id INT PRIMARY KEY,
    description VARCHAR(255),
    -- grid_layout format: "row,col,type;row,col,type"
    -- Example: "0,0,START; 2,2,GOAL; 1,1,WALL"
    grid_layout TEXT,
    -- solution_key: The exact string the user must type to win
    -- Example: "moveRight(2);moveDown(2);"
    solution_key TEXT,
    grid_size INT DEFAULT 5 -- e.g., 5 means a 5x5 grid
);

-- Insert sample admin user
-- Username: admin, Password: admin123
INSERT INTO users (username, password, current_level_id, role) 
VALUES ('admin', 'admin123', 1, 'ADMIN')
ON DUPLICATE KEY UPDATE username = username;

-- Insert sample student user
-- Username: student, Password: student123
INSERT INTO users (username, password, current_level_id, role) 
VALUES ('student', 'student123', 1, 'STUDENT')
ON DUPLICATE KEY UPDATE username = username;

-- Insert sample level 1
-- Simple level: Move right 2 steps, then down 2 steps
INSERT INTO levels (level_id, description, grid_layout, solution_key, grid_size) 
VALUES (
    1,
    'Welcome to LogicLab! Move Steve to the goal.',
    '0,0,START; 2,2,GOAL',
    'moveRight(2);moveDown(2);',
    5
)
ON DUPLICATE KEY UPDATE level_id = level_id;

-- Insert sample level 2
-- Level with a wall obstacle
INSERT INTO levels (level_id, description, grid_layout, solution_key, grid_size) 
VALUES (
    2,
    'Avoid the wall! Find the path to the goal.',
    '0,0,START; 1,1,WALL; 2,2,GOAL',
    'moveRight(1);moveDown(2);moveRight(1);',
    5
)
ON DUPLICATE KEY UPDATE level_id = level_id;

-- Insert sample level 3
-- More complex path
INSERT INTO levels (level_id, description, grid_layout, solution_key, grid_size) 
VALUES (
    3,
    'Navigate through the maze to reach the emerald!',
    '0,0,START; 0,2,WALL; 1,2,WALL; 2,2,WALL; 4,4,GOAL',
    'moveRight(1);moveDown(4);moveRight(3);',
    5
)
ON DUPLICATE KEY UPDATE level_id = level_id;

