Chara = Class{}

-- entity boundary error margin
local border_guide = 11

function Chara:init(x, y)
    charSprites = {
        ['1'] = love.graphics.newImage('graphics/player/excellent.png'),
        ['2'] = love.graphics.newImage('graphics/player/great.png'),
        ['3'] = love.graphics.newImage('graphics/player/good.png'),
        ['4'] = love.graphics.newImage('graphics/player/bad.png'),
        ['5'] = love.graphics.newImage('graphics/player/worse.png'),
        ['6'] = love.graphics.newImage('graphics/player/dying.png')
    }
    self.x = x
    self.y = y
    self.width = 0.05
    self.height = 0.05

    self.dx = 0
    self.dy = 0
end

function Chara:update(dt)
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    elseif self.dy > 0 then
        self.y = math.min(VIRTUAL_HEIGHT - border_guide, self.y + self.dy * dt)
    end

    if self.dx < 0 then
        self.x = math.max(0, self.x + self.dx * dt)
    elseif self.dx > 0 then
        self.x = math.min(PLAY_WIDTH - border_guide, self.x + self.dx * dt)
    end
end

function Chara:render() -- character sprite changes depending on current health
    if hp >= 100 then
        love.graphics.draw(charSprites['1'], self.x, self.y, 0, self.width, self.height)
    elseif hp >= 80 then
        love.graphics.draw(charSprites['2'], self.x, self.y, 0, self.width, self.height)
    elseif hp >= 60 then
        love.graphics.draw(charSprites['3'], self.x, self.y, 0, self.width, self.height)
    elseif hp >= 40 then
        love.graphics.draw(charSprites['4'], self.x, self.y, 0, self.width, self.height)
    elseif hp >= 20 then
        love.graphics.draw(charSprites['5'], self.x, self.y, 0, self.width, self.height)
    else
        love.graphics.draw(charSprites['6'], self.x, self.y, 0, self.width, self.height)
    end
end