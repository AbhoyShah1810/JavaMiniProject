<%@ page import="com.logiclab.db.DBConnection" %>
<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Security: Check if user is logged in and is ADMIN
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String role = (String) session.getAttribute("role");
    if (!"ADMIN".equals(role)) {
        response.sendRedirect("game.jsp");
        return;
    }
    
    String username = (String) session.getAttribute("user");
    String message = "";
    String messageType = ""; // "success" or "error"
    
    Connection con = null;
    PreparedStatement psList = null;
    ResultSet rsList = null;
    
    // User Management Resources
    PreparedStatement psUserList = null;
    ResultSet rsUserList = null;
    
    try {
        con = DBConnection.getConnection();
        
        // --- USER MANAGEMENT LOGIC ---
        
        // Handle USER UPDATE
        if (request.getParameter("update_user") != null) {
            String uId = request.getParameter("user_id");
            String pass = request.getParameter("password");
            String uRole = request.getParameter("role");
            String uLevel = request.getParameter("current_level_id");
            
            if (uId != null) {
                try {
                    PreparedStatement ps = con.prepareStatement("UPDATE users SET password=?, role=?, current_level_id=? WHERE user_id=?");
                    ps.setString(1, pass);
                    ps.setString(2, uRole);
                    ps.setInt(3, Integer.parseInt(uLevel));
                    ps.setInt(4, Integer.parseInt(uId));
                    int rows = ps.executeUpdate();
                    ps.close();
                    if (rows > 0) {
                        message = "User updated successfully!";
                        messageType = "success";
                    } else {
                        message = "Error: User not found!";
                        messageType = "error";
                    }
                } catch (Exception e) {
                    message = "Error updating user: " + e.getMessage();
                    messageType = "error";
                }
            }
        }
        
        // Handle USER DELETE
        if (request.getParameter("delete_user") != null) {
            String uId = request.getParameter("user_id");
             if (uId != null) {
                try {
                    PreparedStatement ps = con.prepareStatement("DELETE FROM users WHERE user_id=?");
                    ps.setInt(1, Integer.parseInt(uId));
                    int rows = ps.executeUpdate();
                    ps.close();
                    if (rows > 0) {
                        message = "User deleted successfully!";
                        messageType = "success";
                    } else {
                        message = "Error: User not found!";
                        messageType = "error";
                    }
                } catch (Exception e) {
                    message = "Error deleting user: " + e.getMessage();
                    messageType = "error";
                }
            }
        }
        
        // Fetch User for Editing
        String editUserId = request.getParameter("edit_user_id");
        if (request.getParameter("user_id") != null && request.getParameter("edit_user") != null) {
            editUserId = request.getParameter("user_id");
        }
        
        String editUsername = "";
        String editPassword = "";
        String editRole = "STUDENT";
        int editCurrentLevel = 1;
        boolean isUserEditMode = false;
        
        if (editUserId != null && !editUserId.isEmpty()) {
            try {
                PreparedStatement ps = con.prepareStatement("SELECT * FROM users WHERE user_id=?");
                ps.setInt(1, Integer.parseInt(editUserId));
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    isUserEditMode = true;
                    editUsername = rs.getString("username");
                    editPassword = rs.getString("password");
                    editRole = rs.getString("role");
                    editCurrentLevel = rs.getInt("current_level_id");
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                // Ignore
            }
        }
        
        // --- LEVEL MANAGEMENT LOGIC (Existing) ---
        
        // Handle CREATE operation
        if (request.getParameter("create") != null) {
            String levelId = request.getParameter("level_id");
            String description = request.getParameter("description");
            String gridLayout = request.getParameter("grid_layout");
            String solutionKey = request.getParameter("solution_key");
            String gridSize = request.getParameter("grid_size");
            
            if (levelId != null && !levelId.trim().isEmpty()) {
                try {
                    PreparedStatement ps = con.prepareStatement("INSERT INTO levels (level_id, description, grid_layout, solution_key, grid_size) VALUES (?, ?, ?, ?, ?)");
                    ps.setInt(1, Integer.parseInt(levelId));
                    ps.setString(2, description != null ? description : "");
                    ps.setString(3, gridLayout != null ? gridLayout : "");
                    ps.setString(4, solutionKey != null ? solutionKey : "");
                    ps.setInt(5, gridSize != null && !gridSize.isEmpty() ? Integer.parseInt(gridSize) : 5);
                    ps.executeUpdate();
                    ps.close();
                    message = "Level created successfully!";
                    messageType = "success";
                } catch (SQLException e) {
                    if (e.getErrorCode() == 1062) { // Duplicate entry
                        message = "Error: Level ID already exists!";
                    } else {
                        message = "Error creating level: " + e.getMessage();
                    }
                    messageType = "error";
                } catch (NumberFormatException e) {
                    message = "Error: Invalid number format!";
                    messageType = "error";
                }
            }
        }
        
        // Handle UPDATE operation
        if (request.getParameter("update") != null) {
            String levelId = request.getParameter("level_id");
            String description = request.getParameter("description");
            String gridLayout = request.getParameter("grid_layout");
            String solutionKey = request.getParameter("solution_key");
            String gridSize = request.getParameter("grid_size");
            
            if (levelId != null && !levelId.trim().isEmpty()) {
                try {
                    PreparedStatement ps = con.prepareStatement("UPDATE levels SET description=?, grid_layout=?, solution_key=?, grid_size=? WHERE level_id=?");
                    ps.setString(1, description != null ? description : "");
                    ps.setString(2, gridLayout != null ? gridLayout : "");
                    ps.setString(3, solutionKey != null ? solutionKey : "");
                    ps.setInt(4, gridSize != null && !gridSize.isEmpty() ? Integer.parseInt(gridSize) : 5);
                    ps.setInt(5, Integer.parseInt(levelId));
                    int rows = ps.executeUpdate();
                    ps.close();
                    if (rows > 0) {
                        message = "Level updated successfully!";
                        messageType = "success";
                    } else {
                        message = "Error: Level not found!";
                        messageType = "error";
                    }
                } catch (SQLException e) {
                    message = "Error updating level: " + e.getMessage();
                    messageType = "error";
                } catch (NumberFormatException e) {
                    message = "Error: Invalid number format!";
                    messageType = "error";
                }
            }
        }
        
        // Handle DELETE operation
        if (request.getParameter("delete") != null) {
            String levelId = request.getParameter("level_id");
            if (levelId != null && !levelId.trim().isEmpty()) {
                try {
                    PreparedStatement ps = con.prepareStatement("DELETE FROM levels WHERE level_id=?");
                    ps.setInt(1, Integer.parseInt(levelId));
                    int rows = ps.executeUpdate();
                    ps.close();
                    if (rows > 0) {
                        message = "Level deleted successfully!";
                        messageType = "success";
                    } else {
                        message = "Error: Level not found!";
                        messageType = "error";
                    }
                } catch (SQLException e) {
                    message = "Error deleting level: " + e.getMessage();
                    messageType = "error";
                } catch (NumberFormatException e) {
                    message = "Error: Invalid number format!";
                    messageType = "error";
                }
            }
        }
        
        // Handle READ operation - Fetch level for editing
        String editLevelId = request.getParameter("edit");
        // FIX: If edit triggered by button (POST), the value is in 'level_id'
        if (request.getParameter("level_id") != null && editLevelId != null) {
            editLevelId = request.getParameter("level_id");
        }
        String editDescription = "";
        String editGridLayout = "";
        String editSolutionKey = "";
        int editGridSize = 5;
        boolean isEditMode = false;
        
        if (editLevelId != null && !editLevelId.trim().isEmpty()) {
            try {
                PreparedStatement ps = con.prepareStatement("SELECT * FROM levels WHERE level_id=?");
                ps.setInt(1, Integer.parseInt(editLevelId));
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    isEditMode = true;
                    editDescription = rs.getString("description") != null ? rs.getString("description") : "";
                    editGridLayout = rs.getString("grid_layout") != null ? rs.getString("grid_layout") : "";
                    editSolutionKey = rs.getString("solution_key") != null ? rs.getString("solution_key") : "";
                    editGridSize = rs.getInt("grid_size");
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                // Ignore
            }
        }
        
        // Fetch all levels for display
        psList = con.prepareStatement("SELECT * FROM levels ORDER BY level_id");
        rsList = psList.executeQuery();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>LogicLab - Admin Panel</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <style>
        .admin-container {
            max-width: 1200px;
            margin: 20px auto;
            padding: 20px;
            background-color: #C6C6C6;
            border: 4px solid #373737;
            box-shadow: 8px 8px 0px rgba(0,0,0,0.2);
        }
        .admin-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .admin-header h2 {
            margin: 0;
            color: #373737;
        }
        .admin-header a {
            color: #57381C;
            text-decoration: none;
        }
        .message {
            padding: 10px;
            margin-bottom: 20px;
            border: 2px solid;
            text-align: center;
        }
        .message.success {
            color: #00AA00;
            background-color: rgba(200, 255, 200, 0.5);
            border-color: #00AA00;
        }
        .message.error {
            color: #AA0000;
            background-color: rgba(255, 200, 200, 0.5);
            border-color: #AA0000;
        }
        .form-section, .list-section {
            margin-bottom: 30px;
            padding: 20px;
            background-color: #F4E4BC;
            border: 2px solid #57381C;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            color: #3e2723;
            margin-bottom: 5px;
            font-size: 18px;
        }
        .form-group input, .form-group textarea {
            width: 100%;
            padding: 8px;
            font-family: 'VT323', monospace;
            font-size: 18px;
            border: 2px solid #57381C;
            background: rgba(255, 255, 255, 0.9);
            box-sizing: border-box;
        }
        .form-group textarea {
            height: 80px;
            resize: vertical;
        }
        .button-group {
            display: flex;
            gap: 10px;
        }
        .button-group button {
            flex: 1;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: rgba(255, 255, 255, 0.9);
        }
        table th, table td {
            padding: 10px;
            border: 1px solid #57381C;
            text-align: left;
        }
        table th {
            background-color: #787878;
            color: #FFF;
        }
        .action-buttons {
            display: flex;
            gap: 5px;
        }
        .action-buttons form {
            display: inline;
        }
        .btn-small {
            padding: 5px 10px;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="admin-container">
        <div class="admin-header">
            <h2>Admin Panel - Level Manager</h2>
            <div>
                <a href="game.jsp">[Play Game]</a> | 
                <a href="logout.jsp">[Logout]</a>
            </div>
        </div>
        
        <% if (!message.isEmpty()) { %>
            <div class="message <%= messageType %>"><strong><%= message %></strong></div>
        <% } %>
        
        <!-- CREATE/UPDATE Form -->
        <div class="form-section">
            <h3><%= isEditMode ? "Edit Level" : "Create New Level" %></h3>
            <form method="POST">
                <div class="form-group">
                    <label for="level_id">Level ID:</label>
                    <input type="number" id="level_id" name="level_id" value="<%= isEditMode ? editLevelId : "" %>" required <%= isEditMode ? "readonly" : "" %>>
                </div>
                
                <div class="form-group">
                    <label for="description">Description:</label>
                    <input type="text" id="description" name="description" value="<%= editDescription %>" required>
                </div>
                
                <div class="form-group">
                    <label for="grid_layout">Grid Layout (format: "row,col,type;row,col,type"):</label>
                    <textarea id="grid_layout" name="grid_layout" required><%= editGridLayout %></textarea>
                    <small style="color: #616161;">Example: 0,0,START; 2,2,GOAL; 1,1,WALL</small>
                </div>
                
                <div class="form-group">
                    <label for="solution_key">Solution Key (exact code to win):</label>
                    <textarea id="solution_key" name="solution_key" required><%= editSolutionKey %></textarea>
                    <small style="color: #616161;">Example: moveRight(2);moveDown(2);</small>
                </div>
                
                <div class="form-group">
                    <label for="grid_size">Grid Size:</label>
                    <input type="number" id="grid_size" name="grid_size" value="<%= editGridSize %>" min="3" max="10" required>
                </div>
                
                <div class="button-group">
                    <% if (isEditMode) { %>
                        <button type="submit" name="update">Update Level</button>
                        <a href="admin.jsp" style="flex: 1; text-align: center; padding: 10px; background-color: #787878; color: #FFF; border: 2px solid #000; text-decoration: none; display: inline-block;">Cancel</a>
                    <% } else { %>
                        <button type="submit" name="create">Create Level</button>
                    <% } %>
                </div>
            </form>
        </div>
        
        <!-- READ - List all levels -->
        <div class="list-section">
            <h3>Existing Levels</h3>
            <table>
                <thead>
                    <tr>
                        <th>Level ID</th>
                        <th>Description</th>
                        <th>Grid Size</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        boolean hasLevels = false;
                        while (rsList.next()) {
                            hasLevels = true;
                            int levelId = rsList.getInt("level_id");
                            String desc = rsList.getString("description");
                            int gSize = rsList.getInt("grid_size");
                    %>
                    <tr>
                        <td><%= levelId %></td>
                        <td><%= desc != null ? desc : "" %></td>
                        <td><%= gSize %>x<%= gSize %></td>
                        <td>
                            <div class="action-buttons">
                                <form method="POST" style="display: inline;">
                                    <input type="hidden" name="level_id" value="<%= levelId %>">
                                    <button type="submit" name="edit" class="btn-small">Edit</button>
                                </form>
                                <form method="POST" style="display: inline;" onsubmit="return confirm('Are you sure you want to delete level <%= levelId %>?');">
                                    <input type="hidden" name="level_id" value="<%= levelId %>">
                                    <button type="submit" name="delete" class="btn-small" style="background-color: #AA0000;">Delete</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <% 
                        }
                        rsList.close();
                        psList.close();
                        if (!hasLevels) {
                    %>
                    <tr>
                        <td colspan="4" style="text-align: center; color: #616161;">No levels found. Create one above!</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <!-- USER MANAGER SECTION -->
        <hr style="border: 4px solid #373737; margin: 40px 0;">
        
        <!-- User Editor Form -->
        <div class="form-section" style="background-color: #E6E6FA;">
            <h3><%= isUserEditMode ? "Edit User: " + editUsername : "Manage Users" %></h3>
            <% if (isUserEditMode) { %>
            <form method="POST">
                <input type="hidden" name="user_id" value="<%= editUserId %>">
                
                <div class="form-group">
                    <label>Username:</label>
                    <input type="text" value="<%= editUsername %>" disabled style="background-color: #ddd;">
                </div>
                
                <div class="form-group">
                    <label for="password">Password:</label>
                    <input type="text" id="password" name="password" value="<%= editPassword %>" required>
                </div>
                
                <div class="form-group">
                    <label for="role">Role:</label>
                    <select id="role" name="role" style="width: 100%; padding: 8px; font-family: 'VT323'; font-size: 18px; border: 2px solid #57381C;">
                        <option value="STUDENT" <%= "STUDENT".equals(editRole) ? "selected" : "" %>>STUDENT</option>
                        <option value="ADMIN" <%= "ADMIN".equals(editRole) ? "selected" : "" %>>ADMIN</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="current_level_id">Current Level:</label>
                    <input type="number" id="current_level_id" name="current_level_id" value="<%= editCurrentLevel %>" required>
                </div>
                
                <div class="button-group">
                    <button type="submit" name="update_user">Update User</button>
                    <a href="admin.jsp" style="flex: 1; text-align: center; padding: 10px; background-color: #787878; color: #FFF; border: 2px solid #000; text-decoration: none; display: inline-block;">Cancel</a>
                </div>
            </form>
            <% } else { %>
                <p>Select a user from the list below to edit.</p>
            <% } %>
        </div>
        
        <!-- User List -->
        <div class="list-section">
            <h3>All Users</h3>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Username</th>
                        <th>Role</th>
                        <th>Level</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        psUserList = con.prepareStatement("SELECT * FROM users ORDER BY user_id");
                        rsUserList = psUserList.executeQuery();
                        boolean hasUsers = false;
                        while (rsUserList.next()) {
                            hasUsers = true;
                            int uId = rsUserList.getInt("user_id");
                            String uName = rsUserList.getString("username");
                            String uRole = rsUserList.getString("role");
                            int uLvl = rsUserList.getInt("current_level_id");
                    %>
                    <tr>
                        <td><%= uId %></td>
                        <td><%= uName %></td>
                        <td><%= uRole %></td>
                        <td><%= uLvl %></td>
                        <td>
                            <div class="action-buttons">
                                <form method="POST" style="display: inline;">
                                    <input type="hidden" name="user_id" value="<%= uId %>">
                                    <button type="submit" name="edit_user" class="btn-small">Edit</button>
                                </form>
                                <% if (!"admin".equals(uName)) { // Prevent deleting main admin %>
                                <form method="POST" style="display: inline;" onsubmit="return confirm('Are you sure you want to delete user <%= uName %>?');">
                                    <input type="hidden" name="user_id" value="<%= uId %>">
                                    <button type="submit" name="delete_user" class="btn-small" style="background-color: #AA0000;">Delete</button>
                                </form>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                    <% 
                        }
                        rsUserList.close();
                        psUserList.close();
                    %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
<%
    } catch (SQLException e) {
        out.println("<div class='message error'>Database Error: " + e.getMessage() + "</div>");
    } finally {
        // Close all resources
        try {
            if (rsList != null) rsList.close();
            if (psList != null) psList.close();
            if (rsUserList != null) rsUserList.close();
            if (psUserList != null) psUserList.close();
            if (con != null) con.close();
        } catch (SQLException e) {
            // Ignore
        }
    }
%>

