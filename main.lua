-- window size
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- retro 16:9 aspect resolution
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- boot timer
boot = 5

-- adjusting the play area
PLAY_WIDTH = 370

-- base character speed
CHAR_SPEED = 200

-- base projectile speed and max speed
BASE_PSPEED = 80
MAX_SPEED = 175

-- base projectile spawn chance and maximum spawn chance
BASE_SPAWN = 400
MAX_SPAWN = 48

-- base projectile damage
BASE_DAMAGE = 4

-- base heal information
BASE_RECOVER = 10
HSPEED = 100
HSPAWN_CHANCE = 8000

-- header files
Class = require 'class'
push = require 'push'
require 'Chara'
require 'Heal'
require 'Projectile'

function love.load()
    math.randomseed(os.time()) -- randomizer

    love.window.setTitle("Pandemic") -- window name

    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.mouse.setVisible(true) -- cursor visibility set to true

    playChar = Chara(PLAY_WIDTH / 2 - 10, VIRTUAL_HEIGHT / 2 + 10) -- initializing the player character

    bullets = {} -- table that stores all the projectiles
    heals = {} -- table that stores all the heals

    -- information initializer
    timer = 0
    hp = 100
    rep = 0
    aveFPS = 0
    spawn_timer = 0
    dec_spawn = 0
    phase = 1
    bootTimer = boot
    sfx_on = true
    music_on = true

    -- screen initializer
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = false
    })

    -- table of all visuals used
    graphics = {
        ['cover'] = love.graphics.newImage('graphics/cover.png'),
        ['play_area'] = love.graphics.newImage('graphics/play_area.png'),
        ['sidebar'] = love.graphics.newImage('graphics/sidebar.png'),
        ['menu'] = love.graphics.newImage('graphics/menu.png'),
        ['paused'] = love.graphics.newImage('graphics/pause.png'),
        ['defeat'] = love.graphics.newImage('graphics/lose.png')
    }

    -- table of all button images used 
    buttons = {
        ['pause_button'] = love.graphics.newImage('graphics/buttons/pause_button.png'),
        ['sfx_on'] = love.graphics.newImage('graphics/buttons/sfx_on.png'),
        ['sfx_off'] = love.graphics.newImage('graphics/buttons/sfx_off.png'),
        ['music_on'] = love.graphics.newImage('graphics/buttons/music_on.png'),
        ['music_off'] = love.graphics.newImage('graphics/buttons/music_off.png'),
        ['30fps'] = love.graphics.newImage('graphics/buttons/30.png'),
        ['60fps'] = love.graphics.newImage('graphics/buttons/60.png'),
        ['144fps'] = love.graphics.newImage('graphics/buttons/144.png'),
        ['selection'] = love.graphics.newImage('graphics/buttons/selection.png')
    }
    
    -- table of all music used
    music = {
        ['cover_theme'] = love.audio.newSource('music/bensound-instinct.mp3', 'stream'),
        ['play_theme'] = love.audio.newSource('music/bensound-dance.mp3', 'stream')
    }

    -- table of all sound effects used
    sfx = {
        ['hit'] = love.audio.newSource('sfx/Hit.wav', 'static'),
        ['heal'] = love.audio.newSource('sfx/Heal.wav', 'static'),
        ['active_heal'] = love.audio.newSource('sfx/HealSpawn.wav', 'static'),
        ['loss'] = love.audio.newSource('sfx/Defeat.wav', 'static'),
        ['select'] = love.audio.newSource('sfx/Select.wav', 'static')
    }

    -- table of all fonts used
    fonts = {
        ['titleFont'] = love.graphics.newFont('fonts/Wynter Sandy.ttf', 70),
        ['baseFont'] = love.graphics.newFont('fonts/Pocket Change.otf', 15),
        ['entryFont'] = love.graphics.newFont('fonts/gravtac.ttf', 30),
        ['menuFont'] = love.graphics.newFont('fonts/Sweet Banana.ttf', 17),
        ['largemenuFont'] = love.graphics.newFont('fonts/Sweet Banana.ttf', 23),
        ['fontsFont'] = love.graphics.newFont('fonts/Sweet Banana.ttf', 15),
        ['selfpromotionFont'] = love.graphics.newFont('fonts/Sweet Banana.ttf', 12)
    }

    -- initializing the gamestate to open
    gameState = 'open'
