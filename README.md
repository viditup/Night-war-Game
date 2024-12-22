# Night War - A Lua-based Shooting Game

Night War is an action-packed shooting game where you play as a hero, fighting against waves of enemies. Use your skills to dodge obstacles, destroy enemies, and complete missions to increase your level. The goal is to survive and rack up a high score. 

In this game, you'll face different levels with increasing difficulty as you shoot bullets at enemies, avoid colliding with them, and create explosions when you destroy them.

## Features

- **Simple Controls**: Use the arrow keys to move your player and the spacebar to shoot bullets.
- **Dynamic Gameplay**: Enemies spawn randomly, and the difficulty increases as you progress through the game.
- **Mission System**: Complete missions by destroying a certain number of enemies.
- **Explosions**: When enemies are destroyed, they explode in a visually exciting animation.
- **High Score Tracking**: The game keeps track of your high score.
- **Multiple Levels**: The game increases in difficulty with each level, adding more enemies and faster speeds.

## Controls

- **Arrow Keys (Left/Right)**: Move the player horizontally.
- **Spacebar**: Shoot bullets to destroy enemies.
- **Escape**: Quit the game.

## Installation

1. Clone this repository to your local machine:
   ```
   git clone https://github.com/yourusername/night-war.git
   ```

2. Ensure you have [Love2D](https://love2d.org/) installed on your system.

3. Run the game by opening the folder in Love2D:
   ```
   love .
   ```

## Game Flow

1. **Start Screen**: Choose to start the game or quit. The start screen is where you can begin your adventure.
   
2. **Transition Screen**: A brief transition occurs as the background moves down and the gameplay begins.
   
3. **Gameplay**: Destroy enemies, dodge collisions, and try to achieve the highest score possible.
   
4. **Game Over**: When you collide with an enemy, the game ends, and you are shown your final score.

5. **Restart**: After a game over, you can restart the game and try again.

## Game Design

### Backgrounds
The game has two primary background images: 
- A **main background** for the playing area.
- A **transition background** for a smooth transition between screens.

### Player
The player image is a character that moves horizontally and shoots bullets to defeat enemies. The player is positioned at the bottom of the screen and can move freely left and right.

### Enemies
Enemies spawn randomly at the top of the screen and move downward toward the player. When an enemy is hit by a bullet, it is destroyed and an explosion occurs.

### Explosions
When enemies are destroyed, an explosion animation is triggered. This adds a dynamic and exciting visual effect to the game.

### Score
The score increases with each enemy defeated, and the game will increase in difficulty as you reach new levels. The high score is saved to a file for future sessions.

## Images

### Game Start Screen
![Screenshot 2024-12-22 190251](https://github.com/user-attachments/assets/4ef29bf8-9e3d-4975-a302-d16e6fa99640)


### Gameplay
![Screenshot 2024-12-22 190305](https://github.com/user-attachments/assets/99c429e7-2c26-402f-9022-b6215f1029a8)
meplay
![Screenshot 2024-12-22 190448](https://github.com/user-attachments/assets/cfbf7557-4225-4887-a306-08f89668f6af)


### Game Over Screen
![Screenshot 2024-12-22 190343](https://github.com/user-attachments/assets/43148fba-e546-4ef3-9863-a4ee9127a172)


## License

This game is open source and available under the MIT License. Feel free to fork the project and contribute to it.

## Contact

For any questions or inquiries, you can contact me at [viditupadhyay07@gmail.com].

---

### Note:
Please replace the images in the `images/` folder with actual screenshots or renders of your game for a more professional touch. The above readme assumes those images are part of the repository.

