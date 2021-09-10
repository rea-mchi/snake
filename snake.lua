local love = love
local utils = require("utils")
local playArea = require("conf").play.bound
local cellSize = require("conf").global.cellSize
local snake = require("conf").play.snake
local initPos = utils.cellPos(snake.initPos, cellSize)

local _M = {}
local mt = { __index = _M }

function _M:new()
  return setmetatable(
    {
      headPos = {initPos[1], initPos[2]},
      bodyPos = {},
      bodyLength = 0,
      direction = {0,-1},
      unitTime = snake.initUnitTime,
      timer = 0,
      headColor = snake.headColor,
      bodyColor = snake.bodyColor
    },
    mt
  )
end

function _M:getCurrentBodyLength() return self.bodyLength end

function _M:move(dt)
  if self.timer < self.unitTime then
    self.timer = self.timer + dt
    do return false end
  end

  self.timer = 0
  table.insert(self.bodyPos, 1, self.headPos[2])
  table.insert(self.bodyPos, 1, self.headPos[1])
  table.remove(self.bodyPos)
  table.remove(self.bodyPos)
  self.headPos[1] = self.headPos[1] + self.direction[1] * cellSize
  self.headPos[2] = self.headPos[2] + self.direction[2] * cellSize
  do return true end
end

local function turnup(len, direction)
  if len > 0 and direction[2] == 1 then
    do return end
  end
  direction[1] = 0
  direction[2] = -1
end

local function turndown(len, direction)
  if len > 0 and direction[2] == -1 then
    do return end
  end
  direction[1] = 0
  direction[2] = 1
end

local function turnleft(len, direction)
  if len > 0 and direction[1] == 1 then
    do return end
  end
  direction[1] = -1
  direction[2] = 0
end

local function turnright(len, direction)
  if len > 0 and direction[1] == -1 then
    do return end
  end
  direction[1] = 1
  direction[2] = 0
end

local inputTbl = {
  ["up"] = turnup,
  ["down"] = turndown,
  ["left"] = turnleft,
  ["right"] = turnright
}

function _M:input(key)
  if inputTbl[key] then
    inputTbl[key](self.bodyLength, self.direction)
  end
end

local function tailDirection(self)
  local bodyPos = self.bodyPos
  local num = #bodyPos
  if num < 2 then do return end end
  local last = {bodyPos[num-1],bodyPos[num]}
  local prelast = nil
  if num < 4 then
    prelast = {self.headPos[1], self.headPos[2]}
    else prelast = {bodyPos[num-3], bodyPos[num-2]}
  end

  local nom = utils.twodimNormalize({last[1] - prelast[1], last[2] - prelast[2]})

  return nom
end

local limitLen = 40 / (1 - snake.minUnitTimeRatio) -- set 40 as max allowed len

local function updateSpeed(self)
  self.unitTime = (1-self.bodyLength/limitLen)*snake.initUnitTime
end

function _M:grow()
  local num = #(self.bodyPos)
  local direction = nil
  local last = nil
  if num == 0 then
    direction = { -self.direction[1], -self.direction[2] }
    last = {self.headPos[1], self.headPos[2]}
    else
      direction = tailDirection(self)
      last = {self.bodyPos[num-1], self.bodyPos[num]}
  end
  local newX = last[1] + direction[1] * cellSize
  local newY = last[2] + direction[2] * cellSize
  -- check whether tail out of screen
  if newX < playArea.left  or newX + cellSize > playArea.right then
    newX = last[1]
    newY = last[2] + cellSize
    if newY > playArea.bottom then
      newY = last[2] - cellSize
    end
  end

  if newY < playArea.top  or newY + cellSize > playArea.bottom then
    newY = last[2]
    newX = last[1] + cellSize
    if newX > playArea.right then
      newX = last[1] - cellSize
    end
  end

  table.insert(self.bodyPos, newX)
  table.insert(self.bodyPos, newY)
  self.bodyLength = self.bodyLength + 1
  updateSpeed(self)
end

local function drawHead(self)
  local headPos = self.headPos
  local color = self.headColor
  local r,g,b = utils.convertRGB(color)
  love.graphics.setColor(r,g,b)
  local radius = cellSize / 2 - 1 --留出间隙
  local centerX = headPos[1] + cellSize / 2
  local centerY = headPos[2] + cellSize / 2
  love.graphics.circle("fill", centerX, centerY, radius)
end

local function drawBody(self)
  local bodyPos = self.bodyPos
  local num = #bodyPos
  if num < 4 then do return end end
  local color = self.bodyColor
  local r,g,b = utils.convertRGB(color)
  love.graphics.setColor(r,g,b)
  for i = 1, num-3, 2 do
    love.graphics.rectangle("fill", bodyPos[i]+1, bodyPos[i+1]+1, cellSize-2, cellSize-2)
  end
end

local function drawTail(self)
  local num = #(self.bodyPos)
  if num < 2 then do return end end
  local color = self.bodyColor
  local r,g,b = utils.convertRGB(color)
  love.graphics.setColor(r,g,b)

  local vertices
  local direction = tailDirection(self)
  local pos = {self.bodyPos[num-1] + 1, self.bodyPos[num] + 1} -- +1为了制造空隙
  local width = cellSize - 2
  if direction[1] < 0 then
    -- left
    vertices = { pos[1], pos[2] + width / 2,
    pos[1] + width, pos[2],
    pos[1] + width, pos[2] + width }
    elseif direction[1] > 0 then
      -- right
      vertices = { pos[1], pos[2],
      pos[1], pos[2] + width,
      pos[1] + width, pos[2] + width / 2 }
      elseif direction[2] > 0 then
        -- down
        vertices = { pos[1], pos[2],
        pos[1] + width, pos[2],
        pos[1] + width / 2, pos[2] + width }
        else
          -- up
          vertices = { pos[1], pos[2] + width,
          pos[1] + width, pos[2] + width,
          pos[1] + width / 2, pos[2] }
  end
  love.graphics.polygon("fill", vertices)
end

function _M:draw()
  drawBody(self)
  drawTail(self)
  drawHead(self)
end

function _M:reset()
  self.headPos = {initPos[1], initPos[2]}
  self.bodyPos = {}
  self.bodyLength = 0
  self.direction = {0,-1}
  self.unitTime = snake.initUnitTime
  self.timer = 0
end

function _M:posTbl()
  local head = self.headPos
  local body = self.bodyPos
  local len = self.bodyLength
  local posTbl = {
    head = { math.floor(head[1]/cellSize), math.floor(head[2]/cellSize) },
    body = {}
  }
  for i = 1, len, 1 do
    local x = math.floor(body[2*i-1]/cellSize)
    local y = math.floor(body[2*i]/cellSize)
    if not posTbl.body[x] then
      posTbl.body[x] = {}
    end
    posTbl.body[x][y] = true
  end

  return posTbl
end



return _M