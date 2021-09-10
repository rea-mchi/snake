local love = love
local ui = require("conf").ui
local stateEnum = require("core").GameState

local _M = {}

local function drawScorePanel(score, maxScore, level)
  local scoreConf = ui.score
  love.graphics.setColor(1,1,1) -- white
  love.graphics.print(
    string.format(scoreConf.format, score),
    scoreConf.pos[1],
    scoreConf.pos[2]
  )

  local maxScoreConf = ui.maxScore
  love.graphics.print(
    string.format(maxScoreConf.format, maxScore),
    maxScoreConf.pos[1],
    maxScoreConf.pos[2]
  )

  local levelConf = ui.level
  love.graphics.print(
    string.format(levelConf.format, level),
    levelConf.pos[1],
    levelConf.pos[2]
  )

  local lineConf = ui.separateLine
  love.graphics.setLineWidth(lineConf.width)
  love.graphics.line(lineConf.points)
end

local function drawStartHint()
  local startHintConf = ui.startHint
  love.graphics.print(
    startHintConf.hint,
    startHintConf.pos[1],
    startHintConf.pos[2]
  )
end

local function drawPauseHint()
  local pauseHintConf = ui.pauseHint
  love.graphics.setLineWidth(ui.hintOutlineWidth)
  love.graphics.rectangle(
    "line",
    pauseHintConf.pos[1], pauseHintConf.pos[2],
    pauseHintConf.dim[1], pauseHintConf.dim[2]
  )
  love.graphics.print(
    pauseHintConf.hint,
    pauseHintConf.hintPos[1],
    pauseHintConf.hintPos[2]
  )
end

local function drawGameOverHint()
  local conf = ui.gameOverHint
  love.graphics.setLineWidth(ui.hintOutlineWidth)
  love.graphics.rectangle(
    "line",
    conf.pos[1], conf.pos[2], conf.dim[1], conf.dim[2]
  )
  love.graphics.print( conf.hint, conf.hintPos[1], conf.hintPos[2] )
end

local function drawLevelUpHint()
  local conf = ui.levelUpHint
  love.graphics.setLineWidth(ui.hintOutlineWidth)
  love.graphics.rectangle(
    "line",
    conf.pos[1], conf.pos[2], conf.dim[1], conf.dim[2]
  )
  love.graphics.print( conf.hint, conf.hintPos[1], conf.hintPos[2] )
end

local function drawGameClear()
  local conf = ui.ClearHint
  love.graphics.setColor(1,1,1) -- white
  love.graphics.print(
    conf.hint, conf.pos[1], conf.pos[2])

  local lineConf = ui.separateLine
  love.graphics.setLineWidth(lineConf.width)
  love.graphics.line(lineConf.points)
end

function _M.draw(state, score, maxScore, level)
  if state == stateEnum.Pass then goto gameclear end

  -- assert(score ~= nil and maxScore ~= nil and level ~= nil, "not enough data of current score.")
  drawScorePanel(score, maxScore, level)
  if state == stateEnum.Welcome then
    drawStartHint()
    elseif state == stateEnum.Pause then
      drawPauseHint()
      elseif state == stateEnum.GameOver then
        drawGameOverHint()
      elseif state == stateEnum.Levelup then
        drawLevelUpHint()
  end
  do return end

  ::gameclear::
  drawGameClear()
end

return _M