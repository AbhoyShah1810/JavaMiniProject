import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;

public class LevelTransitionTest {

    private static final String BASE_URL = "http://localhost:8082/LogicLab";
    private static String cookie = "";

    public static void main(String[] args) {
        try {
            // 1. Create User via DB (Direct)
            runCommand(
                    "/opt/homebrew/bin/mysql -u logiclab -plogiclab123 -D logiclab -e \"INSERT INTO users (username, password, role, current_level_id) VALUES ('auto_tester', 'pass', 'STUDENT', 1);\"");

            // 2. Login
            login("auto_tester", "pass");

            // 3. Play Levels 1-20
            Map<Integer, String> solutions = new HashMap<>();
            solutions.put(1, "moveRight(2);moveDown(2);");
            solutions.put(2, "moveRight(2);moveDown(2);");
            solutions.put(3, "moveDown(4);moveRight(4);");
            solutions.put(4, "moveRight(4);moveDown(4);");
            solutions.put(5, "moveUp(4);moveLeft(4);");
            solutions.put(6, "moveRight(5);moveDown(5);");
            solutions.put(7, "moveDown(1);moveRight(2);moveDown(1);");
            solutions.put(8, "moveRight(3);moveDown(3);moveRight(2);moveDown(2);");
            solutions.put(9, "moveRight(5);moveDown(5);");
            solutions.put(10, "moveRight(5);moveDown(5);");
            solutions.put(11, "jumpRight(2);");
            solutions.put(12, "jumpDown(3);");
            solutions.put(13, "moveDown(1);moveRight(3);moveUp(1);");
            solutions.put(14, "jumpRight(3);");
            solutions.put(15, "jumpDown(2);jumpDown(2);jumpDown(2);moveRight(6);");
            solutions.put(16, "moveDown(7);moveRight(7);");
            solutions.put(17, "moveRight(7);moveDown(7);");
            solutions.put(18, "moveDown(7);moveRight(7);");
            solutions.put(19, "moveRight(7);moveDown(7);");
            solutions.put(20, "moveRight(7);moveDown(7);");

            for (int level = 1; level <= 20; level++) {
                System.out.println("Testing Level " + level + "...");
                String code = solutions.get(level);

                // Verify current level in DB BEFORE run
                int dbLevel = getDbLevel("auto_tester");
                if (dbLevel != level) {
                    System.err.println("FAILURE: Expected DB Level " + level + " but got " + dbLevel);
                    System.exit(1);
                }

                // Run Code
                boolean success = runLevel(code);
                if (!success) {
                    System.err.println("FAILURE: Level " + level + " submission failed (HTTP error or no redirect).");
                    System.exit(1);
                }

                // Verify DB updated to next level
                int nextDbLevel = getDbLevel("auto_tester");
                if (nextDbLevel != level + 1) {
                    System.err.println("FAILURE: Level " + level + " completed, but DB did not update to " + (level + 1)
                            + ". Stuck at " + nextDbLevel);
                    System.exit(1);
                }

                System.out.println("SUCCESS: Level " + level + " -> " + (level + 1));
            }

            System.out.println("ALL 20 LEVELS PASSED!");

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            runCommand(
                    "/opt/homebrew/bin/mysql -u logiclab -plogiclab123 -D logiclab -e \"DELETE FROM users WHERE username='auto_tester';\"");
        }
    }

    private static void login(String username, String password) throws Exception {
        URL url = new URL(BASE_URL + "/login.jsp");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setInstanceFollowRedirects(false);

        String params = "username=" + username + "&password=" + password + "&submit=Login";
        try (OutputStream os = conn.getOutputStream()) {
            os.write(params.getBytes(StandardCharsets.UTF_8));
        }

        String setCookie = conn.getHeaderField("Set-Cookie");
        if (setCookie != null) {
            cookie = setCookie.split(";")[0];
        }

        int code = conn.getResponseCode();
        if (code != 302) {
            throw new RuntimeException("Login failed, status: " + code);
        }
    }

    private static boolean runLevel(String code) throws Exception {
        URL url = new URL(BASE_URL + "/game.jsp");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setInstanceFollowRedirects(false);
        conn.setRequestProperty("Cookie", cookie);

        String params = "codeArea=" + URLEncoder.encode(code, StandardCharsets.UTF_8) + "&runCode=Craft+Run";
        try (OutputStream os = conn.getOutputStream()) {
            os.write(params.getBytes(StandardCharsets.UTF_8));
        }

        int status = conn.getResponseCode();
        String location = conn.getHeaderField("Location");

        // Expect 302 Redirect to game.jsp?levelComplete=true
        return status == 302 && location != null && location.contains("levelComplete=true");
    }

    private static int getDbLevel(String username) {
        try {
            ProcessBuilder pb = new ProcessBuilder(
                    "/opt/homebrew/bin/mysql", "-u", "logiclab", "-plogiclab123", "-D", "logiclab", "-N", "-e",
                    "SELECT current_level_id FROM users WHERE username='" + username + "'");
            Process p = pb.start();
            BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
            String line = reader.readLine();
            return Integer.parseInt(line.trim());
        } catch (Exception e) {
            throw new RuntimeException("DB Query Failed", e);
        }
    }

    private static void runCommand(String cmd) {
        try {
            String[] args = { "/bin/sh", "-c", cmd };
            Runtime.getRuntime().exec(args).waitFor();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
