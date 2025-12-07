<%@ page import="com.logiclab.db.DBConnection" %>
<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Check if already logged in - MUST be first, before any output
    if (session.getAttribute("user") != null) {
        String role = (String) session.getAttribute("role");
        if (role != null && "ADMIN".equals(role)) {
            response.sendRedirect("admin.jsp");
            return;
        } else {
            response.sendRedirect("game.jsp");
            return;
        }
    }
    
    String errorMessage = "";
    String successMessage = "";
    String username = "";
    
    // Check for registration success message
    if (request.getParameter("registered") != null) {
        successMessage = "Registration successful! Please login.";
    }
    
    // Handle login form submission
    if (request.getParameter("submit") != null) {
        username = request.getParameter("username");
        String password = request.getParameter("password");
        
        if (username != null && password != null && !username.trim().isEmpty() && !password.trim().isEmpty()) {
            Connection con = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            try {
                con = DBConnection.getConnection();
                ps = con.prepareStatement("SELECT username, role FROM users WHERE username=? AND password=?");
                ps.setString(1, username.trim());
                ps.setString(2, password);
                rs = ps.executeQuery();
                
                if (rs.next()) {
                    // Login successful
                    String userRole = rs.getString("role");
                    session.setAttribute("user", username.trim());
                    session.setAttribute("role", userRole);
                    
                    // Close resources before redirect
                    rs.close();
                    ps.close();
                    con.close();
                    
                    // Redirect based on role - MUST be before any HTML output
                    if (userRole != null && "ADMIN".equals(userRole)) {
                        response.sendRedirect("admin.jsp");
                        return;
                    } else {
                        response.sendRedirect("game.jsp");
                        return;
                    }
                } else {
                    errorMessage = "Invalid username or password!";
                }
            } catch (SQLException e) {
                errorMessage = "Database error: " + e.getMessage();
            } finally {
                // Ensure resources are closed
                try {
                    if (rs != null) rs.close();
                    if (ps != null) ps.close();
                    if (con != null) con.close();
                } catch (SQLException e) {
                    // Ignore
                }
            }
        } else {
            errorMessage = "Please enter both username and password!";
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>LogicLab - Login</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <style>
        .login-container {
            max-width: 500px;
            margin: 100px auto;
            padding: 40px;
            background-color: #C6C6C6;
            border: 4px solid #373737;
            box-shadow: 8px 8px 0px rgba(0,0,0,0.2);
        }
        .login-container h2 {
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
    <div class="login-container">
        <h2>Login to LogicLab</h2>
        
        <% if (!successMessage.isEmpty()) { %>
            <div class="success-message"><strong><%= successMessage %></strong></div>
        <% } %>
        
        <% if (!errorMessage.isEmpty()) { %>
            <div class="error-message"><strong><%= errorMessage %></strong></div>
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
            
            <button type="submit" name="submit">Login</button>
        </form>
        
        <div class="link-container">
            <p>Don't have an account? <a href="register.jsp">Register here</a></p>
            <p><a href="index.jsp">← Back to Home</a></p>
        </div>
    </div>
</body>
</html>

