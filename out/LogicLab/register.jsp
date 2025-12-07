<%@ page import="com.logiclab.db.DBConnection" %>
<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String errorMessage = "";
    String successMessage = "";
    String username = "";
    
    // Check if already logged in
    if (session.getAttribute("user") != null) {
        response.sendRedirect("game.jsp");
        return;
    }
    
    // Handle registration form submission
    if (request.getParameter("submit") != null) {
        username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        
        if (username != null && password != null && confirmPassword != null) {
            username = username.trim();
            
            if (username.isEmpty() || password.isEmpty()) {
                errorMessage = "Username and password cannot be empty!";
            } else if (!password.equals(confirmPassword)) {
                errorMessage = "Passwords do not match!";
            } else if (password.length() < 3) {
                errorMessage = "Password must be at least 3 characters!";
            } else {
                try {
                    Connection con = DBConnection.getConnection();
                    
                    // Check if username already exists
                    PreparedStatement psCheck = con.prepareStatement("SELECT username FROM users WHERE username=?");
                    psCheck.setString(1, username);
                    ResultSet rsCheck = psCheck.executeQuery();
                    
                    if (rsCheck.next()) {
                        errorMessage = "Username already exists! Please choose another.";
                        rsCheck.close();
                        psCheck.close();
                    } else {
                        // Insert new user
                        PreparedStatement ps = con.prepareStatement("INSERT INTO users (username, password, current_level_id, role) VALUES (?, ?, 1, 'STUDENT')");
                        ps.setString(1, username);
                        ps.setString(2, password);
                        ps.executeUpdate();
                        ps.close();
                        
                        // Close resources before redirect
                        rsCheck.close();
                        psCheck.close();
                        con.close();
                        
                        // Redirect to login page after successful registration
                        response.sendRedirect("login.jsp?registered=true");
                        return;
                    }
                    rsCheck.close();
                    psCheck.close();
                    con.close();
                } catch (SQLException e) {
                    errorMessage = "Database error: " + e.getMessage();
                }
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>LogicLab - Register</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <style>
        .register-container {
            max-width: 500px;
            margin: 50px auto;
            padding: 40px;
            background-color: #C6C6C6;
            border: 4px solid #373737;
            box-shadow: 8px 8px 0px rgba(0,0,0,0.2);
        }
        .register-container h2 {
            color: #373737;
            text-align: center;
            margin-bottom: 30px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            color: #3e2723;
            margin-bottom: 5px;
            font-size: 20px;
        }
        .form-group input {
            width: 100%;
            padding: 10px;
            font-family: 'VT323', monospace;
            font-size: 20px;
            border: 2px solid #57381C;
            background: rgba(255, 255, 255, 0.9);
            box-sizing: border-box;
        }
        .error-message {
            color: #AA0000;
            background-color: rgba(255, 200, 200, 0.5);
            padding: 10px;
            border: 2px solid #AA0000;
            margin-bottom: 20px;
            text-align: center;
        }
        .success-message {
            color: #00AA00;
            background-color: rgba(200, 255, 200, 0.5);
            padding: 10px;
            border: 2px solid #00AA00;
            margin-bottom: 20px;
            text-align: center;
        }
        .link-container {
            text-align: center;
            margin-top: 20px;
        }
        .link-container a {
            color: #57381C;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <div class="register-container">
        <h2>Register for LogicLab</h2>
        
        <% if (!errorMessage.isEmpty()) { %>
            <div class="error-message"><strong><%= errorMessage %></strong></div>
        <% } %>
        
        <% if (!successMessage.isEmpty()) { %>
            <div class="success-message"><strong><%= successMessage %></strong></div>
        <% } %>
        
        <form method="POST">
            <div class="form-group">
                <label for="username">Username:</label>
                <input type="text" id="username" name="username" value="<%= username %>" required>
            </div>
            
            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
            </div>
            
            <div class="form-group">
                <label for="confirmPassword">Confirm Password:</label>
                <input type="password" id="confirmPassword" name="confirmPassword" required>
            </div>
            
            <button type="submit" name="submit">Register</button>
        </form>
        
        <div class="link-container">
            <p>Already have an account? <a href="login.jsp">Login here</a></p>
            <p><a href="index.jsp">← Back to Home</a></p>
        </div>
    </div>
</body>
</html>