end

function love.keypressed(key) -- keyboard mapping
    if key == 'escape' then
        if gameState == 'credits' or gameState == 'instructions' or gameState == 'pause' then
            sfx['select']:play()
            gameState = 'open'
        elseif gameState == 'open' or gameState == 'dead' then
            love.event.quit()
        end
    end

    if key == 'enter' or key == 'return' then
        if gameState ==  'open' then
            sfx['select']:play()
            timer = 0
            spawn_timer = 0
            gameState = 'instructions'
        elseif gameState == 'instructions' then
            if bootTimer <= 0 then
                sfx['select']:play()
                aveFPS = love.timer.getFPS()
                HSPAWN_CHANCE = HSPAWN_CHANCE * (aveFPS/100)
                gameState = 'play'
            end
        elseif gameState == 'dead' then
            sfx['select']:play()
            gameState = 'highscores'
        end       
    end

    if gameState ==  'highscores' then
        if key == 'enter' or key == 'return' or key == 'escape' then
            gameState = 'open'
        end
    end

    if key == 'p' then
        if gameState == 'play' then
            if sfx_on == true then
                sfx['select']:play()
            end
            gameState = 'pause'
        elseif gameState == 'pause' then
            if sfx_on == true then
                sfx['select']:play()
            end
            gameState = 'play'
        end
    end

    if key == 'c' then
        if gameState == 'open' then
            sfx['select']:play()
            gameState = 'credits'
        elseif gameState == 'credits' then
            sfx['select']:play()
            gameState = 'open'
        end
    end

    if gameState == 'play' then
        if key == 'm' then
            if sfx_on == true or music_on == true then
                sfx_on = false
                music_on = false
            else
                sfx['select']:play()
                sfx_on = true
                music_on = true
            end
        end
    end
end

function love.mousepressed() -- mouse key mapping
    local msx, msy = love.mouse.getPosition()
    if love.mouse.isDown(1) and gameState == 'play' then
        if msx >= 1110 and msx <= 1263 and msy >= 634 and msy <= 696 then
            if sfx_on == true then  
                sfx['select']:play()
            end
            gameState = 'pause'
        elseif msx >= 1110 and msx <= 1187 and msy >= 572 and msy <= 634 then
            if sfx_on == true then
                sfx_on = false
            elseif sfx_on == false then
                sfx_on = true
            end
        elseif msx >= 1187 and msx <= 1263 and msy >= 572 and msy <= 634 then
            if music_on == true then
                music_on = false
            elseif music_on == false then
                music_on = true
            end
        end
    end
end

