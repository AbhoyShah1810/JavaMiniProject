# LogicLab Setup & Run Guide

This guide details how to set up, run, and manage the LogicLab application.

## 1. Prerequisites
Ensure you have the following installed:
- **Java Development Kit (JDK)** 17 or later (Verified with JDK 22)
- **Apache Tomcat** 10.x or 11.x (Verified with Tomcat 11.0.14)
- **MySQL Server** 8.0 or later
- **MySQL JDBC Driver** (Included in project: `mysql-connector-j-9.5.0.jar`)

---

## 2. Database Setup

### 2.1 Automated Setup (Recommended)
We provide a script to automatically create the `logiclab` user and initialize the database.

1.  Open a terminal in the project root.
2.  Run the setup script:
    ```bash
    ./database/create_user_and_setup.sh
    ```
3.  Enter your **MySQL root password** when prompted.

### 2.2 Verify Database
Run the following checks to ensure everything is set up:
```bash
# Login as the new logiclab user
mysql -u logiclab -plogiclab123 -e "SHOW TABLES IN logiclab;"
```

---

## 3. Configuration

### 3.1 Database Connection
Ensure `src/main/java/com/logiclab/db/DBConnection.java` is using the dedicated logiclab user:
```java
private static final String DB_USERNAME = "logiclab";
private static final String DB_PASSWORD = "logiclab123";
```

### 3.2 Tomcat Configuration
Ensure your Tomcat is running on Port **8080** (default). If it is on a different port (e.g., 8082), adjust the URLs below accordingly.

---

## 4. Build & Deploy

### 4.1 Compile & Deploy (Manual / CLI)

**macOS / Linux (Zsh/Bash):**
> *Note: Replace `/opt/homebrew/Cellar/tomcat/11.0.14/libexec` with your actual `$CATALINA_HOME`.*
```zsh
javac -d src/main/webapp/WEB-INF/classes -cp "src/main/webapp/WEB-INF/lib/*" src/main/java/com/logiclab/db/*.java src/main/java/com/logiclab/game/*.java && cp -R src/main/webapp/* /opt/homebrew/Cellar/tomcat/11.0.14/libexec/webapps/LogicLab/ && echo "✅ Deployed Successfully!"
```

**Windows (PowerShell):**
> *Note: Replace `C:\Program Files\Apache Software Foundation\Tomcat 10.1` with your actual Tomcat path.*
```powershell
javac -d src/main/webapp/WEB-INF/classes -cp "src/main/webapp/WEB-INF/lib/*" src/main/java/com/logiclab/db/*.java src/main/java/com/logiclab/game/*.java; Copy-Item -Recurse -Force src/main/webapp/* "C:\Program Files\Apache Software Foundation\Tomcat 10.1\webapps\LogicLab\"; Write-Host "✅ Deployed Successfully!"
```

### 4.2 Start Tomcat
```bash
# Start Tomcat
catalina run
# OR
startup.sh
```

---

## 5. Usage

### 5.1 Accessing the Application
- **Main URL:** [http://localhost:8080/LogicLab/](http://localhost:8080/LogicLab/)

### 5.2 Accounts
| Role | Username | Password | Access |
|---|---|---|---|
| **Student** | `student` | `student123` | Can play levels, view victory page. |
| **Admin** | `admin` | `admin123` | Can manage Levels and Users. |

### 5.3 Features

#### **Game Interface**
- Solve coding puzzles using movement commands (`moveRight(2)`, `jumpDown(2)`).
- **Victory Page**: Unlocks after completing Level 20. Displays a custom pixel-art implementation with a leaderboard.

#### **Admin Panel**
- **URL**: [http://localhost:8080/LogicLab/admin.jsp](http://localhost:8080/LogicLab/admin.jsp)
- **Level Manager**: Create, Edit, or Delete game levels.
- **User Manager**:
    - **Edit User**: Change roles, passwords, or current level (e.g., promote a student to Admin).
    - **Delete User**: Remove users from the system (Admin user cannot be deleted).

---

## 6. Project Structure

```
LogicLab/
├── database/               # SQL Scripts & Setup
│   ├── init.sql            # Schema definitions
│   └── create_user_and...  # Auto-setup script
├── Levels/                 # Level Content
│   └── populate_levels.sql # Level data (Levels 1-20)
├── src/
│   └── main/
│       ├── java/           # Java Source Code
│       │   └── com/logiclab/...
│       └── webapp/         # Web Content (JSP, CSS, JS)
│           ├── assets/     # Images, CSS, JS
│           ├── WEB-INF/    # Config & Libs
│           │   ├── classes/# Compiled Output
│           │   └── lib/    # JAR dependencies
│           ├── admin.jsp   # Admin Panel
│           ├── game.jsp    # Game Interface
│           ├── victory.jsp # Victory Screen
│           └── ...
└── SETUP.md                # This file
```
