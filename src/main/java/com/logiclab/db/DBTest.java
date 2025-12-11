package com.logiclab.db;

import java.sql.Connection;
import java.sql.SQLException;

public class DBTest {
    public static void main(String[] args) {
        System.out.println("Testing Database Connection...");
        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                System.out.println("Connection Successful!");
                System.out.println("Connected to: " + conn.getMetaData().getURL());
            } else {
                System.out.println("Connection Failed! (Returning null)");
            }
        } catch (SQLException e) {
            System.err.println("Connection Failed with Exception:");
            e.printStackTrace();
        }
    }
}
