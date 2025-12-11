package com.logiclab.game;

import java.util.HashSet;
import java.util.Set;

public class GameValidator {
    public static boolean validate(String gridLayout, int gridSize, String userCode) {
        // Parse Layout
        Set<String> walls = new HashSet<>();
        Set<String> hazards = new HashSet<>(); // Lava, Mines, Spikes
        Set<String> bushes = new HashSet<>();

        int startR = 0, startC = 0;
        int goalR = -1, goalC = -1;

        if (gridLayout == null || gridLayout.isEmpty())
            return false;
        
        String[] items = gridLayout.split(";"); // Split by semicolon ";" in the console by the player if trying to enter multiple commands
        for (String item : items) {
            String trimmed = item.trim();
            if (trimmed.isEmpty())
                continue;

            String[] parts = trimmed.split(",");
            if (parts.length >= 3) {
                try {
                    int r = Integer.parseInt(parts[0].trim());
                    int c = Integer.parseInt(parts[1].trim());
                    String type = parts[2].trim().toUpperCase();

                    if (type.contains("WALL"))
                        walls.add(r + "," + c);
                    else if (type.contains("LAVA") || type.contains("MINE") || type.contains("SPIKE"))
                        hazards.add(r + "," + c);
                    else if (type.contains("BUSH"))
                        bushes.add(r + "," + c);
                    else if (type.contains("START")) {
                        startR = r;
                        startC = c;
                    } else if (type.contains("GOAL") || type.contains("FLAG")) {
                        goalR = r;
                        goalC = c;
                    }
                } catch (NumberFormatException e) {
                    // Ignore malformed layout items
                }
            }
        }

        // Parse Code
        if (userCode == null)
            return false;

        String[] lines = userCode.split("[;\\n]+");
        int currR = startR;
        int currC = startC;

        for (String line : lines) {
            line = line.trim();
            if (line.isEmpty() || line.startsWith("//"))
                continue;

            String action = "";
            int steps = 0;

            // Match command
            if (line.startsWith("moveRight"))
                action = "moveRight";
            else if (line.startsWith("moveLeft"))
                action = "moveLeft";
            else if (line.startsWith("moveUp"))
                action = "moveUp";
            else if (line.startsWith("moveDown"))
                action = "moveDown";
            else if (line.startsWith("jumpRight"))
                action = "jumpRight";
            else if (line.startsWith("jumpLeft"))
                action = "jumpLeft";
            else if (line.startsWith("jumpUp"))
                action = "jumpUp";
            else if (line.startsWith("jumpDown"))
                action = "jumpDown";
            else
                continue;

            try {
                int openParen = line.indexOf('(');
                int closeParen = line.indexOf(')');
                if (openParen > -1 && closeParen > openParen) {
                    steps = Integer.parseInt(line.substring(openParen + 1, closeParen).trim());
                }
            } catch (Exception e) {
                continue;
            }

            // Determine direction and type
            int dr = 0, dc = 0;
            boolean isJump = action.startsWith("jump");
            String dirStr = action.replace("jump", "move");

            if (dirStr.equals("moveRight"))
                dc = 1;
            else if (dirStr.equals("moveLeft"))
                dc = -1;
            else if (dirStr.equals("moveDown"))
                dr = 1;
            else if (dirStr.equals("moveUp"))
                dr = -1;

            if (isJump) {
                // Jump Logic
                int tempR = currR;
                int tempC = currC;
                boolean hitWall = false;

                for (int i = 1; i <= steps; i++) {
                    tempR += dr;
                    tempC += dc;

                    // Check bounds
                    if (tempR < 0 || tempR >= gridSize || tempC < 0 || tempC >= gridSize) {
                        hitWall = true;
                        break;
                    }
                    // Check walls (Cannot jump through walls)
                    if (walls.contains(tempR + "," + tempC)) {
                        hitWall = true;
                        break;
                    }
                }

                if (hitWall)
                    return false; // Crash

                // Check landing spot for hazards
                if (hazards.contains(tempR + "," + tempC))
                    return false; // Dead

                // Landing on bush is allowed (it's just an obstacle for walking)

                currR = tempR;
                currC = tempC;

            } else {
                // Move Logic
                for (int i = 0; i < steps; i++) {
                    int nextR = currR + dr;
                    int nextC = currC + dc;

                    // Check bounds
                    if (nextR < 0 || nextR >= gridSize || nextC < 0 || nextC >= gridSize)
                        return false;

                    // Check walls
                    if (walls.contains(nextR + "," + nextC))
                        return false;

                    // Check hazards
                    if (hazards.contains(nextR + "," + nextC))
                        return false;

                    // Check bushes (Cannot walk through)
                    if (bushes.contains(nextR + "," + nextC))
                        return false;

                    currR = nextR;
                    currC = nextC;
                }
            }
        }

        return currR == goalR && currC == goalC;
    }
}
