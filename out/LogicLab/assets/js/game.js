/**
 * LogicLab Game JavaScript
 * Handles visual grid animations and game interactions
 */

// Game State
let currentState = {
    playerRow: 0,
    playerCol: 0,
    gridSize: 5,
    walls: [],
    goal: { r: -1, c: -1 },
    isAnimating: false,
    cumulativeCode: "" // Store history of commands
};

// Initialize game when page loads
document.addEventListener('DOMContentLoaded', function () {
    initializeGrid(true); // true = reset to start
    setupFormHandler();
});

/**
 * Initialize the game grid with layout data
 * @param {boolean} resetPlayer - Whether to reset player to START position
 */
function initializeGrid(resetPlayer = false) {
    const layoutData = document.getElementById('layoutData');
    if (!layoutData || !layoutData.value) return;

    const layout = layoutData.value.trim();
    if (!layout) return;

    // Apply Theme based on Level ID
    const levelIdInput = document.getElementById('levelId');
    if (levelIdInput) {
        const level = parseInt(levelIdInput.value);
        document.body.className = ''; // Reset themes
        if (level >= 6 && level <= 10) {
            document.body.classList.add('theme-lava');
        } else if (level >= 16 && level <= 20) {
            document.body.classList.add('theme-space');
        }
    }

    // Reset walls and enemies
    currentState.walls = [];
    currentState.enemies = [];

    // Determine grid size dynamically from DOM
    const rows = document.querySelectorAll('.grid tr');
    currentState.gridSize = rows.length || 5;

    // Clear entire grid of player class to prevent "ghost" robots
    // Only if we are resetting or if it's the first load
    if (resetPlayer) {
        for (let r = 0; r < currentState.gridSize; r++) {
            for (let c = 0; c < currentState.gridSize; c++) {
                const cell = document.getElementById('cell-' + r + '-' + c);
                if (cell) cell.classList.remove('player');
            }
        }
    }

    // Parse layout string: "row,col,type;row,col,type"
    const items = layout.split(';');

    items.forEach(item => {
        const trimmed = item.trim();
        if (trimmed) {
            const parts = trimmed.split(',');
            if (parts.length >= 3) {
                const row = parseInt(parts[0].trim());
                const col = parseInt(parts[1].trim());
                const type = parts[2].trim().toUpperCase();

                const cell = document.getElementById('cell-' + row + '-' + col);
                if (cell) {
                    // Remove any existing classes (except player if not resetting)
                    if (resetPlayer) {
                        cell.classList.remove('wall', 'goal', 'player', 'lava', 'mine', 'flag', 'bush', 'spike', 'enemy');
                    } else {
                        cell.classList.remove('wall', 'goal', 'lava', 'mine', 'flag', 'bush', 'spike', 'enemy');
                    }

                    // Add appropriate class based on type
                    if (type.includes('WALL')) {
                        cell.classList.add('wall');
                        currentState.walls.push(`${row},${col}`);
                    } else if (type.includes('GOAL')) {
                        cell.classList.add('goal');
                        currentState.goal = { r: row, c: col };
                    } else if (type.includes('FLAG')) {
                        cell.classList.add('flag'); // New Goal Type
                        currentState.goal = { r: row, c: col };
                    } else if (type.includes('START')) {
                        // Only set player to start if requested
                        if (resetPlayer) {
                            cell.classList.add('player');
                            currentState.playerRow = row;
                            currentState.playerCol = col;
                        }
                    } else if (type.includes('LAVA')) {
                        cell.classList.add('lava');
                    } else if (type.includes('MINE')) {
                        cell.classList.add('mine');
                    } else if (type.includes('BUSH')) {
                        cell.classList.add('bush');
                    } else if (type.includes('SPIKE')) {
                        cell.classList.add('spike');
                    } else if (type.includes('ENEMY')) {
                        cell.classList.add('enemy');
                        currentState.enemies.push({ r: row, c: col });
                    }
                }
            }
        }
    });
}

/**
 * Setup form submission handler
 */
function setupFormHandler() {
    // Reset Button Handler
    const resetBtn = document.getElementById('resetBtn');
    if (resetBtn) {
        resetBtn.addEventListener('click', function () {
            currentState.cumulativeCode = "";
            initializeGrid(true);
            const form = document.querySelector('form');
            if (form) form.querySelector('textarea').value = "";
        });
    }

    // Form Submit Handler (Run Code)
    const form = document.querySelector('form');
    if (form) {
        form.addEventListener('submit', function (e) {
            e.preventDefault();

            if (currentState.isAnimating) return;

            const code = form.querySelector('textarea[name="codeArea"]').value;
            runUserCode(code, form);
        });
    }
}

/**
 * Parse and execute user code
 */
