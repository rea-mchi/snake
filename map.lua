local conf = require("conf")
local playArea = conf.play.bound
local cellSize = conf.global.cellSize
local item = require("item")

local _M = {}

local itemId = 1
local idTbl = {}
local items = {}
local itemsPos = {}

local function checkNotOutOfArea(bb)
  return bb.left >= playArea.left
          and bb.top >= playArea.top
          and bb.right <= playArea.right
          and bb.bottom <= playArea.bottom
end

local function checkNotCollideSelf(posTbl)
  local headPos = posTbl.head
  return not ( posTbl.body[headPos[1]] ~= nil and posTbl.body[headPos[1]][headPos[2]] )
end

local function updateNewPos(item, posTbl)
  -- handle portal
  if item.brother ~= nil then
    local bro = item.brother
    bro.brother = nil
    item.brother = nil
    updateNewPos(item, posTbl)
    updateNewPos(bro, posTbl)
    item.brother = bro
    bro.brother = item
    do return end
  end

  local dim = item.dim
  idTbl[item.id] = false
  local notUpdate = true
  while notUpdate do
    -- playarea padding = 1 cellsize
    local x = math.random(playArea.left + cellSize, playArea.right - cellSize - dim[1])
    local y = math.random(playArea.top + cellSize, playArea.bottom - cellSize - dim[2])
    -- check overlap with snake or existing item
    local head = posTbl.head
    local body = posTbl.body
    local cellBB = {
      math.floor(x/cellSize),
      math.floor(y/cellSize),
      math.floor((x+dim[1])/cellSize),
      math.floor((y+dim[2])/cellSize)
    }
    for hor = cellBB[1], cellBB[3] do
      for ver = cellBB[2], cellBB[4] do
        if hor == head[1] and ver == head[2] then goto continue end
        if body[hor] ~= nil and body[hor][ver] then goto continue end
        if itemsPos[hor] ~=nil then
          local id = itemsPos[hor][ver]
          if id ~= nil and idTbl[id] then goto continue end
        end
      end
    end

    item.id = itemId
    idTbl[itemId] = true
    itemId = itemId + 1
    for hor = cellBB[1], cellBB[3] do
      for ver = cellBB[2], cellBB[4] do
        if not itemsPos[hor] then itemsPos[hor] = {} end
        itemsPos[hor][ver] = item.id
      end
    end
    item:refresh(x,y)
    notUpdate = false

    ::continue::
    if notUpdate then print("Overlap happened") end
  end
end

local function addItem(item)
  item.isVisible = false
  item.timer = item.duration + 1
  item.id = itemId
  idTbl[itemId] = true
  table.insert(items, item)
  itemId = itemId + 1
end

function _M.checkSnakeAndUpdate(posTbl, dt)
  local head = posTbl.head
  local headBB = {
    left = head[1] * cellSize, top = head[2] * cellSize,
    right = head[1] * cellSize + cellSize, bottom = head[2] * cellSize + cellSize
  }

  local checkRes = checkNotOutOfArea(headBB) and checkNotCollideSelf(posTbl)

  local collisionCallback = nil
  for _, item in ipairs(items) do
    if not item.isVisible then goto continue end
    if item:checkCollisionHappen(headBB) then
      collisionCallback = item:collisionCallback()
      if item.collisionUpdate then updateNewPos(item, posTbl) end
      break
    end

    ::continue::
  end

  for _, item in ipairs(items) do
    item:update(dt)
    if item.timer > item.duration then
      updateNewPos(item, posTbl)
    end
  end

  return checkRes, collisionCallback
end

function _M.draw()
  for _, item in ipairs(items) do
    item:draw()
  end
end

local levelItemTbl = conf.play.level.levelItemList

function _M.init()
  _M.updateLevel(1)
end

function _M.updateLevel(level)
  local itemTbl = levelItemTbl[level]
  assert(itemTbl ~= nil, "incorrect level converted to map")
  itemId = 1
  idTbl = {}
  items = {}
  itemsPos = {}
  for _, value in ipairs(itemTbl) do
    if value == "apple" then
      local apple = item.apple:new()
      addItem(apple)
      elseif value == "block" then
        local obstacle = item.obstacle:new()
        addItem(obstacle)
        elseif value == "portal" then
          local portal = item.portal:new()
          local portal2 = item.portal:new()
          portal.brother = portal2
          portal2.brother = portal
          addItem(portal)
          addItem(portal2)
          else
            assert(false, "wrong item name in tbl.")
    end
  end
end

function _M.refreshItems(posTbl)
  for _ , item in ipairs(items) do
    updateNewPos(item, posTbl)
  end
end

return _M