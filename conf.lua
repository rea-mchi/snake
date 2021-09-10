local _M = {
  global = {
    width = 1500,
    height = 1000,
    title = "Snake game",
    cellSize = 20
  },
  ui = {
    score = {
      pos = {10,10},
      format = "SCORE: %d"
    },
    maxScore = {
      pos = {1000,10},
      format = "HIGHEST SCORE: %d"
    },
    level = {
      pos = {600,10},
      format = "LEVEL %d"
    },
    separateLine = {
      points = {0,50,1500,50},
      width = 5
    },
    hintOutlineWidth = 5,
    startHint = {
      pos = {500, 500},
      hint = "Press any button to start!"
    },
    pauseHint = {
      pos = {300, 300},
      dim = {900, 400},
      hintPos = {400, 500},
      hint = "Press ESC to restore game. Or press Q to leave."
    },
    gameOverHint = {
      pos = {300, 300},
      dim = {900, 400},
      hintPos = {400, 500},
      hint = "Game Over. Press Space to play again."
    },
    levelUpHint = {
      pos = {300, 300},
      dim = {900, 400},
      hintPos = {400, 500},
      hint = "Conguratulation! Press any button to go to next Level!"
    },
    ClearHint = {
      pos = {10,10},
      hint = "Congulatulation you clear this game! You can Q to leave."
    }
  },
  play = {
    bound = {left = 0, top = 60, right = 1500, bottom = 1000},
    snake = {
      initPos = {700, 600},
      headColor = {144,252,3},
      bodyColor = {35,118,150},
      initUnitTime = .1,
      minUnitTimeRatio = .25
    },
    level = {
      maxLevel = 3,
      levelUpBodyLen = {
        [1] = 25, [2] = 30, [3] = 40
      },
      levelItemList = {
        [1] = {"apple", "block"},
        [2] = {"apple", "block", "block", "portal"},
        [3] = {"apple", "apple", "block", "block", "block", "portal"}
      }
    }
  }
}

function love.conf(tbl)
  tbl.window.width = _M.global.width
  tbl.window.height = _M.global.height
  tbl.window.title = _M.global.title
end

return _M