function love.update(dt) -- updating the display depending on the current gamestate
    if gameState == 'dead' or gameState == 'open' then
        if gameState == 'open' then
            -- information reset
            timer = 0
            rep = 0
            hp = 100
            RECOVER = BASE_RECOVER
            phase = 1
            PROJ_SPEED = BASE_PSPEED
            SPAWN_CHANCE = BASE_SPAWN
            DAMAGE = BASE_DAMAGE
            sfx_on = true
            music_on = true
        end

        if gameState == 'dead' then
            if rep == 0 then
                sfx['loss']:play()
                rep = 1
            end
        end
        
        for i,v in ipairs(bullets) do
            table.remove(bullets, i)
        end

        bootTimer = boot
    elseif gameState == 'instructions' then
        bootTimer = bootTimer - 1 * dt -- load timer
    elseif gameState == 'play' then
        playChar:update(dt)

        PROJ_SPEED = math.min(PROJ_SPEED + 0.8 * dt, MAX_SPEED) -- projectile speed ramping up
        SPAWN_CHANCE = math.max(SPAWN_CHANCE - (1.1 * math.min(phase - 1, 5) * dt), MAX_SPAWN) -- spawn chance ramping up
        if dec_spawn == 25  then -- phase/level scaling
            spawn_timer = 0
            dec_spawn = 0
            RECOVER = RECOVER + 5
            phase = phase + 1
            DAMAGE = DAMAGE + 1
            if phase == 5 then
                SPAWN_CHANCE = 500
            elseif phase > 2  and phase < 9 then
                SPAWN_CHANCE = SPAWN_CHANCE + 50
            else
                SPAWN_CHANCE = SPAWN_CHANCE + 100
            end
        end

        -- projectile spawning
        bulSpawn = math.random(SPAWN_CHANCE)
        if phase == 1 or phase == 2 or phase >= 5 then
            if bulSpawn == 1 then
                -- top spawn downward movement
                table.insert(bullets, Projectile(math.random(10, PLAY_WIDTH - 10), -5, 0, PROJ_SPEED))
            elseif bulSpawn == 2 then
                -- bottom spawn upward movement
                table.insert(bullets, Projectile(math.random(10, PLAY_WIDTH - 10), VIRTUAL_HEIGHT, 0, -PROJ_SPEED))
            elseif bulSpawn == 3 then
                -- left spawn rightward movement
                table.insert(bullets, Projectile(-5, math.random(10, VIRTUAL_HEIGHT - 10), PROJ_SPEED, 0))
            elseif bulSpawn == 4 then
                -- right spawn leftward movement
                table.insert(bullets, Projectile(PLAY_WIDTH - 8, math.random(10, VIRTUAL_HEIGHT - 10), -PROJ_SPEED, 0))
            end
        end
        if phase == 3 or phase == 4 or phase >= 5 then
            if bulSpawn == 5 then
                -- top spaw rightward diagonal movement
                table.insert(bullets, Projectile(math.random(10, PLAY_WIDTH - 10), -5, 0.5 * PROJ_SPEED, 0.5 * PROJ_SPEED))
            elseif bulSpawn == 6 then
                -- top spawn leftward diagonal movement
                table.insert(bullets, Projectile(math.random(10, PLAY_WIDTH - 10), -5, -0.5 * PROJ_SPEED, 0.5 * PROJ_SPEED))
            elseif bulSpawn == 7 then
                -- bottom spawn rightward diagonal movement
                table.insert(bullets, Projectile(math.random(10, PLAY_WIDTH - 10), VIRTUAL_HEIGHT, 0.5 *PROJ_SPEED, -0.5 * PROJ_SPEED))
            elseif bulSpawn == 8 then
                -- bottom spawn leftward diagonal movement
                table.insert(bullets, Projectile(math.random(10, PLAY_WIDTH - 10), VIRTUAL_HEIGHT, -0.5 * PROJ_SPEED, -0.5 * PROJ_SPEED))
            elseif bulSpawn == 9 then
                -- left spawn upward diagonal movement
                table.insert(bullets, Projectile(-5, math.random(10, VIRTUAL_HEIGHT - 10), 0.5 * PROJ_SPEED, -0.5 * PROJ_SPEED))
            elseif bulSpawn == 10 then
                -- left spawn downward diagonal movement
                table.insert(bullets, Projectile(-5, math.random(10, VIRTUAL_HEIGHT - 10), 0.5 * PROJ_SPEED, -0.5 * PROJ_SPEED))
            elseif bulSpawn == 11 then
                -- right spawn upward diagonal movement
                table.insert(bullets, Projectile(PLAY_WIDTH - 8, math.random(10, VIRTUAL_HEIGHT - 10), -0.5 *PROJ_SPEED, -0.5 * PROJ_SPEED))
            elseif bulSpawn == 12 then
                -- right spawn downward diagonal movement
                table.insert(bullets, Projectile(PLAY_WIDTH - 8, math.random(10, VIRTUAL_HEIGHT - 10), -0.5 * PROJ_SPEED, 0.5 * PROJ_SPEED))
            end
        end
        
        -- projectile collision
        for i,v in ipairs(bullets) do
            v:update(dt)

            v:collision(playChar)
            if v.dead then
                if sfx_on == true then
                    sfx['hit']:play()
                end
                table.remove(bullets, i)
                hp = hp - DAMAGE
                if hp <= 0 then
                    gameState = 'dead'
                end
            end

            v:border()
            if v.frame then
                table.remove(bullets, i)
            end
        end

        -- heal spawning
        helSpawn = math.random(HSPAWN_CHANCE)
        if helSpawn == 1 then
            -- top spawn downward movement
            table.insert(heals, Heal(math.random(10, PLAY_WIDTH - 10), -5, 0, HSPEED))
        elseif helSpawn == 2 then
            -- bottom spawn upward movement
            table.insert(heals, Heal(math.random(10, PLAY_WIDTH - 10), VIRTUAL_HEIGHT, 0, -HSPEED))
        elseif helSpawn == 3 then
            -- left spawn rightward movement
            table.insert(heals, Heal(-5, math.random(10, VIRTUAL_HEIGHT - 10), HSPEED, 0))
        elseif helSpawn == 4 then
            -- right spawn leftward movement
            table.insert(heals, Heal(PLAY_WIDTH - 8, math.random(10, VIRTUAL_HEIGHT - 10), -HSPEED, 0))
        end

        -- heal collision
        for i,v in ipairs(heals) do
            v:update(dt)

            v:collision(playChar)
            if v.healed then
                if sfx_on == true then
                    sfx['heal']:play()
                end
                table.remove(heals, i)
                hp = hp + RECOVER
            end

            v:border()
            if v.frame then
                table.remove(heals, i)
            end
        end

        -- time and scoring
        timer = timer + 1
        score = math.floor(timer / aveFPS)

        -- timer for phases
        spawn_timer = spawn_timer + 1
        dec_spawn = math.floor(spawn_timer / aveFPS)

        -- player vertical movement
        if love.keyboard.isDown('w') or love.keyboard.isDown('up') then -- upward movement
            if hp >= 100 then
                playChar.dy = -1.2*CHAR_SPEED
            elseif hp >= 80 then
                playChar.dy = -CHAR_SPEED
            elseif hp >= 60 then
                playChar.dy = -0.8*CHAR_SPEED
            elseif hp >= 40 then
                playChar.dy = -0.6*CHAR_SPEED
            elseif hp >= 20 then
                playChar.dy = -0.4*CHAR_SPEED
            else
                playChar.dy = -0.2*CHAR_SPEED
            end
        elseif love.keyboard.isDown('s') or love.keyboard.isDown('down') then -- downward movement
            if hp >= 100 then
                playChar.dy = 1.2*CHAR_SPEED
            elseif hp >= 80 then
                playChar.dy = CHAR_SPEED
            elseif hp >= 60 then
                playChar.dy = 0.8*CHAR_SPEED
            elseif hp >= 40 then
                playChar.dy = 0.6*CHAR_SPEED
            elseif hp >= 20 then
                playChar.dy = 0.4*CHAR_SPEED
            else
                playChar.dy = 0.2*CHAR_SPEED
            end
        else
            playChar.dy = 0
        end

        -- player horizontal movement
        if love.keyboard.isDown('d') or love.keyboard.isDown('right') then -- rightward movement
            if hp >= 100 then
                playChar.dx = 1.2*CHAR_SPEED
            elseif hp >= 80 then
                playChar.dx = CHAR_SPEED
            elseif hp >= 60 then
                playChar.dx = 0.8*CHAR_SPEED
            elseif hp >= 40 then
                playChar.dx = 0.6*CHAR_SPEED
            elseif hp >= 20 then
                playChar.dx = 0.4*CHAR_SPEED
            else
                playChar.dx = 0.2*CHAR_SPEED
            end
        elseif love.keyboard.isDown('a') or love.keyboard.isDown('left') then -- leftward movement
            if hp >= 100 then
                playChar.dx = -1.2*CHAR_SPEED
            elseif hp >= 80 then
                playChar.dx = -CHAR_SPEED
            elseif hp >= 60 then
                playChar.dx = -0.8*CHAR_SPEED
            elseif hp >= 40 then
                playChar.dx = -0.6*CHAR_SPEED
            elseif hp >= 20 then
                playChar.dx = -0.4*CHAR_SPEED
            else
                playChar.dx = -0.2*CHAR_SPEED
            end
        else
            playChar.dx = 0
        end
    end
