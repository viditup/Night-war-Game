local player = {}
local bullets = {}
local enemies = {}
local explosions = {}
local gameWidth = 800
local gameHeight = 600

local gameOver = false
local score = 0
local highScore = 0
local explosionImage
local background
local background2
local backgroundY = 0
local enemySpawnTimer = 0
local enemySpawnInterval = 2
local bulletSound 
local explosionSound 
local gameState = "start"
local startButton
local quitButton
local restartButton
local startButtonWidth
local startButtonHeight
local startButtonScaleX
local startButtonScaleY
local quitButtonWidth
local quitButtonHeight
local quitButtonScaleX
local quitButtonScaleY
local restartButtonWidth
local restartButtonHeight
local restartButtonScaleX
local restartButtonScaleY
local titleFont 
local readyFont 
local scoreFont 
local gameOverImage

local highScoreFile = "highscore.txt"

-- Add target and levels
local target = {x = 0, y = 0, radius = 30, color = {0, 1, 0}} 
local level = 1
local bulletSpeed = 500
local enemySpeed = 200
local missionDescription = "Destroy 10 enemies"
local enemiesToDestroy = 10
local enemiesDestroyed = 0

-- Bullet options
local bulletType = "normal"  -- "normal", "fast", or "large"

-- Adjust image size function
function adjustImageSize(imagePath, newWidth, newHeight)
    local image = love.graphics.newImage(imagePath)
    if not image then
        print("Error: Could not load image " .. imagePath)
        return nil
    end
    local canvas = love.graphics.newCanvas(newWidth, newHeight)
    love.graphics.setCanvas(canvas)
    love.graphics.draw(image, 0, 0, 0, newWidth / image:getWidth(), newHeight / image:getHeight())
    love.graphics.setCanvas()
    return canvas
end

-- Load high score from file
function loadHighScore()
    if love.filesystem.getInfo(highScoreFile) then
        local contents = love.filesystem.read(highScoreFile)
        if contents then
            highScore = tonumber(contents) or 1000
        end
    else
        highScore = 1000
        saveHighScore() 
    end
end

-- Save high score to file
function saveHighScore()
    love.filesystem.write(highScoreFile, tostring(highScore))
end

-- Image loading function with fallback
function loadImage(imagePath)
    if love.filesystem.getInfo(imagePath) then
        return love.graphics.newImage(imagePath)
    else
        print("Error: Could not load image " .. imagePath)
        return nil
    end
end

function love.load()
    love.window.setTitle("Night War")
    love.window.setMode(gameWidth, gameHeight, {
        resizable = false,
        vsync = true,
        minwidth = gameWidth,
        minheight = gameHeight
    })

    loadHighScore()

    -- Load background images
    background = loadImage("font.jpg")
    background2 = loadImage("background.jpg")

    -- Load button images
    startButton = loadImage("startgame.png")
    quitButton = loadImage("quitgame.png")
    restartButton = loadImage("restart.png")

    -- Load game over image
    gameOverImage = loadImage("gameover.png")

    -- Load player image and size initialization
    player.image = adjustImageSize("player.png", 50, 80)
    if player.image then
        player.width = player.image:getWidth()
        player.height = player.image:getHeight()
    end

    -- Enemy size and image
    enemyWidth = 30
    enemyHeight = 40
    enemyImage = adjustImageSize("enemy.png", enemyWidth, enemyHeight)

    -- Explosion image
    explosionImage = adjustImageSize("explosion.png", 60, 90)

    -- Button scaling
    startButtonWidth = 150
    startButtonHeight = 75
    startButtonScaleX = startButtonWidth / startButton:getWidth()
    startButtonScaleY = startButtonHeight / startButton:getHeight()

    quitButtonWidth = 150
    quitButtonHeight = 75
    quitButtonScaleX = quitButtonWidth / quitButton:getWidth()
    quitButtonScaleY = quitButtonHeight / quitButton:getHeight()

    restartButtonWidth = 150
    restartButtonHeight = 75
    restartButtonScaleX = restartButtonWidth / restartButton:getWidth()
    restartButtonScaleY = restartButtonHeight / restartButton:getHeight()

    -- Fonts
    titleFont = love.graphics.newFont(50)
    readyFont = love.graphics.newFont(25)
    scoreFont = love.graphics.newFont(30)

    -- Initialize player properties
    player.x = gameWidth / 2
    player.y = gameHeight - 50
    player.speed = 300
    player.color = {1, 0, 0}

    -- Sounds
    bulletSound = love.audio.newSource("sound.mp3", "static")
    explosionSound = love.audio.newSource("explosion.mp3", "static")

    -- Game state
    gameState = "start"
    backgroundY = 0
    enemySpawnTimer = 0
    enemies = {}
    bullets = {}
    explosions = {}
    score = 0
    highScore = 0
    gameOver = false
