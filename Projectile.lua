Projectile = Class{}

--entity boundary error margin
local ERROR_MARGIN = 10

function Projectile:init(x, y, dx, dy)
    self.sprite = love.graphics.newImage('graphics/virus.png')
    self.x = x
    self.y = y
    self.width = 0.05
    self.height = 0.05

    self.dx = dx
    self.dy = dy
end

function Projectile:update(dt)
    self.y = self.y + self.dy * dt
    self.x = self.x + self.dx * dt
end

function Projectile:collision(player)
    local bulLeft = self.x
    local bulRight = self.x + self.width + ERROR_MARGIN
    local bulTop = self.y
    local bulBot = self.y + self.height + ERROR_MARGIN

    local playLeft = player.x
    local playRight = player.x + player.width + ERROR_MARGIN
    local playTop = player.y
    local playBot = player.y + player.height + ERROR_MARGIN

    --axis-aligned bounding boxes
    if bulRight > playLeft and 
    bulLeft < playRight and
    bulBot > playTop and
    bulTop < playBot then
        self.dead = true
    end
end

function Projectile:border() --despawn the entity when it goes of bounds
    if self.x > PLAY_WIDTH - 5 or
    self.x < -10 or
    self.y > VIRTUAL_HEIGHT or
    self.y < -10 then 
        self.frame = true
    end
end

function Projectile:render()
    love.graphics.draw(self.sprite, self.x, self.y, 0, self.width, self.height)
end