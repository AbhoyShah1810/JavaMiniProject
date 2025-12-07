-- Clear existing levels
DELETE FROM levels;

-- Levels 1-5: Basic Movement (Stone Theme)
-- 5x5 Grids
INSERT INTO levels (level_id, description, grid_layout, solution_key, grid_size) VALUES 
(1, 'Welcome to LogicLab! Move to the Star.', '0,0,START; 2,2,GOAL', 'moveRight(2);moveDown(2);', 5),
(2, 'Watch out for the wall!', '0,0,START; 1,1,WALL; 2,2,GOAL', 'moveRight(2);moveDown(2);', 5),
(3, 'The Maze Begins.', '0,0,START; 0,1,WALL; 1,1,WALL; 2,1,WALL; 3,1,WALL; 4,4,GOAL', 'moveDown(4);moveRight(4);', 5),
(4, 'Zig-Zag Path.', '0,0,START; 1,1,WALL; 3,1,WALL; 1,3,WALL; 3,3,WALL; 4,4,GOAL', 'moveRight(4);moveDown(4);', 5),
(5, 'Around the Block.', '4,4,START; 2,2,WALL; 2,3,WALL; 3,2,WALL; 3,3,WALL; 0,0,GOAL', 'moveUp(4);moveLeft(4);', 5);

-- Levels 6-10: Hazards (Lava Theme)
-- 6x6 Grids
INSERT INTO levels (level_id, description, grid_layout, solution_key, grid_size) VALUES 
(6, 'The Floor is Lava! Don\'t step on red tiles.', '0,0,START; 1,1,LAVA; 2,2,LAVA; 3,3,LAVA; 4,4,LAVA; 5,5,FLAG', 'moveRight(5);moveDown(5);', 6),
(7, 'Minefield. Tread carefully.', '0,0,START; 0,1,MINE; 2,2,FLAG', 'moveDown(1);moveRight(2);moveDown(1);', 6),
(8, 'Lava Lake.', '0,0,START; 2,0,LAVA; 2,1,LAVA; 2,2,LAVA; 2,4,LAVA; 2,5,LAVA; 5,5,FLAG', 'moveRight(3);moveDown(3);moveRight(2);moveDown(2);', 6),
(9, 'Hidden Danger.', '0,0,START; 1,1,MINE; 3,3,MINE; 5,5,FLAG', 'moveRight(5);moveDown(5);', 6),
(10, 'The Gauntlet.', '0,0,START; 1,0,LAVA; 2,2,MINE; 3,3,LAVA; 4,4,MINE; 5,5,FLAG', 'moveRight(5);moveDown(5);', 6);

-- Levels 11-15: Jumping (Nature Theme)
-- 7x7 Grids
INSERT INTO levels (level_id, description, grid_layout, solution_key, grid_size) VALUES 
(11, 'Learn to Jump! Use jumpRight(2) to hop over bushes.', '0,0,START; 0,1,BUSH; 0,2,GOAL', 'jumpRight(2);', 7),
(12, 'Spike Pit. Jump over it!', '0,0,START; 1,0,SPIKE; 2,0,SPIKE; 3,0,GOAL', 'jumpDown(3);', 7),
(13, 'Wall vs Bush. You can jump bushes, not walls.', '0,0,START; 0,1,WALL; 0,2,BUSH; 0,3,GOAL', 'moveDown(1);moveRight(3);moveUp(1);', 7),
(14, 'Island Hopping.', '0,0,START; 0,1,LAVA; 0,2,LAVA; 0,3,GOAL', 'jumpRight(3);', 7),
(15, 'Obstacle Course.', '0,0,START; 1,0,BUSH; 3,0,SPIKE; 5,0,BUSH; 6,6,GOAL', 'jumpDown(2);jumpDown(2);jumpDown(2);moveRight(6);', 7);

-- Levels 16-20: Enemies (Space Theme)
-- 8x8 Grids
INSERT INTO levels (level_id, description, grid_layout, solution_key, grid_size) VALUES 
(16, 'First Contact. Don\'t let the robot see you!', '0,0,START; 0,7,ENEMY; 7,7,GOAL', 'moveDown(7);moveRight(7);', 8),
(17, 'Patrol Bot. Stay out of line of sight.', '0,0,START; 4,4,ENEMY; 2,2,WALL; 7,7,GOAL', 'moveRight(7);moveDown(7);', 8),
(18, 'Space Station. Walls block vision.', '0,0,START; 0,5,ENEMY; 0,2,WALL; 7,7,GOAL', 'moveDown(7);moveRight(7);', 8),
(19, 'The Chase.', '0,0,START; 1,1,ENEMY; 2,2,ENEMY; 7,7,GOAL', 'moveRight(7);moveDown(7);', 8),
(20, 'Final Frontier. Survive.', '0,0,START; 3,3,ENEMY; 4,4,ENEMY; 5,5,ENEMY; 7,7,GOAL', 'moveRight(7);moveDown(7);', 8);