async function runUserCode(code, form) {
    currentState.isAnimating = true;

    // Do NOT reset player to start. Continue from current position.
    // initializeGrid(false); 

    // Simple parser for commands
    const commands = [];
    const lines = code.split(/[;\n]+/);

    for (const line of lines) {
        const trimmed = line.trim();
        if (!trimmed || trimmed.startsWith('//')) continue;

        // Match moveRight(n) or jumpRight(n)
        const match = trimmed.match(/^(moveRight|moveLeft|moveUp|moveDown|jumpRight|jumpLeft|jumpUp|jumpDown)\s*\(\s*(\d+)\s*\)/);
        if (match) {
            commands.push({
                action: match[1],
                steps: parseInt(match[2])
            });
        }
    }

    // Execute commands sequentially
    try {
        for (const cmd of commands) {
            await executeCommand(cmd);
        }

        // If successful (no crash), append to history
        currentState.cumulativeCode += code + "\n";

        // Move Enemies after player turn
        moveEnemies();

        // Check win condition
        if (currentState.playerRow === currentState.goal.r &&
            currentState.playerCol === currentState.goal.c) {
            showSuccessAnimation();

            // Update the hidden input with the FULL cumulative code
            const codeArea = form.querySelector('textarea[name="codeArea"]');
            codeArea.value = currentState.cumulativeCode;

            setTimeout(() => {
                form.submit();
            }, 1000);
        } else {
            // Not at goal yet, but successful move.
            form.querySelector('textarea[name="codeArea"]').value = "";
            currentState.isAnimating = false;
        }
    } catch (error) {
        showErrorAnimation(error.message);
        currentState.isAnimating = false;
    }
}

/**
 * Execute a single command
 */
async function executeCommand(cmd) {
    const isJump = cmd.action.startsWith('jump');
    const direction = cmd.action.replace('jump', 'move'); // Normalize to move direction

    const dr = direction === 'moveDown' ? 1 : (direction === 'moveUp' ? -1 : 0);
    const dc = direction === 'moveRight' ? 1 : (direction === 'moveLeft' ? -1 : 0);

    if (isJump) {
        // Jump logic: Move n steps at once, checking walls but ignoring hazards in between
        await jumpPlayer(dr, dc, cmd.steps);
    } else {
        // Move logic: Move 1 step at a time, checking everything
        for (let i = 0; i < cmd.steps; i++) {
            await movePlayer(dr, dc);
        }
    }
}

/**
 * Jump player (ignore hazards in path, land on safe spot)
 */
function jumpPlayer(dr, dc, steps) {
    return new Promise((resolve, reject) => {
        let newR = currentState.playerRow;
        let newC = currentState.playerCol;

        // Check path for walls
        for (let i = 1; i <= steps; i++) {
            const checkR = currentState.playerRow + (dr * i);
            const checkC = currentState.playerCol + (dc * i);

            // Check bounds
            if (checkR < 0 || checkR >= currentState.gridSize || checkC < 0 || checkC >= currentState.gridSize) {
                reject(new Error("Cannot jump out of bounds!"));
                return;
            }

            // Check walls (Cannot jump over walls)
            if (currentState.walls.includes(`${checkR},${checkC}`)) {
                reject(new Error("Bonk! Cannot jump through walls."));
                return;
            }

            // Update final position
            newR = checkR;
            newC = checkC;
        }

        // Check landing spot for hazards
        const cell = document.getElementById(`cell-${newR}-${newC}`);
        if (cell) {
            if (cell.classList.contains('lava')) { reject(new Error("Melted! You jumped into lava.")); return; }
            if (cell.classList.contains('mine')) { reject(new Error("Boom! You jumped on a mine.")); return; }
            if (cell.classList.contains('spike')) { reject(new Error("Ouch! You jumped on spikes.")); return; }
            // Note: Landing on a bush is okay? User said "jump over bush". 
            // Usually landing ON a bush is weird, but let's assume it's safe or maybe you can't land on it?
            // "user can jump over bush and spikes".
            // I'll assume landing on bush is safe for now, or maybe it's an obstacle you can't stand on?
            // For now, I'll treat bush as safe to land on, but primarily an obstacle for walking.
        }

        // Animation (Jump effect)
        animatePlayerMovement(currentState.playerRow, currentState.playerCol, newR, newC);

        // Update State
        currentState.playerRow = newR;
        currentState.playerCol = newC;

        setTimeout(resolve, 500); // Slower animation for jump
    });
}

/**
 * Move player one step (Standard walk)
 */