end

function spawnEnemy()
    local enemy = {}
    enemy.x = math.random(50, gameWidth - 50)
    enemy.y = -30
    enemy.speed = enemySpeed
    enemy.image = enemyImage
    if enemy.image then
        enemy.width = enemy.image:getWidth()
        enemy.height = enemy.image:getHeight()
    end
    table.insert(enemies, enemy)
end

function checkCollision(a, b)
    if not a.width or not b.width then return false end  -- Check if width is nil to prevent errors
    return a.x - a.width / 2 < b.x + b.width / 2 and
           a.x + a.width / 2 > b.x - b.width / 2 and
           a.y - a.height / 2 < b.y + b.height / 2 and
           a.y + a.height / 2 > b.y - b.height / 2
end

function increaseDifficulty()
    level = level + 1
    missionDescription = "Destroy " .. (enemiesToDestroy + 5) .. " enemies"
    enemiesToDestroy = enemiesToDestroy + 5
    enemySpeed = enemySpeed + 50
    enemySpawnInterval = enemySpawnInterval - 0.2
end

function love.update(dt)
    if gameState == "start" then
        return
    end

    if gameState == "transition" then
        backgroundY = backgroundY + 200 * dt
        if backgroundY >= gameHeight then
            backgroundY = 0
            gameState = "play"
        end
        return
    end

    if gameOver then
        return
    end

    -- Update player position based on input
    if love.keyboard.isDown("left") then
        player.x = player.x - player.speed * dt
    elseif love.keyboard.isDown("right") then
        player.x = player.x + player.speed * dt
    end

    -- Constrain player within window bounds
    if player.x < player.width / 2 then
        player.x = player.width / 2
    elseif player.x > gameWidth - player.width / 2 then
        player.x = gameWidth - player.width / 2
    end

    -- Update enemy spawn timer and spawn enemies
    enemySpawnTimer = enemySpawnTimer + dt
    if enemySpawnTimer >= enemySpawnInterval then
        spawnEnemy()
        enemySpawnTimer = 0
    end

    -- Update enemy positions
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        enemy.y = enemy.y + enemy.speed * dt

        if checkCollision(player, enemy) then
            gameOver = true
            createExplosion(player.x, player.y)
            if score > highScore then
                highScore = score
                saveHighScore() 
            end
            return
        end

        if enemy.y > gameHeight then
            table.remove(enemies, i)
        end
    end

    -- Update bullet positions
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        bullet.y = bullet.y - bullet.speed * dt

        if bullet.y < 0 then
            table.remove(bullets, i)
        end

        for j = #enemies, 1, -1 do
            local enemy = enemies[j]
            if checkCollision(bullet, enemy) then
                love.audio.play(bulletSound)
                createExplosion(enemy.x, enemy.y)
                table.remove(bullets, i)
                table.remove(enemies, j)
                score = score + 1
                enemiesDestroyed = enemiesDestroyed + 1
                if enemiesDestroyed >= enemiesToDestroy then
                    increaseDifficulty()
                    enemiesDestroyed = 0
                end
                break
            end
        end
    end

    -- Update explosion animations
    for i = #explosions, 1, -1 do
        local explosion = explosions[i]
        explosion.timer = explosion.timer - dt
        if explosion.timer <= 0 then
            table.remove(explosions, i)
        end
    end
end

