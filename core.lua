local maxLevel = require("conf").play.level.maxLevel

local _M = {
  GameState = {
    Welcome = 0,
    Run = 1,
    GameOver = 2,
    Pause = 3,
    Levelup = 4,
    Pass = 5
  },
}

local dataFile = ".scoredata"
local curState = _M.GameState.Welcome
local score = 0
local maxScore = 0
local maxScoreUpdated = false
local level = 1

-- getCurrent
function _M.getCurrentState()
  return curState
end

function _M.getCurrentScore()
  return score
end

function _M.getCurrentMaxScore()
  return maxScore
end

function _M.getCurrentLevel()
  return level
end

-- score IO
local function readMaxScore()
  local read = function ()
    local file = io.open(dataFile, "r")
    if not file then do return end end
    local content = file:read("*n")
    if not content then do return end end
    maxScore = content
    file:close()
  end
  local co = coroutine.create(read)
  coroutine.resume(co)
end

local function saveMaxScore()
  if not maxScoreUpdated then do return end end
  local max = maxScore
  local write = function ()
    local file = io.open(dataFile, "w")
    file:write(max)
    file:flush()
    file:close()
  end
  local co = coroutine.create(write)
  coroutine.resume(co)
  return co
end

-- state change
function _M.init()
  readMaxScore()
  maxScoreUpdated = false
  score = 0
  level = 1
  curState = _M.GameState.Welcome
end

function _M.startGame(clearScores)
  local clear = clearScores
  if clear == nil then clear = true end
  if clear then score = 0 end
  curState = _M.GameState.Run
end

function _M.pause()
  curState = _M.GameState.Pause
end

function _M.restoreGame()
  curState = _M.GameState.Run
end

function _M.levelUp()
  level = level + 1
  if level >   maxLevel then
    curState = _M.GameState.Pass
    else
      curState = _M.GameState.Levelup
  end
end

function _M.earnScore(add)
  assert(add ~= nil)
  score = score + add
end

local function checkMaxScore()
  if score > maxScore then
    maxScore = score
    maxScoreUpdated = true
  end
end

function _M.GameOver()
  curState = _M.GameState.GameOver
  checkMaxScore()
end

function _M.EndGame()
  checkMaxScore()
  return saveMaxScore()
end

return _M