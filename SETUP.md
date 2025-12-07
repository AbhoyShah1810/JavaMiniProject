# LogicLab Setup Guide

This guide will help you configure your development environment for LogicLab before starting development.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Java Development Kit (JDK)** 8 or later
- **Apache Tomcat** 9.x or 10.x
- **MySQL Server** 5.7 or later
- **MySQL JDBC Driver** (mysql-connector-j-8.x.jar)

---

## Step 1: Verify Java Installation

1. Open a terminal/command prompt
2. Run the following commands:

```bash
java -version
javac -version
```

Both commands should display version information. If not, install JDK and set `JAVA_HOME` environment variable.

---

## Step 2: Install and Configure MySQL

### 2.1 Install MySQL

- **macOS**: `brew install mysql` or download from [MySQL Downloads](https://dev.mysql.com/downloads/mysql/)
- **Windows**: Download installer from [MySQL Downloads](https://dev.mysql.com/downloads/mysql/)
- **Linux**: `sudo apt-get install mysql-server` (Ubuntu/Debian) or use your package manager

### 2.2 Start MySQL Service

```bash
# macOS (Homebrew)
brew services start mysql

# Linux
sudo systemctl start mysql

# Windows: Start MySQL service from Services panel
```

### 2.3 Create Database and Tables

**Option A: Run SQL script from command line (Recommended)**

```bash
# Navigate to project directory
cd /path/to/JavaMiniProject

# Run the SQL script (you'll be prompted for MySQL root password)
mysql -u root -p < database/init.sql
```

**Option B: Run SQL script interactively**

1. Log into MySQL:

```bash
mysql -u root -p
```

2. Once connected, run:

```sql
source /path/to/JavaMiniProject/database/init.sql
```

Or copy and paste the contents of `database/init.sql` into your MySQL client.

**Option C: Use the helper script (creates dedicated user)**

```bash
cd /path/to/JavaMiniProject
./database/create_user_and_setup.sh
```

This script will create a dedicated MySQL user 'logiclab' and set up the database automatically.

3. Verify the database was created:

```sql
USE logiclab;
SHOW TABLES;
SELECT * FROM users;
SELECT * FROM levels;
```

You should see:
- `users` table with admin and student accounts
- `levels` table with 3 sample levels

### 2.4 Update Database Credentials

Edit `src/main/java/com/logiclab/db/DBConnection.java` and update:

```java
private static final String DB_USERNAME = "root";  // Your MySQL username
private static final String DB_PASSWORD = "";      // Your MySQL password
```

**Default Test Accounts:**
- Admin: `username: admin`, `password: admin123`
- Student: `username: student`, `password: student123`

---

## Step 3: Install Apache Tomcat

### 3.1 Download Tomcat

Download from [Apache Tomcat Downloads](https://tomcat.apache.org/download-90.cgi)

### 3.2 Extract and Configure

1. Extract Tomcat to a location (e.g., `/usr/local/tomcat` or `C:\Program Files\Apache\Tomcat`)
2. Set `CATALINA_HOME` environment variable:

```bash
# macOS/Linux
export CATALINA_HOME=/path/to/tomcat
export PATH=$PATH:$CATALINA_HOME/bin

# Windows
set CATALINA_HOME=C:\path\to\tomcat
set PATH=%PATH%;%CATALINA_HOME%\bin
```

### 3.3 Start Tomcat

```bash
# macOS/Linux
$CATALINA_HOME/bin/startup.sh

# Windows
%CATALINA_HOME%\bin\startup.bat
```

3. Verify Tomcat is running:
   - Open browser: `http://localhost:8082` (or check your configured port)
   - You should see the Tomcat welcome page

### 3.4 Stop Tomcat (when needed)

```bash
# macOS/Linux
$CATALINA_HOME/bin/shutdown.sh

# Windows
%CATALINA_HOME%\bin\shutdown.bat
```

---

## Step 4: Install MySQL JDBC Driver

### 4.1 Download MySQL Connector/J

1. Download from [MySQL Connector/J Downloads](https://dev.mysql.com/downloads/connector/j/)
2. Extract the JAR file (e.g., `mysql-connector-j-8.0.33.jar`)

### 4.2 Place JAR in Project

Copy the JAR file to:

```
src/main/webapp/WEB-INF/lib/mysql-connector-j-8.x.jar
```

**Important:** The exact filename may vary (e.g., `mysql-connector-j-8.0.33.jar`). Ensure it's in the `WEB-INF/lib/` directory.

---

## Step 5: Deploy Project to Tomcat

### Option A: Manual Deployment

1. Copy the entire `src/main/webapp/` directory to:

```
$CATALINA_HOME/webapps/LogicLab/
```

2. Copy compiled Java classes to:

```
$CATALINA_HOME/webapps/LogicLab/WEB-INF/classes/
```

### Option B: Using IDE (Recommended)

**IntelliJ IDEA:**
1. Open project in IntelliJ
2. File → Project Structure → Artifacts
3. Add Web Application: Exploded
4. Run → Edit Configurations → Add Tomcat Server
5. Deploy artifact and run

**Eclipse:**
1. File → New → Dynamic Web Project
2. Import project files
3. Right-click project → Run As → Run on Server
4. Select Tomcat installation

**VS Code:**
1. Install "Tomcat for Java" extension
2. Configure Tomcat server
3. Right-click project → Run on Tomcat

---

## Step 6: Verify Installation

### 6.1 Test Database Connection

1. Ensure MySQL is running
2. Ensure database `logiclab` exists with tables
3. Test connection by running a simple Java class that uses `DBConnection.getConnection()`

### 6.2 Test Tomcat Deployment

1. Start Tomcat
2. Navigate to: `http://localhost:8082/LogicLab/` (or your configured port)
3. You should see the application (or login page if `index.jsp` redirects)

### 6.3 Test Application Flow

1. **Login as Admin:**
   - URL: `http://localhost:8082/LogicLab/login.jsp` (or your configured port)
   - Username: `admin`
   - Password: `admin123`
   - Should redirect to `admin.jsp` (to be created)

2. **Login as Student:**
   - Username: `student`
   - Password: `student123`
   - Should redirect to `game.jsp` (to be created)

---

## Troubleshooting

### MySQL Connection Issues

- **Error: "Access denied"**
  - Verify username/password in `DBConnection.java`
  - If you forgot your MySQL root password, you can reset it:
    1. Stop MySQL: `sudo /usr/local/mysql/support-files/mysql.server stop`
    2. Start in safe mode: `sudo /usr/local/mysql/bin/mysqld_safe --skip-grant-tables &`
    3. Connect: `mysql -u root`
    4. Run: `ALTER USER 'root'@'localhost' IDENTIFIED BY 'your_new_password';`
    5. Restart MySQL normally
  - Or create a new user: `CREATE USER 'logiclab'@'localhost' IDENTIFIED BY 'password'; GRANT ALL ON logiclab.* TO 'logiclab'@'localhost';`
  - Check MySQL user permissions: `GRANT ALL ON logiclab.* TO 'username'@'localhost';`

- **Error: "Unknown database 'logiclab'"**
  - Run `database/init.sql` script again using: `mysql -u root -p < database/init.sql`
  - Verify database exists: `mysql -u root -p -e "SHOW DATABASES;"`

- **Error: "Bootstrap failed" when starting MySQL via Homebrew**
  - This usually means MySQL was installed via official installer, not Homebrew
  - MySQL is likely already running (check with `ps aux | grep mysql`)
  - Use the MySQL installation's start script: `/usr/local/mysql/support-files/mysql.server start`

### Tomcat Issues

- **Port already in use:**
  - Change port in `$CATALINA_HOME/conf/server.xml` (find `<Connector port="..."`)
  - Or stop the service using that port
  - Note: Your Tomcat is configured on port 8082

- **404 Error on application:**
  - Verify deployment path matches URL
  - Check `web.xml` configuration
  - Verify JSP files are in correct location

### JDBC Driver Issues

- **Error: "ClassNotFoundException: com.mysql.cj.jdbc.Driver"**
  - Verify JAR is in `WEB-INF/lib/`
  - Restart Tomcat after adding JAR
  - Check JAR filename matches driver class version

---

## Next Steps

After completing this setup:

1. ✅ Database is configured and initialized
2. ✅ Tomcat is running
3. ✅ JDBC driver is installed
4. ✅ Project structure is ready

You can now proceed with development:
- Create JSP files (`login.jsp`, `register.jsp`, `game.jsp`, `admin.jsp`, `index.jsp`)
- Create CSS file (`assets/css/style.css`)
- Create JavaScript file (`assets/js/game.js`)
- Add images to `assets/images/`

---

## Quick Reference

| Component | Location/Command |
|-----------|------------------|
| Database | `mysql -u root -p` then `USE logiclab;` |
| Tomcat Start | `$CATALINA_HOME/bin/startup.sh` (macOS/Linux) |
| Tomcat Stop | `$CATALINA_HOME/bin/shutdown.sh` (macOS/Linux) |
| Application URL | `http://localhost:8082/LogicLab/` (or your configured port) |
| JDBC Driver | `src/main/webapp/WEB-INF/lib/mysql-connector-j-8.x.jar` |
| DB Config | `src/main/java/com/logiclab/db/DBConnection.java` |

---

**Need Help?** Refer to `THOUGHTS.md` for detailed architecture and implementation details.

