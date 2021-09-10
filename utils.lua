local _M = {}

function _M.convertRGB(rgb_tbl)
  local r,g,b = unpack(rgb_tbl)
  return r/255, g/255, b/255
end

function _M.boundingBox(pos, dim)
  return {
    left = pos[1],
    top = pos[2],
    right = pos[1] + dim[1],
    bottom = pos[2] + dim[2]
  }
end

function _M.twodimNormalize(tbl)
  assert(#tbl == 2)
  local len = math.sqrt(tbl[1] * tbl[1] + tbl[2] * tbl[2])
  if len == 0 then return {0,0} end
  local x = tbl[1] / len
  local y = tbl[2] / len
  return {x,y}
end

function _M.cellPos(rawPos, cellSize)
  local pos = {}
  for index, value in ipairs(rawPos) do
    pos[index] = math.floor(value / cellSize) * cellSize
  end
  return pos
end

return _M