debug = true

player = { x = 1000/2, y = 710, speed = 400, img = nil }
universal = { x = 1000/2, y = 0 }
ground = { x = 0, y = 710, img = nil, rImg = nil}

isAlive = true
score = 0

speedAdder = 0
speedMultiplier = 1

-- Timers
-- We declare these here so we don't have to edit them multiple places
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax

-- Image Storage
bulletImg = nil

-- Entity Storage
bullets = {} -- array of current bullets being drawn and updated

--More timers
createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax
createHEnemyTimerMax = 5
createHEnemyTimer = createHEnemyTimerMax

-- More images
enemyImg = nil -- Like other images we'll pull this in during out love.load function
hEnemyImg = nil
platformImg = nil

-- More storage
enemies = {} -- array of current enemies on screen
hEnemies = {}
hEnemyTimer = {}
hEnemySpeed = 0.3
platforms = {}



harassingEnemies = false

universalTimer = 0
angle = 0



-- THE MAP OF ENEMIES --
--enemyMap = {{enemyType, initialPosition, flightPath, Number of enemies}} --
--enemyTimes = {timeOfAppearance,timeOfAppearance...}
enemyMap = {{100,50},{500,250},{1100,500},{1900,300}, {2500,800}}
platformMap = {{200,750},{300,700},{400,550},{800,300},{900,650},{1000,700}}
enemyTimes = {10,15}


grounded = false
yVelocity = 0

--  FUNCTIONS  --

