local playerCoins = 100
local betAmount = 0
local arrowAngle = 0
local spinning = false
local result = ""
local choice = nil
local spinSpeed = 0
local finalAngle = nil
local inputActive = true -- Enables typing for bet input

-- Define zones
local greenZoneStart = 270
local greenZoneEnd = 90
local orangeZoneStart = 90
local orangeZoneEnd = 270

function love.load()
    love.window.setTitle("Spin the Wheel")
    love.window.setMode(800, 600)
    math.randomseed(os.time()) -- Ensure randomness
end

function love.update(dt)
    -- Handle the spinning arrow animation
    if spinning then
        arrowAngle = arrowAngle + spinSpeed * dt
        spinSpeed = spinSpeed - dt * 50 -- Gradually slow down the spin

        -- Stop spinning and calculate result
        if spinSpeed <= 0 then
            spinning = false
            arrowAngle = arrowAngle % 360 -- Normalize angle to 0-360
            checkResult()
        end
    end
end

function love.draw()
    -- Draw the wheel (stationary)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("line", 400, 300, 100) -- Draw wheel outline
    love.graphics.setColor(1, 0.5, 0) -- Orange (left)
    love.graphics.arc("fill", 400, 300, 100, math.rad(0), math.rad(180))
    love.graphics.setColor(0, 1, 0) -- Green (right)
    love.graphics.arc("fill", 400, 300, 100, math.rad(180), math.rad(360))

    -- Draw spinning arrow (shorter and arrow-shaped)
    love.graphics.push()
    love.graphics.translate(400, 300)
    love.graphics.rotate(math.rad(arrowAngle))
    love.graphics.setColor(1, 1, 1) -- White arrow
    love.graphics.polygon("fill", -5, 0, 5, 0, 0, -50) -- Arrow body
    love.graphics.polygon("fill", -10, -40, 10, -40, 0, -50) -- Arrowhead
    love.graphics.pop()

    -- Draw UI elements
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Coins: " .. playerCoins, 10, 10)
    love.graphics.print("Bet: " .. betAmount, 10, 30)
    love.graphics.print("Result: " .. result, 10, 50)
    love.graphics.print("Choice: " .. (choice or "None"), 10, 70)

    -- Draw Green Button
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", 50, 500, 100, 50)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Green", 75, 515)

    -- Draw Orange Button
    love.graphics.setColor(1, 0.5, 0)
    love.graphics.rectangle("fill", 200, 500, 100, 50)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Orange", 220, 515)

    -- Draw Spin Button
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle("fill", 350, 500, 100, 50)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Spin", 385, 515)

    -- Instructions
    love.graphics.print("Type your bet and press Backspace to edit. Select Green/Orange, then Spin.", 10, 120)
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then -- Left mouse button
        -- Check if Green button is clicked
        if x >= 50 and x <= 150 and y >= 500 and y <= 550 then
            choice = "green"
            result = "You chose Green!"
        end

        -- Check if Orange button is clicked
        if x >= 200 and x <= 300 and y >= 500 and y <= 550 then
            choice = "orange"
            result = "You chose Orange!"
        end

        -- Check if Spin button is clicked
        if x >= 350 and x <= 450 and y >= 500 and y <= 550 then
            if betAmount > 0 and betAmount <= playerCoins and choice then
                spinning = true
                spinSpeed = math.random(300, 400) -- Random initial spin speed
                finalAngle = math.random(0, 360) -- Random landing angle
                playerCoins = playerCoins - betAmount
                result = "" -- Clear result while spinning
                inputActive = false -- Disable bet input while spinning
            else
                result = "Invalid Bet or No Choice!"
            end
        end
    end
end

function checkResult()
    -- Determine which zone the arrow lands in
    local angle = arrowAngle % 360 -- Normalize angle

    -- Green zone: 270° to 90°, Orange zone: 90° to 270°
    local landedColor
    if (angle >= greenZoneStart or angle <= greenZoneEnd) then
        landedColor = "green"
    elseif angle > orangeZoneStart and angle <= orangeZoneEnd then
        landedColor = "orange"
    end

    -- Compare the landed color with the player's choice
    if choice == landedColor then
        playerCoins = playerCoins + betAmount * 2
        result = "You Win!"
    else
        result = "You Lose!"
    end

    -- Clear the choice and reset input
    choice = nil
    inputActive = true

    -- Handle Game Over or Winning Conditions
    if playerCoins <= 0 then
        result = "Game Over! Restart to Play Again."
        playerCoins = 0
    elseif playerCoins >= 500 then
        result = "Congratulations! You Won the Game!"
    end
end

function love.textinput(text)
    if inputActive and tonumber(text) then
        betAmount = tonumber(tostring(betAmount) .. text) -- Append typed number to betAmount
    end
end

function love.keypressed(key)
    if inputActive and key == "backspace" then
        betAmount = math.floor(betAmount / 10) -- Remove the last digit of betAmount
    end
end

