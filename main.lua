local ui = require("ui")
local snake = require("snake")
local core = require("core")
local stateEnum = core.GameState
local map = require("map")
local levelUpTbl = require("conf").play.level.levelUpBodyLen

local mySnake = nil

function love.load()
  math.randomseed(os.time())

  core.init()

  love.graphics.setFont(love.graphics.newFont(28))

  mySnake = snake:new()

  map.init()
end

local function notifyLevelUp()
  core.levelUp()
  if core.getCurrentState() == stateEnum.Pass then do return end end
  mySnake:reset()
  map.updateLevel(core.getCurrentLevel())
end

function love.update(dt)
  local state = core.getCurrentState()

  if state == stateEnum.Run then
    if mySnake:move(dt) then
      local posTbl = mySnake:posTbl()
      local safe, callback = map.checkSnakeAndUpdate(posTbl, dt)
      if not safe then
        core.GameOver()
      end
      if callback then
        callback(mySnake, core)
        if mySnake:getCurrentBodyLength() >= levelUpTbl[core.getCurrentLevel()] then
          notifyLevelUp()
        end
      end
    end
  end
end

function love.draw()
  local curState = core.getCurrentState()
  if curState ~= stateEnum.Welcome and curState ~= stateEnum.Levelup then
    map.draw()
  end
  mySnake:draw()
  local level = core.getCurrentLevel()
  if curState == stateEnum.Levelup then level = level - 1 end
  ui.draw(
    curState,
    core.getCurrentScore(),
    core.getCurrentMaxScore(),
    level
  )
end

function love.keypressed(key)
  local curState = core.getCurrentState()

  if key == "escape" then
    if curState == stateEnum.Pause then
      core.restoreGame()
      elseif  curState == stateEnum.Run then
      core.pause()
    end
    do return end
  end

  if key == "q" and ( curState == stateEnum.Pause or curState == stateEnum.Pass ) then
    local co = core.EndGame()
    while co and coroutine.status(co) ~= "dead" do
    end
    love.event.quit(0)
    do return end
  end

  if key == "space" and curState == stateEnum.GameOver then
    mySnake:reset()
    map.refreshItems(mySnake:posTbl())
    core.startGame()
    do return end
  end

  if key == "up" or key == "down" or key == "left" or key == "right" then
    if curState == stateEnum.Run then 
      mySnake:input(key)
      do return end
    end
  end

  if curState == stateEnum.Welcome or curState == stateEnum.Levelup then
    core.startGame(false)
    do return end
  end

  -- -- test
  -- if key == "space" and curState == state.Run then
  --   mySnake:grow()
  --   do return end
  -- end
end