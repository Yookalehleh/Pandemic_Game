Heal = Class{}

-- entity boundary error margin
local ERROR_MARGIN = 10

function Heal:init(x, y, dx, dy)
    self.sprite = love.graphics.newImage('graphics/heal.png')
    self.x = x
    self.y = y
    self.width = 0.05
    self.height = 0.05

    self.dx = dx
    self.dy = dy
end

function Heal:update(dt)
    self.y = self.y + self.dy * dt
    self.x = self.x + self.dx * dt
end

function Heal:collision(player)
    local hLeft = self.x
    local hRight = self.x + self.width + ERROR_MARGIN
    local hTop = self.y
    local hBot = self.y + self.height + ERROR_MARGIN

    local playLeft = player.x
    local playRight = player.x + player.width + ERROR_MARGIN
    local playTop = player.y
    local playBot = player.y + player.height + ERROR_MARGIN

    -- axis-aligned bounding boxes
    if hRight > playLeft and 
    hLeft < playRight and
    hBot > playTop and
    hTop < playBot then
        self.healed = true
    end
end

function Heal:border() -- despawn the entity when it goes out of bounds
    if self.x > PLAY_WIDTH - 5 or
    self.x < -10 or
    self.y > VIRTUAL_HEIGHT or
    self.y < -10 then 
        self.frame = true
    end
end

function Heal:render()
    love.graphics.draw(self.sprite, self.x, self.y, 0, self.width, self.height)
end