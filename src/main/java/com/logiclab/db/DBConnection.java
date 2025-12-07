package com.logiclab.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Database Connection Helper Class
 * Provides a centralized way to obtain database connections
 * for the LogicLab application.
 */
public class DBConnection {
    
    // Database configuration - UPDATE THESE VALUES
    // RECOMMENDED: Use a dedicated MySQL user (not root) for better security
    // Run: ./database/create_user_and_setup.sh to create the 'logiclab' user
    private static final String DB_URL = "jdbc:mysql://localhost:3306/logiclab";
    private static final String DB_USERNAME = "logiclab";  // Recommended: dedicated user
    private static final String DB_PASSWORD = "logiclab123";  // Update after running setup script
    private static final String DB_DRIVER = "com.mysql.cj.jdbc.Driver";
    
    /**
     * Static method to get a database connection
     * @return Connection object to the MySQL database
     * @throws SQLException if connection fails
     */
    public static Connection getConnection() throws SQLException {
        try {
            // Load the MySQL JDBC driver
            Class.forName(DB_DRIVER);
            
            // Create and return the connection
            return DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found. Make sure mysql-connector-j-8.x.jar is in WEB-INF/lib/", e);
        }
    }
}