function love.draw()
    if gameState == "start" then
        love.graphics.draw(background, 0, 0)
        love.graphics.setFont(titleFont)
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("NIGHT WAR", 0, 160, gameWidth, "center")

        local buttonX = (gameWidth - startButtonWidth) / 2
        local buttonY = (gameHeight - startButtonHeight) / 2
        love.graphics.draw(startButton, buttonX, buttonY, 0, startButtonScaleX, startButtonScaleY)

        local quitButtonX = (gameWidth - quitButtonWidth) / 2
        local quitButtonY = buttonY + startButtonHeight + 20
        love.graphics.draw(quitButton, quitButtonX, quitButtonY, 0, quitButtonScaleX, quitButtonScaleY)
    elseif gameState == "transition" then
        love.graphics.draw(background, 0, backgroundY)
        love.graphics.draw(background2, 0, backgroundY - gameHeight)
    elseif gameOver then
        if gameOverImage then
            love.graphics.draw(gameOverImage, 0, 0)
        end
        love.graphics.setFont(scoreFont)
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("Score: " .. score, 0, gameHeight - 100, gameWidth, "center")

        local buttonX = (gameWidth - restartButtonWidth) / 2
        local buttonY = (gameHeight - restartButtonHeight) / 2
        love.graphics.draw(restartButton, buttonX, buttonY, 0, restartButtonScaleX, restartButtonScaleY)
    else
        love.graphics.draw(background2, 0, 0)
        love.graphics.draw(player.image, player.x - player.width / 2, player.y - player.height / 2)

        for _, enemy in ipairs(enemies) do
            love.graphics.draw(enemy.image, enemy.x - enemy.width / 2, enemy.y - enemy.height / 2)
        end

        for _, bullet in ipairs(bullets) do
            love.graphics.setColor(1, 1, 0)
            love.graphics.rectangle("fill", bullet.x - bullet.width / 2, bullet.y - bullet.height / 2, bullet.width, bullet.height)
        end

        for _, explosion in ipairs(explosions) do
            love.graphics.draw(explosion.image, explosion.x - explosion.width / 2, explosion.y - explosion.height / 2)
        end

        love.graphics.setFont(scoreFont)
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("Score: " .. score, 0, 20, gameWidth, "center")
        love.graphics.printf("High Score: " .. highScore, 0, 60, gameWidth, "center")

        love.graphics.setFont(readyFont)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Mission: " .. missionDescription, 0, 100, gameWidth, "center")

        love.graphics.setColor(target.color)
        love.graphics.circle("fill", target.x, target.y, target.radius)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if gameState == "start" then
            local buttonX = (gameWidth - startButtonWidth) / 2
            local buttonY = (gameHeight - startButtonHeight) / 2
            if x >= buttonX and x <= buttonX + startButtonWidth and y >= buttonY and y <= buttonY + startButtonHeight then
                gameState = "transition"
            end

            local quitButtonX = (gameWidth - quitButtonWidth) / 2
            local quitButtonY = buttonY + startButtonHeight + 20
            if x >= quitButtonX and x <= quitButtonX + quitButtonWidth and y >= quitButtonY and y <= quitButtonY + quitButtonHeight then
                love.event.quit()
            end
        elseif gameOver then
            local buttonX = (gameWidth - restartButtonWidth) / 2
            local buttonY = (gameHeight - restartButtonHeight) / 2
            if x >= buttonX and x <= buttonX + restartButtonWidth and y >= buttonY and y <= buttonY + restartButtonHeight then
                gameOver = false
                score = 0
                player.x = gameWidth / 2
                player.y = gameHeight - 50
                enemies = {}
                bullets = {}
                explosions = {}
                gameState = "start"
            end
        end
    end
end

function love.keypressed(key)
    if key == "space" and not gameOver and gameState == "play" then
        shootBullet()
    elseif key == "escape" then
        love.event.quit()
    end
end

function shootBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y - player.height / 2
    bullet.speed = bulletSpeed
    bullet.width = 5
    bullet.height = 10

    if bulletType == "fast" then
        bullet.speed = 700
        bullet.width = 3
    elseif bulletType == "large" then
        bullet.width = 15
    end

    table.insert(bullets, bullet)
end

function createExplosion(x, y)
    local explosion = {}
    explosion.x = x
    explosion.y = y
    explosion.image = explosionImage
    explosion.width = explosion.image:getWidth()
    explosion.height = explosion.image:getHeight()
    explosion.timer = 0.5
    table.insert(explosions, explosion)
    love.audio.play(explosionSound)
end
