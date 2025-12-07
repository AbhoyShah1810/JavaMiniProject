<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>LogicLab - Gamified Learning Platform</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <style>
        .landing-container {
            max-width: 800px;
            margin: 50px auto;
            padding: 40px;
            background-color: #C6C6C6;
            border: 4px solid #373737;
            box-shadow: 8px 8px 0px rgba(0,0,0,0.2);
            text-align: center;
        }
        .landing-container h1 {
            color: #373737;
            font-size: 48px;
            margin-bottom: 20px;
            text-transform: uppercase;
        }
        .landing-container p {
            color: #3e2723;
            font-size: 24px;
            margin: 20px 0;
        }
        .button-group {
            margin-top: 40px;
            display: flex;
            gap: 20px;
            justify-content: center;
        }
        .btn-large {
            padding: 15px 30px;
            font-size: 24px;
            text-decoration: none;
            display: inline-block;
        }
    </style>
</head>
<body>
    <div class="landing-container">
        <h1>LogicLab</h1>
        <p>Control a virtual robot using simplified code commands</p>
        <p style="font-size: 20px; color: #616161;">Write Code → Compile → Visual Feedback → Level Up</p>
        
        <div class="button-group">
            <a href="login.jsp" class="btn-large" style="background-color: #787878; color: #FFF; border: 2px solid #000; box-shadow: inset 2px 2px #AAA, inset -2px -2px #444;">Login</a>
            <a href="register.jsp" class="btn-large" style="background-color: #787878; color: #FFF; border: 2px solid #000; box-shadow: inset 2px 2px #AAA, inset -2px -2px #444;">Register</a>
        </div>
    </div>
</body>
</html>

