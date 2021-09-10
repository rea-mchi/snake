local love = love
local utils = require("utils")

local base = {
  isVisible = false,
  collisionUpdate = true
}

-- 检查传入的2D包围盒是否和当前物体有碰撞
-- @param bb 记录left, top, right, bottom
function base:checkCollisionHappen(bb)
  local selfBB = utils.boundingBox(self.pos, self.dim)
  return not (
    selfBB.right < bb.left
    or selfBB.left > bb.right
    or selfBB.bottom < bb.top
    or selfBB.top > bb.bottom
  )
end

function base:update(dt)
  self.timer = self.timer + dt
  if self.timer > 0.75*self.duration then
    self.isVisible = not self.isVisible
  end
end

function base:draw()
  if not self.isVisible then
    do return end
  end

  local r,g,b = utils.convertRGB(self.color)
  love.graphics.setColor(r,g,b)
  love.graphics.rectangle("fill", self.pos[1], self.pos[2], self.dim[1], self.dim[2])
end

function base:refresh(posX, posY)
  self.pos[1] = posX
  self.pos[2] = posY
  self.isVisible = true
  self.timer = 0
end

local apple = setmetatable({},{ __index = base })
local mt_apple = { __index = apple }

local obstacle = setmetatable({}, { __index = base })
local mt_obstale = { __index = obstacle }

local portal = setmetatable({}, { __index = base })
local mt_portal = { __index = portal }

function apple:new()
  local radius = 15
  return setmetatable(
    {
      pos = {0, 0},
      dim = {2*radius, 2*radius},
      color = {255, 51, 0},
      duration = 4,
      timer = 12,
      radius = radius
    },
    mt_apple
  )
end

function apple:draw()
  if not self.isVisible then
    do return end
  end

  local r,g,b = utils.convertRGB(self.color)
  love.graphics.setColor(r,g,b)
  local centerX = self.pos[1] + self.radius
  local centerY = self.pos[2] + self.radius
  love.graphics.circle("fill", centerX, centerY, self.radius)
  love.graphics.setColor(1,1,1) --white light
  love.graphics.circle("fill", centerX + 0.5*self.radius, centerY - 0.5*self.radius, 0.2*self.radius)
end

function obstacle:new()
  local hor = math.random(2) == 1 -- 1:horizontal 2:vertical
  local dim = nil
  if hor then dim = {100,40} else dim = {40,100} end
  return setmetatable(
    {
      pos = {0,0},
      dim = dim,
      color = {255,255,255},
      duration = 10,
      timer = 11,
      collisionUpdate = false
    },
    mt_obstale
  )
end

function portal:new()
  local raidus = 24
  return setmetatable(
    {
      pos = {0,0},
      dim = {raidus*2, raidus*2},
      radius = raidus,
      minRadius = 4,
      circleCount = 5,
      currentCircle = 0,
      color = {124, 53, 240},
      duration = 15,
      timer = 0,
      brother = nil
    },
    mt_portal
  )
end

function portal:draw()
  local outerRadius =
    self.minRadius + (self.radius - self.minRadius) / self.circleCount * (self.currentCircle % self.circleCount + 1)
  self.currentCircle = (self.currentCircle + 1) % self.circleCount
  if self.isVisible then
    local r,g,b = utils.convertRGB(self.color)
    love.graphics.setColor(r,g,b)
    local centerX = self.pos[1] + self.radius
    local centerY = self.pos[2] + self.radius
    love.graphics.circle("fill", centerX, centerY, self.minRadius)
    love.graphics.circle("line", centerX, centerY, outerRadius)
  end
end

function apple:collisionCallback()
  return function (snake, core)
    snake:grow()
    core.earnScore(10)
  end
end

function obstacle:collisionCallback()
  return function (snake, core)
    core.GameOver()
  end
end

function portal:collisionCallback()
  local bro = self.brother
  assert(bro ~= nil, "wrong portal without another.")
  local broCenterX = bro.pos[1] + bro.radius
  local broCenterY = bro.pos[2] + bro.radius
  return function (snake, core)
    snake.headPos[1] = broCenterX
    snake.headPos[2] = broCenterY
  end
end

function obstacle:update(dt)
  do return end
end

local _M = {
  apple = apple,
  obstacle = obstacle,
  portal = portal
}
return _M