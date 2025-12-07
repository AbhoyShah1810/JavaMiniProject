<%@ page import="com.logiclab.game.GameValidator" %>
<%@ page import="com.logiclab.db.DBConnection" %>
<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 1. Session Check (Security)
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String username = (String) session.getAttribute("user");
    
    String feedback = "Waiting for command...";
    String statusClass = ""; // For styling success/fail messages
    int currentLevel = 1;
    boolean levelComplete = false;
    
    // Declare variables outside try block for scope visibility
    String gridLayout = ""; 
    String correctAnswer = "";
    String levelDescription = "";
    int gridSize = 5;

    Connection con = null;
    try {
        con = DBConnection.getConnection();

        // 2. DATA: Fetch Current Level (Moved up for Validation)
        PreparedStatement psUser = con.prepareStatement("SELECT current_level_id FROM users WHERE username=?");
        psUser.setString(1, username);
        ResultSet rsUser = psUser.executeQuery();
        if (rsUser.next()) {
            currentLevel = rsUser.getInt(1);
        }
        rsUser.close();
        psUser.close();

        // Fetch Level Layout (Needed for Validation)
        PreparedStatement psLevel = con.prepareStatement("SELECT * FROM levels WHERE level_id=?");
        psLevel.setInt(1, currentLevel);
        ResultSet rsLevel = psLevel.executeQuery();
        
        if (rsLevel.next()) {
            gridLayout = rsLevel.getString("grid_layout") != null ? rsLevel.getString("grid_layout") : "";
            correctAnswer = rsLevel.getString("solution_key") != null ? rsLevel.getString("solution_key") : "";
            levelDescription = rsLevel.getString("description") != null ? rsLevel.getString("description") : "";
            gridSize = rsLevel.getInt("grid_size");
        } else {
            feedback = "Game Over! You beat all levels.";
            statusClass = "color: #00AA00;";
        }
        rsLevel.close();
        psLevel.close();

        // 3. LOGIC: Handle "Run Code" Button
        if (request.getParameter("runCode") != null) {
            String userCode = request.getParameter("codeArea");
            
            if (userCode != null) {
                userCode = userCode.trim();
                
                // Use GameValidator to simulate and check
                boolean isValid = GameValidator.validate(gridLayout, gridSize, userCode);
                
                if (isValid) {
                    // Success: Update Database
                    PreparedStatement psUp = con.prepareStatement("UPDATE users SET current_level_id = current_level_id + 1 WHERE username=?");
                    psUp.setString(1, username);
                    psUp.executeUpdate();
                    psUp.close();
                    con.close();
                    
                    // Redirect immediately to show next level - MUST be before any HTML output
                    response.sendRedirect("game.jsp?levelComplete=true");
                    return;
                } else {
                    feedback = "Oof! Logic Error. Try again.";
                    statusClass = "color: #AA0000;"; // Minecraft Red
                }
            }
        }
        
        // Show success message if level was just completed
        if (request.getParameter("levelComplete") != null) {
            feedback = "Task Complete! Moving to next chunk...";
            statusClass = "color: #00AA00;";
        }
    } catch (SQLException e) {
        feedback = "Database Error: " + e.getMessage();
        statusClass = "color: #AA0000;";
        // Set default values if database fails
        if (gridLayout == null || gridLayout.isEmpty()) {
            gridLayout = "0,0,START; 2,2,GOAL";
            correctAnswer = "moveRight(2);moveDown(2);";
            levelDescription = "Welcome to LogicLab! Move Steve to the goal.";
            gridSize = 5;
        }
    } catch (Exception e) {
        feedback = "Error: " + e.getMessage();
        statusClass = "color: #AA0000;";
        gridLayout = "0,0,START; 2,2,GOAL";
        correctAnswer = "moveRight(2);moveDown(2);";
        levelDescription = "Welcome to LogicLab! Move Steve to the goal.";
        gridSize = 5;
    } finally {
        if (con != null) {
            try {
                con.close();
            } catch (SQLException e) {
                // Ignore
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>LogicLab: Level <%= currentLevel %></title>
    <link rel="stylesheet" href="assets/css/style.css">
    <script src="assets/js/game.js"></script>
</head>
<body>
    <div class="container">
        
        <div class="editor-pane">
            <div style="display:flex; justify-content:space-between; align-items:center;">
                <h2>World <%= currentLevel %></h2>
                <a href="logout.jsp" style="color:#57381C; text-decoration:none;">[Quit Game]</a>
            </div>
            
            <% if (!levelDescription.isEmpty()) { %>
                <p style="color: #3e2723; font-size: 18px; margin: 10px 0;"><%= levelDescription %></p>
            <% } %>
            
            <p<% if (!statusClass.isEmpty()) { %> style="<%= statusClass %>"<% } %>><strong>> <%= feedback %></strong></p>
            
            <form method="POST">
                <input type="hidden" name="correctAnswer" value="<%= correctAnswer %>">
                
                <textarea name="codeArea" placeholder="// Write code to move Steve...&#10;moveRight(3);" required><% 
                    if (request.getParameter("codeArea") != null && request.getParameter("levelComplete") == null) {
                        out.print(request.getParameter("codeArea"));
                    }
                %></textarea>
                <br><br>
                <button type="submit" name="runCode">Craft & Run</button>
                <button type="button" id="resetBtn" style="background-color: #AA0000; margin-left: 10px;">Reset</button>
            </form>
        </div>

        <div class="game-pane">
            <table class="grid">
                <% 
                   // Simple Rendering Logic
                   for(int r=0; r<gridSize; r++) { 
                %>
                <tr>
                    <% for(int c=0; c<gridSize; c++) { 
                        String cellClass = "cell"; 
                    %>
                        <td class="<%= cellClass %>" id="cell-<%=r%>-<%=c%>"></td>
                    <% } %>
                </tr>
                <% } %>
            </table>
            
            <input type="hidden" id="layoutData" value="<%= gridLayout %>">
            <input type="hidden" id="levelId" value="<%= currentLevel %>">
        </div>
    </div>

</body>
</html>

