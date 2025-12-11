# LogicLab Helper Commands

## 🚀 Sp**One-Liner to Compile & Deploy:**

**macOS / Linux (Zsh/Bash):**
```zsh
# Compile Java files and Deploy to Tomcat
javac -d src/main/webapp/WEB-INF/classes -cp "src/main/webapp/WEB-INF/lib/*" src/main/java/com/logiclab/db/*.java src/main/java/com/logiclab/game/*.java && cp -R src/main/webapp/* /opt/homebrew/Cellar/tomcat/11.0.14/libexec/webapps/LogicLab/ && echo "✅ Deployed Successfully!"
```

**Windows (PowerShell):**
> *Note: Update the Tomcat path (`C:\Program Files\Apache Software Foundation\Tomcat 10.1`) to match your installation.*
```powershell
javac -d src/main/webapp/WEB-INF/classes -cp "src/main/webapp/WEB-INF/lib/*" src/main/java/com/logiclab/db/*.java src/main/java/com/logiclab/game/*.java; Copy-Item -Recurse -Force src/main/webapp/* "C:\Program Files\Apache Software Foundation\Tomcat 10.1\webapps\LogicLab\"; Write-Host "✅ Deployed Successfully!"
```

**Open in Browser:**
[http://localhost:8080/LogicLab/](http://localhost:8080/LogicLab/)

---

## 🗄️ Database Inspection (MySQL)
**Show All Tables:**
```sql
mysql -u logiclab -plogiclab123 -e "SHOW TABLES IN logiclab;"
```

**Dump Users Table:**
```sql
mysql -u logiclab -plogiclab123 -e "SELECT * FROM logiclab.users;"
```

**Dump Levels Table:**
```sql
mysql -u logiclab -plogiclab123 -e "SELECT level_id, description, grid_size FROM logiclab.levels ORDER BY level_id;"
```

**Reset User to Level 1:**
```sql
mysql -u logiclab -plogiclab123 -e "UPDATE logiclab.users SET current_level_id = 1 WHERE username = 'student';"
```

**Cheat to Level 20:**
```sql
mysql -u logiclab -plogiclab123 -e "UPDATE logiclab.users SET current_level_id = 20 WHERE username = 'student';"
```

---

## 🗝️ Level Solutions (Speed Run)
Copy and paste these solutions into the game editor to breeze through levels.

```java
// Level 1
moveRight(2);moveDown(2);

// Level 2
moveRight(2);moveDown(2);

// Level 3
moveDown(4);moveRight(4);

// Level 4
moveRight(4);moveDown(4);

// Level 5
moveUp(4);moveLeft(4);

// Level 6
moveRight(5);moveDown(5);

// Level 7
moveDown(1);moveRight(2);moveDown(1);

// Level 8
moveRight(3);moveDown(3);moveRight(2);moveDown(2);

// Level 9
moveRight(5);moveDown(5);

// Level 10
moveRight(5);moveDown(5);

// Level 11
jumpRight(2);

// Level 12
jumpDown(3);

// Level 13
moveDown(1);moveRight(3);moveUp(1);

// Level 14
jumpRight(3);

// Level 15
jumpDown(2);jumpDown(2);jumpDown(2);moveRight(6);

// Level 16
moveDown(7);moveRight(7);

// Level 17
moveRight(7);moveDown(7);

// Level 18
moveDown(7);moveRight(7);

// Level 19
moveRight(7);moveDown(7);

// Level 20
moveRight(7);moveDown(7);
```




//admin login
admin
admin123