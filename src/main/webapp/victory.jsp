<%@ page import="com.logiclab.db.DBConnection" %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Security Check
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>LogicLab: Victory!</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <style>
        body {
            background-color: #74C3FF;
            overflow: hidden;
        }

        .victory-container {
            width: 800px;
            background-color: #C6C6C6; /* Stone */
            border: 4px solid #373737;
            box-shadow: 10px 10px 0px rgba(0,0,0,0.2);
            padding: 40px;
            text-align: center;
            position: relative;
            z-index: 10;
        }

        h1 {
            font-family: 'VT323', monospace;
            font-size: 80px;
            color: #52D017; /* Emerald Green */
            text-shadow: 4px 4px 0px #000;
            margin: 0;
            text-transform: uppercase;
        }

        p.subtitle {
            font-size: 30px;
            color: #373737;
            margin-top: 10px;
            margin-bottom: 30px;
        }

        .leaderboard-panel {
            background-color: #F4E4BC; 
            border: 4px solid #57381C; 
            padding: 20px;
            max-height: 300px;
            overflow-y: auto;
            margin-bottom: 30px;
            text-align: left;
        }

        .leaderboard-panel h3 {
            color: #57381C;
            border-bottom: 4px solid #57381C;
            padding-bottom: 10px;
            margin-top: 0;
            margin-bottom: 0;
            background-color: #EACD96;  
        }

        .leaderboard-table {
            width: 100%;
            border-collapse: collapse;
            color: #3e2723;
            font-family: 'VT323', monospace;
            font-size: 24px;
        }

        .leaderboard-table th {
            text-align: left;
            padding: 10px;
            border-bottom: 4px solid #57381C;
            border-right: 2px solid #57381C;
        }

        .leaderboard-table th:last-child {
            border-right: none;
        }

        .leaderboard-table td {
            padding: 8px 10px;
            border-bottom: 1px dashed #57381C;
            border-right: 2px solid #57381C;
            vertical-align: middle;
        }

        .leaderboard-table td:last-child {
            border-right: none;
        }

        .leaderboard-table tr:last-child td {
            border-bottom: none;
        }

        .rank-cell { font-weight: bold; text-align: center; }
        .lvl-cell { font-weight: bold; color: #00AA00; text-align: right; }


        .btn-large {
            display: inline-block;
            background-color: #787878;
            color: #FFF;
            border: 4px solid #000;
            padding: 15px 30px;
            font-family: 'VT323', monospace;
            font-size: 28px;
            text-decoration: none;
            cursor: pointer;
            box-shadow: inset 4px 4px #AAA, inset -4px -4px #444;
            margin: 0 10px;
        }

        .btn-large:hover {
            background-color: #888888;
            transform: translateY(-2px);
        }

        .btn-large:active {
            background-color: #555;
            box-shadow: inset 4px 4px #222;
            transform: translateY(2px);
        }

        canvas {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
            z-index: 5;
        }
    </style>
</head>
<body>

    <canvas id="confetti"></canvas>

    <div class="victory-container">
        <h1>VICTORY!</h1>
        <p class="subtitle">You have conquered the LogicLab!</p>

        <div class="leaderboard-panel">
            <h3>Top Explorers</h3>
            <table class="leaderboard-table">
                <thead>
                    <tr>
                        <th style="width: 15%; text-align: center;">Rank</th>
                        <th style="width: 55%;">Explorer</th>
                        <th style="width: 30%; text-align: right;">Status</th>
                    </tr>
                </thead>
                <tbody>
            <%
                try (Connection con = DBConnection.getConnection()) {
                    String query = "SELECT username, current_level_id FROM users ORDER BY current_level_id DESC LIMIT 10";
                    try (Statement stmt = con.createStatement(); ResultSet rs = stmt.executeQuery(query)) {
                        int rank = 1;
                        while (rs.next()) {
                            String uName = rs.getString("username");
                            int lvl = rs.getInt("current_level_id");
            %>
                            <tr>
                                <td class="rank-cell">#<%= rank++ %></td>
                                <td><%= uName %></td>
                                <td class="lvl-cell"><%= (lvl > 20) ? "ALL CLEARED" : "Lvl " + lvl %></td>
                            </tr>
            <%
                        }
                    }
                } catch (SQLException e) {
            %>
                    <tr>
                        <td colspan="3" style="text-align: center; color: red;">Failed to load leaderboard</td>
                    </tr>
            <%
                }
            %>
                </tbody>
            </table>
        </div>

        <a href="index.jsp" class="btn-large">Play Again</a>
        <a href="logout.jsp" class="btn-large" style="background-color: #AA0000;">Logout</a>
    </div>

    <!-- Reusing the confetti script but maybe tweaking colors closer to game items if desired, but default is fine -->
    <script>
        const canvas = document.getElementById('confetti');
        const ctx = canvas.getContext('2d');
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;

        const particles = [];
        const particleCount = 150;

        // Game Colors: Emerald, Diamond, Gold, Redstone
        const colors = ['#52D017', '#00FFFF', '#FFD700', '#FF0000'];

        class Particle {
            constructor() {
                this.x = Math.random() * canvas.width;
                this.y = Math.random() * canvas.height - canvas.height;
                this.size = Math.random() * 10 + 5; // Bigger, blockier
                this.speedY = Math.random() * 3 + 2;
                this.color = colors[Math.floor(Math.random() * colors.length)];
                this.rotation = 0;
                this.rotationSpeed = Math.random() * 0.2 - 0.1;
            }

            update() {
                this.y += this.speedY;
                if (this.y > canvas.height) {
                    this.y = -20;
                    this.x = Math.random() * canvas.width;
                }
            }

            draw() {
                ctx.save();
                ctx.translate(this.x, this.y);
                ctx.rotate(this.rotation);
                ctx.fillStyle = this.color;
                // Draw Square (Pixel style)
                ctx.fillRect(-this.size / 2, -this.size / 2, this.size, this.size);
                ctx.restore();
            }
        }

        function init() {
            for (let i = 0; i < particleCount; i++) {
                particles.push(new Particle());
            }
        }

        function animate() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            particles.forEach(p => {
                p.update();
                p.draw();
            });
            requestAnimationFrame(animate);
        }

        init();
        animate();
        
        window.addEventListener('resize', () => {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
        });
    </script>
</body>
</html>
