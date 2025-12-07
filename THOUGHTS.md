# THOUGHTS.md - Project LogicLab (Master Architecture)

## 1. Project Manifesto
**Project Name:** LogicLab
**Concept:** A gamified learning platform where users control a virtual robot using simplified code commands.
**Core Loop:** Write Code -> Compile (Server-side) -> Visual Feedback (Client-side) -> Level Up.
**Architecture:** **JSP Model 1**. Logic is handled directly within JSP files using Scriptlets and Helper Java Classes (JavaBeans). **No Servlets are used.**

---

## 2. Directory Structure (VS Code / Standard Web App)
This structure is critical for the application to run on Apache Tomcat.

```text
LogicLab/
├── src/
│   └── main/
│       └── java/
│           └── com/
│               └── logiclab/
│                   └── db/
│                       └── DBConnection.java  <-- Helper Class for JDBC
├── src/
│   └── main/
│       └── webapp/
│           ├── assets/
│           │   ├── css/
│           │   │   └── style.css          <-- The "Retro Terminal" Theme
│           │   ├── js/
│           │   │   └── game.js            <-- Visual grid animation
│           │   └── images/
│           │       └── robot_sprite.png
│           ├── WEB-INF/
│           │   └── lib/
│           │       └── mysql-connector-j-8.x.jar  <-- JDBC Driver
│           ├── login.jsp
│           ├── register.jsp
│           ├── game.jsp                   <-- The Main Game Engine
│           ├── admin.jsp                  <-- The Level Creator (CRUD)
│           └── index.jsp                  <-- Landing Page

---

## 3. The Database Schema (MySQL)
Database Name: logiclab
##Table 1: users
Stores student credentials and current progress.
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL, -- Storing plain text for simplicity (or hash it)
    current_level_id INT DEFAULT 1,
    role VARCHAR(10) DEFAULT 'STUDENT' -- 'STUDENT' or 'ADMIN'
);
## Table 2: levels
Stores the game configuration. As ID increases, difficulty increases.
CREATE TABLE levels (
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

---

## 4. Technical Implementation Details (JSP Model 1)
A. Database Helper (DBConnection.java)
To avoid writing Class.forName on every single JSP page, we create one Java class to handle the connection.

Location: src/main/java/com/logiclab/db/DBConnection.java

Function: Has a static method getConnection() that returns a java.sql.Connection object.

Why: Meets Unit VI requirement for "Connecting Java Applications to Databases" in a clean, reusable way.

B. Authentication (login.jsp & register.jsp)
Logic:

Top of the file checks request.getParameter("submit").

If true, opens DBConnection.

Runs PreparedStatement (SELECT * FROM users WHERE...).

If match found: session.setAttribute("user", username) and response.sendRedirect("game.jsp").

If fail: Displays error message in HTML.

C. The Game Engine (game.jsp)
This is the most complex file. It handles View and Control.

1. The "Load" Phase (GET Request):

Checks session.getAttribute("user"). If null -> redirect to login.

Fetches user's current_level_id from users table.

Queries levels table for that ID.

HTML Generation: Uses a JSP Loop (<% for %>) to generate the HTML Table (The Grid) based on grid_size. It places classes like .wall, .player, .goal based on grid_layout data.

2. The "Action" Phase (POST Request):

User types code in <textarea name="code"> and submits form to game.jsp.

Scriptlet Logic:

Captures String userCode.

Fetches String solution_key from DB.

Comparison: if (userCode.trim().equals(solution_key))

Success:

UPDATE users SET current_level_id = current_level_id + 1.

Set a flag gameWon = true.

Failure: Set error message "Syntax Error or Robot Crashed".

D. The Content Manager (admin.jsp)
Goal: Satisfy the "Admin Module with CRUD" requirement.

Security: Checks if session.getAttribute("role") equals "ADMIN".

Form: Inputs for Level ID, Description, Grid Layout String, and Answer Key.

Logic: Executes INSERT INTO levels (...) VALUES (...) via JDBC.

---

## 5. The "Minecraft Day" Visual Theme (CSS)
File: src/main/webapp/assets/css/style.css

Design Concept:

Font: 'VT323' or 'Press Start 2P' (Google Fonts) for that pixel look.

Background: Sky Blue (Daytime).

Containers: Styled like "Wooden Planks" or "Book & Quill" UI.

Grid: Looks like a Grass Block landscape.
/* Import Pixel Font */
@import url('[https://fonts.googleapis.com/css2?family=VT323&display=swap](https://fonts.googleapis.com/css2?family=VT323&display=swap)');

body {
    background-color: #74C3FF; /* Minecraft Sky Blue */
    font-family: 'VT323', monospace;
    font-size: 20px;
    margin: 0;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
}

/* The Main Window Frame (Stone UI Style) */
.container {
    width: 90%;
    height: 90%;
    background-color: #C6C6C6; /* Light Gray Stone */
    border: 4px solid #373737; /* Dark Stone Border */
    box-shadow: 8px 8px 0px rgba(0,0,0,0.2);
    display: flex;
    flex-direction: column;
}

/* TOP: The Code Editor (Book & Quill Style) */
.editor-pane {
    flex: 1;
    padding: 20px;
    background-color: #F4E4BC; /* Parchment Paper Color */
    border-bottom: 4px solid #57381C; /* Wood Divider */
    color: #3e2723; /* Ink Color */
}

h2 {
    margin-top: 0;
    color: #373737;
    text-transform: uppercase;
}

/* The Input Box */
textarea {
    width: 100%;
    height: 120px;
    background: rgba(255, 255, 255, 0.5);
    border: 2px solid #57381C;
    font-family: 'VT323', monospace;
    font-size: 24px;
    color: #000;
}

/* Button (Minecraft Button Style) */
button {
    background-color: #787878; /* Stone Button */
    color: #FFF;
    border: 2px solid #000;
    padding: 10px 20px;
    font-family: 'VT323', monospace;
    font-size: 20px;
    cursor: pointer;
    box-shadow: inset 2px 2px #AAA, inset -2px -2px #444; /* 3D Effect */
}

button:active {
    background-color: #555;
    box-shadow: inset 2px 2px #222;
}

/* BOTTOM: The Game Grid (Grass World) */
.game-pane {
    flex: 1.5;
    background-color: #74C3FF; /* Sky continuation */
    display: flex;
    justify-content: center;
    align-items: center;
    overflow: hidden;
}

table.grid {
    border-collapse: collapse;
    background-color: #7CFC00; /* Grass Green */
    border: 4px solid #482708; /* Dirt Brown Border */
}

td.cell {
    width: 50px;
    height: 50px;
    border: 1px solid rgba(0,0,0,0.1); /* Subtle grid lines */
    text-align: center;
    image-rendering: pixelated; /* Keeps images sharp */
}

/* Grid Elements */
.wall {
    background-color: #616161; /* Cobblestone Gray */
    background-image: repeating-linear-gradient(45deg, #555 25%, transparent 25%, transparent 75%, #555 75%, #555), repeating-linear-gradient(45deg, #555 25%, #616161 25%, #616161 75%, #555 75%, #555);
    background-size: 10px 10px;
}

.player {
    background-color: #00AAAA; /* Steve Shirt Teal */
    border: 2px solid #000;
}

.goal {
    background-color: #52D017; /* Emerald Block Green */
    border: 2px solid #FFF;
    animation: glow 1s infinite alternate;
}

@keyframes glow {
    from { box-shadow: 0 0 2px #fff; }
    to { box-shadow: 0 0 10px #fff; }
}

---

## 6. JSP Core Logic (Model 1)
File: src/main/webapp/game.jsp This file handles the logic without any Servlet class.
<%@ page import="com.logiclab.db.DBConnection" %>
<%@ page import="java.sql.*" %>
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

    Connection con = DBConnection.getConnection();

    // 2. LOGIC: Handle "Run Code" Button
    if (request.getParameter("runCode") != null) {
        String userCode = request.getParameter("codeArea").trim();
        String correctCode = request.getParameter("correctAnswer"); // Hidden input
        
        // Basic Logic Check
        if (userCode.equals(correctCode)) {
            // Success: Update Database
            PreparedStatement psUp = con.prepareStatement("UPDATE users SET current_level_id = current_level_id + 1 WHERE username=?");
            psUp.setString(1, username);
            psUp.executeUpdate();
            
            feedback = "Task Complete! Moving to next chunk...";
            statusClass = "color: #00AA00;"; // Minecraft Green
        } else {
            feedback = "Oof! Logic Error. Try again.";
            statusClass = "color: #AA0000;"; // Minecraft Red
        }
    }

    // 3. DATA: Fetch Current Level
    PreparedStatement psUser = con.prepareStatement("SELECT current_level_id FROM users WHERE username=?");
    psUser.setString(1, username);
    ResultSet rsUser = psUser.executeQuery();
    if (rsUser.next()) currentLevel = rsUser.getInt(1);

    // Fetch Level Layout
    PreparedStatement psLevel = con.prepareStatement("SELECT * FROM levels WHERE level_id=?");
    psLevel.setInt(1, currentLevel);
    ResultSet rsLevel = psLevel.executeQuery();
    
    String gridLayout = ""; // e.g. "0,0,START;..."
    String correctAnswer = "";
    int gridSize = 5;
    
    if (rsLevel.next()) {
        gridLayout = rsLevel.getString("grid_layout");
        correctAnswer = rsLevel.getString("solution_key");
        gridSize = rsLevel.getInt("grid_size");
    } else {
        feedback = "Game Over! You beat all levels.";
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>LogicLab: Level <%= currentLevel %></title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <div class="container">
        
        <div class="editor-pane">
            <div style="display:flex; justify-content:space-between;">
                <h2>World <%= currentLevel %></h2>
                <a href="logout.jsp" style="color:#57381C;">[Quit Game]</a>
            </div>
            
            <p style="<%= statusClass %>"><strong>> <%= feedback %></strong></p>
            
            <form method="POST">
                <input type="hidden" name="correctAnswer" value="<%= correctAnswer %>">
                
                <textarea name="codeArea" placeholder="// Write code to move Steve...&#10;moveRight(3);"></textarea>
                <br><br>
                <button type="submit" name="runCode">Craft & Run</button>
            </form>
        </div>

        <div class="game-pane">
            <table class="grid">
                <% 
                   // Simple Rendering Logic (In real project, use JS to parse layout)
                   for(int r=0; r<gridSize; r++) { 
                %>
                <tr>
                    <% for(int c=0; c<gridSize; c++) { 
                        // Determine class based on layout string (simplified logic)
                        String cellClass = "cell"; 
                        // Logic to check if this r,c is a Wall/Goal would go here
                        // For demo purposes, we rely on JS frontend to parse this properly
                    %>
                        <td class="<%= cellClass %>" id="cell-<%=r%>-<%=c%>"></td>
                    <% } %>
                </tr>
                <% } %>
            </table>
            
            <input type="hidden" id="layoutData" value="<%= gridLayout %>">
        </div>
    </div>

    <script>
        const layout = document.getElementById('layoutData').value;
        const items = layout.split(';');
        items.forEach(item => {
            const parts = item.split(',');
            if(parts.length >= 3) {
                const r = parts[0];
                const c = parts[1];
                const type = parts[2]; // START, GOAL, WALL
                
                const cell = document.getElementById('cell-' + r + '-' + c);
                if(cell) {
                    if(type.includes('WALL')) cell.classList.add('wall');
                    if(type.includes('GOAL')) cell.classList.add('goal');
                    if(type.includes('START')) cell.classList.add('player');
                }
            }
        });
    </script>
</body>
</html>

---

## 7. Implementation Steps (Summary)
Setup Environment: Install MySQL and Apache Tomcat.

Database: Run the SQL from Section 3.

Libraries: Copy mysql-connector.jar into src/main/webapp/WEB-INF/lib.

Code: Create the files listed in Section 2.

Run: Open http://localhost:8082/LogicLab/login.jsp (or your configured Tomcat port).

Test: Login as admin, create a level using admin.jsp, then login as a student and play it in game.jsp.