end

function love.draw() -- game and sound rendering
    push:apply('start') -- begin formatting
    
    if gameState == 'open' then
        music['play_theme']:stop()
        music['cover_theme']:play()

        love.graphics.draw(graphics['cover'], 0, 0)
        love.graphics.setFont(fonts['entryFont'])

        -- blinking opening menu prompt
        if math.floor(love.timer.getTime()) % 2 == 0 then
            love.graphics.printf('Press "Enter"', 0, VIRTUAL_HEIGHT / 2 - 10, VIRTUAL_WIDTH, 'center')
        end

        love.graphics.setFont(fonts['baseFont'])
        love.graphics.printf('Press "esc" to exit', 5, VIRTUAL_HEIGHT - 20, VIRTUAL_WIDTH, 'left')
        love.graphics.printf('Press "c" for credits', -5, VIRTUAL_HEIGHT - 20, VIRTUAL_WIDTH, 'right')

        love.graphics.setFont(fonts['titleFont'])
        love.graphics.printf('PANDEMIC', 0, 0, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'credits' then
        love.graphics.draw(graphics['cover'], 0, 0)
        love.graphics.draw(graphics['menu'], 30, 20)

        love.graphics.setFont(fonts['baseFont'])
        love.graphics.printf('Press "esc" to go back to main menu', 5, VIRTUAL_HEIGHT - 20, VIRTUAL_WIDTH, 'left')

        love.graphics.setFont(fonts['menuFont'])
        love.graphics.printf('Royalty Free Music from Bensound', 0, 40, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Cover Photo taken from WHO website', 0, 60, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Sounds Effects from Bfxr.', 0, 80, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Fonts Used:', 0, 100, VIRTUAL_WIDTH, 'center')

        love.graphics.setFont(fonts['selfpromotionFont'])
        love.graphics.printf('github.com/Yookalehleh', -40, VIRTUAL_HEIGHT - 50, VIRTUAL_WIDTH, 'right')

        love.graphics.setFont(fonts['fontsFont'])
        love.graphics.printf('Wynter Sandy by StringLabs Creative Studio', 0, 115, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Gravtac by Typodermic Fonts', 0, 130, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('ComicDylans by StringLabs Creative Studio', 0, 145, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Pocket Change by Woodcutter', 0, 160, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Sweet Banana by Rangkai Aksara', 0, 175, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'instructions' then
        love.graphics.draw(graphics['cover'], 0, 0)
        love.graphics.draw(graphics['menu'], 30, 20)

        love.graphics.setFont(fonts['baseFont'])
        love.graphics.printf('Press "esc" to exit', 5, VIRTUAL_HEIGHT - 20, VIRTUAL_WIDTH, 'left')

        -- game booting sequence
        if bootTimer <= 0 then
            love.graphics.printf('Press "ENTER" to begin!', -10, VIRTUAL_HEIGHT - 20, VIRTUAL_WIDTH, 'right')
        else
            if math.floor(love.timer.getTime()) % 3 == 0 then
                love.graphics.printf('Loading.', VIRTUAL_WIDTH - 70, VIRTUAL_HEIGHT - 20, VIRTUAL_WIDTH, 'left')
            elseif math.floor(love.timer.getTime()) % 3 == 1 then
                love.graphics.printf('Loading..', VIRTUAL_WIDTH - 70, VIRTUAL_HEIGHT - 20, VIRTUAL_WIDTH, 'left')
            elseif math.floor(love.timer.getTime()) % 3 == 2 then
                love.graphics.printf('Loading...', VIRTUAL_WIDTH - 70, VIRTUAL_HEIGHT - 20, VIRTUAL_WIDTH, 'left')
            end
        end

        love.graphics.setFont(fonts['largemenuFont'])
        love.graphics.printf('AVOID THE VIRUS', 0, 25, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('SURVIVE AS LONG AS YOU CAN', 0, 75, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('YOU ARE NOT ALONE', 0, 175, VIRTUAL_WIDTH, 'center')

        love.graphics.setFont(fonts['menuFont'])
        love.graphics.printf('WASD or arrow keys to move', 0, 50, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Watch your health!', 0, 100, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('The lower your health the slower you get', 0, 125, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('It\'s game over when your HP reaches 0', 0, 150, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Catch the green crosses! They heal you', 0, 200, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        music['cover_theme']:stop()

        if music_on == true then
            music['play_theme']:setVolume(0.7)
            music['play_theme']:play()
        elseif music_on == false then
            music['play_theme']:setVolume(0)
        end

        love.graphics.draw(graphics['play_area'], 0, 0)
        love.graphics.draw(graphics['sidebar'], PLAY_WIDTH, 0)
        love.graphics.draw(buttons['pause_button'], 1110 * 432 / 1280, 634 * 243 / 720)

        if sfx_on == true then
            love.graphics.draw(buttons['sfx_on'], 1110 * 432 / 1280, 572 * 243 / 720)
        elseif sfx_on == false then
            love.graphics.draw(buttons['sfx_off'], 1110 * 432 / 1280, 572 * 243 / 720)
        end
        if music_on == true then
            love.graphics.draw(buttons['music_on'], 1187 * 432 / 1280, 572 * 243 / 720)
        elseif music_on == false then
            love.graphics.draw(buttons['music_off'], 1187 * 432 / 1280, 572 * 243 / 720)
        end

        -- character, heal, and projectile rendering
        playChar:render()
        for i,v in ipairs(bullets) do
            v:render()
        end
        for i,v in ipairs(heals) do
            v:render()
            if sfx_on == true then
                sfx['active_heal']:play()
            end
        end

        love.graphics.setFont(fonts['baseFont'])
        if score <= 3 then
            love.graphics.printf('SURVIVE!', 0, 30, PLAY_WIDTH, 'center')
        end
        if dec_spawn <= 3 then
            love.graphics.print('Phase ' .. tostring(phase), VIRTUAL_WIDTH / 2 - 54, 50)
        end

        -- sidebar menu
        love.graphics.print('Life: ' .. tostring(hp), PLAY_WIDTH + 5, 10)
        love.graphics.print('Time: ' .. tostring(score), PLAY_WIDTH + 5, 40)
        love.graphics.print('Phase: ' .. tostring(phase), PLAY_WIDTH + 5, 70)
        love.graphics.printf('"M"-mute', PLAY_WIDTH, 150, VIRTUAL_WIDTH - PLAY_WIDTH, 'center')
        love.graphics.printf('"P"-pause', PLAY_WIDTH, 170, VIRTUAL_WIDTH - PLAY_WIDTH, 'center')
    elseif gameState == 'pause' then
        music['play_theme']:pause()

        love.graphics.draw(graphics['paused'], 0, 0)

        love.graphics.setFont(fonts['baseFont'])
        love.graphics.printf('PAUSED', 0 , VIRTUAL_HEIGHT / 2 - 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press "P" to resume', 0, VIRTUAL_HEIGHT / 2 + 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press "esc" to go back to the Main Menu', 0, VIRTUAL_HEIGHT - 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'dead' then
        music['play_theme']:stop()

        love.graphics.draw(graphics['defeat'], 0, 0)

        love.graphics.setFont(fonts['baseFont'])
        love.graphics.print('Survived for ' .. tostring(score) .. ' seconds', VIRTUAL_WIDTH / 2 - 85, VIRTUAL_HEIGHT / 2)
        love.graphics.printf('Press "enter" to go back to go back to the Main Menu', 0, VIRTUAL_HEIGHT - 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press "esc" to exit', 0, VIRTUAL_HEIGHT - 40, VIRTUAL_WIDTH, 'center')
    end

    push:apply('end') -- end formatting
end