-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function OnPlatform(x1,y1,w1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2-h2+30 and
         y1 > y2-h2+13
end

function love.load(arg)
    player.img = love.graphics.newImage('assets/MarisaChar.png')
    platformImg = love.graphics.newImage('assets/ehehplat.png')
    bulletImg = love.graphics.newImage('assets/MyProj2.png')
    enemyImg = love.graphics.newImage('assets/enemy.png')
    hEnemyImg = love.graphics.newImage('assets/hEnemy.png')
    bgImage = love.graphics.newImage('assets/background.png')
    ground.img = love.graphics.newImage('assets/ground.png')
    ground.rImg = love.graphics.newImage('assets/groundReverse.png')
    -- SOUNDS --
    gunSound = love.audio.newSource("assets/nyanpasu.wav", "static")

    --we now have an asset ready to be used inside Love
end

-- Updating
function love.update(dt)



    -- SHIP --
    if love.keyboard.isDown('lshift') then
        speedMultiplier = 40.0
    else
        speedMultiplier = 1
    end
    -- I always start with an easy way to exit the game
    if love.keyboard.isDown('escape') then
        love.event.push('quit')
    end

    if love.keyboard.isDown('left','a') then
        -- if player.x >= 0 then
        --     player.x = player.x - (speedMultiplier*player.speed*dt)
        -- else
        --
        -- end
        ground.x = ground.x + (speedMultiplier*player.speed*dt)
        universal.x = universal.x - (speedMultiplier*player.speed*dt)
        for i, enemy in ipairs(enemies) do
          enemy.x = enemy.x + (speedMultiplier*player.speed*dt)
        end
        for i, platform in ipairs(platforms) do
          platform.x = platform.x + (speedMultiplier*player.speed*dt)
        end
    elseif love.keyboard.isDown('right','d') then
        -- if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
        --     player.x = player.x + (speedMultiplier*player.speed*dt)
        -- end
            ground.x = ground.x - (speedMultiplier*player.speed*dt)
            universal.x = universal.x + (speedMultiplier*player.speed*dt)
             for i, enemy in ipairs(enemies) do
               enemy.x = enemy.x - (speedMultiplier*player.speed*dt)
             end
             for i, platform in ipairs(platforms) do
               platform.x = platform.x - (speedMultiplier*player.speed*dt)
             end
    end

    if love.keyboard.isDown('up','w') then
        if grounded then
            grounded = false
            yVelocity = -2.5
        end
    elseif love.keyboard.isDown('down','s') then
        -- if player.y < (love.graphics.getHeight() - player.img:getHeight()) then
        --     player.y = player.y + (speedMultiplier*player.speed*dt)
        -- end
    end


    if speedAdder < 1 then
        speedAdder = 0
    else
        player.y = player.y - speedAdder
        speedAdder = speedAdder - 1
    end


    if not isAlive and love.keyboard.isDown('r') then
      	-- remove all our bullets and enemies from screen
      	bullets = {}
      	enemies = {}

      	-- reset timers
      	canShootTimer = canShootTimerMax
      	createEnemyTimer = createEnemyTimerMax

      	-- move player back to default position
      	player.x = 50
      	player.y = 710

      	-- reset our game state
      	score = 0
      	isAlive = true
    end
    if not grounded then
        yVelocity = yVelocity + 0.015
        player.y = player.y + yVelocity
    end
    -- if CheckCollision(player.x,player.y,player.img:getWidth(),player.img:getHeight(),ground.x,ground.y+50,ground.img:getWidth(),ground.img:getHeight()) then
    --     grounded = true
    --     yVelocity = 0
    -- end
    if player.y > ground.y then
        grounded = true
        yVelocity = 0
    end
    for i,platform in ipairs(platforms) do
        if OnPlatform(player.x,player.y,player.img:getWidth(),platform.x,platform.y,platformImg:getWidth(),platformImg:getHeight()) then
            if(yVelocity > 0) then
                grounded = true
            end
        else
            grounded = player.y > ground.y
        end
    end

    if ground.x > ground.img:getWidth() then
        ground.x = 0
    elseif ground.x < -ground.img:getWidth() then
        ground.x = 0
    end

    for i, pos in ipairs(enemyMap) do
      if pos[1] > universal.x and pos[1] < universal.x + 500 then
        newEnemy = { x = pos[2], y = 0, img = enemyImg }
        table.insert(enemies,newEnemy)
        table.remove(enemyMap,i)
      end
    end
    for i, pos in ipairs(platformMap) do
      if pos[1] > universal.x and pos[1] < universal.x + 500 then
        newPlat = { x = 800, y = pos[2], img = platformImg }
        table.insert(platforms,newPlat)
        table.remove(platformMap,i)
      end
    end
end
for i, hEnemy in ipairs(hEnemies) do
      angle = math.atan(2*hEnemyTimer[i]-2*math.pow(hEnemyTimer[i],2)/0.5*hEnemyTimer[i])
      hEnemy.y = hEnemy.y + hEnemySpeed*math.sin(angle) --you never know if you dont gooooooooooooo
      -- hEnemy.y = hEnemy.y - 2*math.pow(hEnemyTimer[i],2)
      -- hEnemy.x = hEnemy.x + 0.5*hEnemyTimer[i]
      hEnemy.x = hEnemy.x + hEnemySpeed*math.cos(angle)
      hEnemyTimer[i]=hEnemyTimer[i]+0.001

      if hEnemy.y > 850 then -- remove enemies when they pass off the screen
        table.remove(hEnemies, i)
      end
    end

function love.draw(dt)
    love.graphics.draw(bgImage)
    love.graphics.draw(ground.img, ground.x, ground.y)
    love.graphics.draw(ground.rImg, ground.x+ground.img:getWidth(), ground.y)
    love.graphics.draw(ground.rImg, ground.x-ground.img:getWidth(), ground.y)

    if isAlive then
        love.graphics.draw(player.img, player.x, player.y)
    else
        love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
    end
    for i, enemy in ipairs(enemies) do
	    love.graphics.draw(enemy.img, enemy.x, enemy.y)
    end
    for i, hEnemy in ipairs(hEnemies) do
      love.graphics.draw(hEnemy.img, hEnemy.x, hEnemy.y)
    end
    for i, platform in ipairs(platforms) do
      love.graphics.draw(platform.img, platform.x, platform.y)
    end

    -- SHOW SCORE --
    -- love.graphics.setColor(255, 255, 255)
    love.graphics.print("SCORE: " .. tostring(score), 400, 10)
end