function movePlayer(dr, dc) {
    return new Promise((resolve, reject) => {
        const newR = currentState.playerRow + dr;
        const newC = currentState.playerCol + dc;

        // Check bounds
        if (newR < 0 || newR >= currentState.gridSize || newC < 0 || newC >= currentState.gridSize) {
            reject(new Error("Crashed into world edge!"));
            return;
        }

        // Check walls
        if (currentState.walls.includes(`${newR},${newC}`)) {
            reject(new Error("Crashed into a wall!"));
            return;
        }

        // Check Hazards (Walking)
        const cell = document.getElementById(`cell-${newR}-${newC}`);
        if (cell) {
            if (cell.classList.contains('lava')) { reject(new Error("Melted! stepped in lava.")); return; }
            if (cell.classList.contains('mine')) { reject(new Error("Boom! Stepped on a mine.")); return; }
            if (cell.classList.contains('spike')) { reject(new Error("Ouch! Stepped on spikes.")); return; }
            if (cell.classList.contains('bush')) { reject(new Error("Blocked! Cannot walk through bushes.")); return; }
        }

        // Update DOM
        animatePlayerMovement(currentState.playerRow, currentState.playerCol, newR, newC);

        // Update State
        currentState.playerRow = newR;
        currentState.playerCol = newC;

        // Wait for animation
        setTimeout(resolve, 300); // 300ms per step
    });
}

/**
 * Move Enemies (Simple AI)
 */
function moveEnemies() {
    if (!currentState.enemies || currentState.enemies.length === 0) return;

    currentState.enemies.forEach((enemy, index) => {
        // Simple AI: Move towards player
        let dr = 0;
        let dc = 0;

        const rowDiff = currentState.playerRow - enemy.r;
        const colDiff = currentState.playerCol - enemy.c;

        // Prioritize larger difference
        if (Math.abs(rowDiff) > Math.abs(colDiff)) {
            dr = rowDiff > 0 ? 1 : -1;
        } else {
            dc = colDiff > 0 ? 1 : -1;
        }

        // Check if move is valid (not wall, not another enemy)
        const newR = enemy.r + dr;
        const newC = enemy.c + dc;

        if (!currentState.walls.includes(`${newR},${newC}`)) {
            // Move enemy in DOM
            const oldCell = document.getElementById(`cell-${enemy.r}-${enemy.c}`);
            const newCell = document.getElementById(`cell-${newR}-${newC}`);

            if (oldCell && newCell) {
                oldCell.classList.remove('enemy');
                newCell.classList.add('enemy');
                enemy.r = newR;
                enemy.c = newC;
            }
        }
    });

    checkEnemySight();
}

/**
 * Check if player is in enemy sight
 */
function checkEnemySight() {
    if (!currentState.enemies) return;

    for (const enemy of currentState.enemies) {
        // Check Row Alignment
        if (enemy.r === currentState.playerRow) {
            // Check for walls in between
            if (!hasWallBetween(enemy.r, enemy.c, currentState.playerCol, true)) {
                showErrorAnimation("ZAP! Enemy saw you!");
                currentState.isAnimating = false;
                throw new Error("Caught by enemy!");
            }
        }

        // Check Col Alignment
        if (enemy.c === currentState.playerCol) {
            // Check for walls in between
            if (!hasWallBetween(enemy.c, enemy.r, currentState.playerRow, false)) {
                showErrorAnimation("ZAP! Enemy saw you!");
                currentState.isAnimating = false;
                throw new Error("Caught by enemy!");
            }
        }

        // Check Collision
        if (enemy.r === currentState.playerRow && enemy.c === currentState.playerCol) {
            showErrorAnimation("CRUNCH! Enemy caught you!");
            currentState.isAnimating = false;
            throw new Error("Caught by enemy!");
        }
    }
}

function hasWallBetween(fixed, start, end, isRowFixed) {
    const min = Math.min(start, end);
    const max = Math.max(start, end);

    for (let i = min + 1; i < max; i++) {
        const checkR = isRowFixed ? fixed : i;
        const checkC = isRowFixed ? i : fixed;
        if (currentState.walls.includes(`${checkR},${checkC}`)) return true;
    }
    return false;
}

/**
 * Animate player movement
 */
function animatePlayerMovement(fromRow, fromCol, toRow, toCol) {
    const fromCell = document.getElementById('cell-' + fromRow + '-' + fromCol);
    const toCell = document.getElementById('cell-' + toRow + '-' + toCol);

    if (fromCell && toCell) {
        fromCell.classList.remove('player');
        toCell.classList.add('player');
    }
}

/**
 * Show success animation
 */
function showSuccessAnimation() {
    const goalCell = document.querySelector('.goal');
    if (goalCell) {
        goalCell.style.backgroundColor = '#00FF00';
        goalCell.style.boxShadow = '0 0 20px #00FF00';
    }
}

/**
 * Show error animation
 */
function showErrorAnimation(msg) {
    const playerCell = document.querySelector('.player');
    if (playerCell) {
        playerCell.style.backgroundColor = '#FF0000';
        setTimeout(() => {
            playerCell.style.backgroundColor = '';
        }, 500);
    }

    // Update feedback text
    const feedback = document.querySelector('p strong');
    if (feedback) {
        feedback.innerText = "> Error: " + msg;
        feedback.parentElement.style.color = '#AA0000';
    }
}

// Add shake animation for errors
const style = document.createElement('style');
style.textContent = `
    @keyframes shake {
        0%, 100% { transform: translateX(0); }
        25% { transform: translateX(-5px); }
        75% { transform: translateX(5px); }
    }
`;
document.head.appendChild(style);

