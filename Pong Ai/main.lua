Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'

WIN_WIDTH = 1280
WIN_HEIGHT = 720

VIRT_WIDTH = 432
VIRT_HEIGHT = 243

PADDLE_SPEED = 200


function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Crazy Pong')
    
    math.randomseed(os.time())

    smallfont = love.graphics.newFont('font.ttf', 8)

    scorefont = love.graphics.newFont('font.ttf', 32)

    victoryFont = love.graphics.newFont('font.ttf', 24)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
        ['point_scored'] = love.audio.newSource('point_scored.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static')
    }

    push:setupScreen(VIRT_WIDTH, VIRT_HEIGHT, WIN_WIDTH, WIN_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    player1score = 0
    player2score = 0

    servingPlayer = math.random(2) == 1 and 1 or 2

    

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRT_WIDTH - 10, VIRT_HEIGHT - 30, 5, 20)
    ball = Ball(VIRT_WIDTH / 2 - 2, VIRT_HEIGHT / 2 - 2, 4, 4)

    if servingPlayer == 1 then
        ball.dx = 100
    else
        ball.dx = -100
    end

    
    gameState = 'start'

    
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if gameState == 'play' then

        if ball.x < 0 then
            servingPlayer = 1
            player2score = player2score + 1

            sounds['point_scored']:play()

            ball:reset()
            ball.dx = 100

            if player2score >= 7 then
                gameState = 'victory'
                winningPlayer = 2
            else
                gameState = 'serve'
            end
        end

        if ball.x > VIRT_WIDTH then
            servingPlayer = 2
            player1score = player1score + 1

            sounds['point_scored']:play()

            ball:reset()
            ball.dx = -100
            
            if player1score >= 7 then
                gameState = 'victory'
                winningPlayer = 1
            else
                gameState = 'serve'
            end
        end


        if ball:collides(player1) then
            -- deflect ball to the right
            ball.dx = -ball.dx * 1.1
            ball.x = player1.x + 5

            sounds['paddle_hit']:play()

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        if ball:collides(player2) then
            -- deflect ball to the left
            ball.dx = -ball.dx * 1.1
            ball.x = player2.x - 4

            sounds['paddle_hit']:play()

            --if ball.dy < 0 then
            --    ball.dy = -math.random(10, 100)
            --else
            --    ball.dy = math.random(10, 100)
            --end
        end


        if ball.y <= 0 then
            -- deflect ball down
            ball.dy = -ball.dy
            ball.y = 0

            sounds['wall_hit']:play()
        end

        if ball.y >= VIRT_HEIGHT - 4 then
            ball.dy = -ball.dy
            ball.y = VIRT_HEIGHT - 4 

            sounds['wall_hit']:play()
        end
    end


    

    --Player 1 movement
    if love.keyboard.isDown('up') then
        player1.dy = -PADDLE_SPEED * 1.5
    
    elseif love.keyboard.isDown('down') then
        player1.dy = PADDLE_SPEED * 1.5
    
    else
        player1.dy = 0
    
    end


    -- Player 2 movement
    player2.dy = ball.dy 


    if gameState == 'play' then
        ball:update(dt)
    end
    
    player1:update(dt)
    player2:update(dt)
end




function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
   
   
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'victory' then
            gameState = 'start'
            player1score = 0
            player2score = 0
        elseif gameState == 'serve' then
            gameState = 'play'
        end
    end
end




function love.draw()


    push:apply('start')

    --Background color set to purple
    love.graphics.clear(127/255, 0/255, 255/255, 127/255)

    -- Draw welcome text toward the top of the screen 
    love.graphics.setFont(smallfont)
    
    if gameState == 'start' then
        love.graphics.setColor(51/255, 153/255, 255/255, 255/255)
        love.graphics.setFont(smallfont)
        love.graphics.printf("Lets Play Some Crazy Pong!", 0, 10, VIRT_WIDTH, 'center')
        love.graphics.printf("Press Enter to Start!", 0, 20, VIRT_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setColor(51/255, 153/255, 255/255, 255/255)
        love.graphics.setFont(smallfont)
        love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s turn to start!", 
            0, 10, VIRT_WIDTH, 'center')
        love.graphics.printf("Press Enter to Serve!", 0, 20, VIRT_WIDTH, 'center')
    elseif gameState == 'victory' then
        -- draw a victory messsage
        love.graphics.setColor(255/255, 255/255, 0/255, 255/255)
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player " .. tostring(winningPlayer) .. " wins!", 
            0, 10, VIRT_WIDTH, 'center')
        love.graphics.setFont(smallfont)
        love.graphics.printf("Press Enter to Start Again!", 0, 100, VIRT_WIDTH, 'center')
    elseif gameState == 'play' then
        love.graphics.setColor(255/255, 102/255, 255/255, 255/255)
        --no UI messages to display in play
    end


    --Draw score on the left and right center of the screen 
    --Need to switch font to draw before actually printing
    love.graphics.setFont(scorefont)
    love.graphics.print(player1score, VIRT_WIDTH / 2 -50, VIRT_HEIGHT / 7)
    love.graphics.print(player2score, VIRT_WIDTH / 2 + 30, VIRT_HEIGHT / 7)

    player1:render()
    player2:render()
    
    --Render ball center
    ball:render()
    
    displayFPS()

    push:apply('end')

end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallfont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1, 1, 1, 1)
    
end