pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- maze

_tt = 0
grids = {}
grid_size = 6
maze_width = 18
maze_height = 18
offset_x = 0
offset_y = 0
wall_color = 1

map_width = grid_size * maze_width
map_height = grid_size * maze_height

user_pos = { 1, 1 }
destination_pos = { maze_width, maze_height }
is_user_moving = false
user_move_v = { 0, 0 }
user_move_delta = { 0, 0 }
user_to_pos = { 0, 0 }

is_win = false
ignore_btn = 0

function log(msg)
  printh(msg, 'log')
end

function initMap()
  log('-----------------------')
  is_win = false

  offset_x = flr((128 - map_width) / 2)
  offset_y = flr((128 - map_height) / 2)

  local maze_size = maze_width * maze_height
  for i = 1, maze_size do
    grids[i] = 0
  end

  user_pos = { 1, 1 }
  destination_pos = { maze_width, maze_height }

  function _isMazeFinished()
    for i = 1, #grids do
      if grids[i] == 0 then
        return false
      end
    end
    return true
  end

  function _isWildGrid(x, y)
    return grids[(y - 1) * maze_width + x] == 0
  end

  function _getNeighbors(x, y)
    local neighbors = {}

    -- up
    if y == 1 or _isWildGrid(x, y - 1) == false then
      add(neighbors, 0)
    else
      add(neighbors, 1)
    end

    -- right
    if x == maze_width or _isWildGrid(x + 1, y) == false then
      add(neighbors, 0)
    else
      add(neighbors, 1)
    end

    -- down
    if y == maze_height or _isWildGrid(x, y + 1) == false then
      add(neighbors, 0)
    else
      add(neighbors, 1)
    end

    -- left
    if x == 1 or _isWildGrid(x - 1, y) == false then
      add(neighbors, 0)
    else
      add(neighbors, 1)
    end

    return neighbors
  end

  function _walkFromTo(direction, x1, y1, x2, y2)
    local i = (y1 - 1) * maze_width + x1
    grids[i] = bor(grids[i], direction)

    d2 = ({4, 8, 0, 1, 0, 0, 0, 2})[direction]
    i = (y2 - 1) * maze_width + x2
    grids[i] = bor(grids[i], d2)
    log('walk from ' .. x1 .. ',' .. y1 .. ' to ' .. x2 .. ',' .. y2)
  end

  function _walkFrom(x, y)
    local history = {}
    local steps = 10

    for i = 1, steps do
      log('step: ' .. i .. ' : ' .. x .. ',' .. y)
      local n = _getNeighbors(x, y)
      log('neighbors: ' .. n[1] .. n[2] .. n[3] .. n[4])
      if n[1] + n[2] + n[3] + n[4] == 0 then
        if #history == 0 then
          return
        end
        g = history[#history]
        x = g[1]
        y = g[2]
        del(history, history[#history])
      else
        local g = false
        repeat
          d0 = flr(rnd(4)) + 1
          if n[d0] == 1 then
            g = true
          end
        until g == true

        add(history, { x, y })
        log('work direction-0: ' .. d0)
        if d0 == 1 then
          _walkFromTo(1, x, y, x, y - 1)
          y -= 1
        elseif d0 == 2 then
          _walkFromTo(2, x, y, x + 1, y)
          x += 1
        elseif d0 == 3 then
          _walkFromTo(4, x, y, x, y + 1)
          y += 1
        elseif d0 == 4 then
          _walkFromTo(8, x, y, x - 1, y)
          x -= 1
        end
      end
    end
  end

  function _getOneStartGrid()
    local valid_grids = {}
    for y = 1, maze_height do
      for x = 1, maze_width do
        if _isWildGrid(x, y) == false then
          n = _getNeighbors(x, y)
          if n[1] + n[2] + n[3] + n[4] ~= 0 then
            add(valid_grids, { x, y })
          end
        end
      end
    end

    if #valid_grids == 0 then
      return nil
    end

    r = flr(rnd(#valid_grids)) + 1
    return valid_grids[r]
  end

  local pos = { 1, 1 }
  repeat
    _walkFrom(pos[1], pos[2])
    pos = _getOneStartGrid()
  until pos == nil
end

function renderMap()
  for y = 1, maze_height do
    for x = 1, maze_width do
      g = grids[(y - 1) * maze_width + x]
      x0 = (x - 1) * grid_size + offset_x
      y0 = (y - 1) * grid_size + offset_y
      -- log('render:'..x..','..y..':'..g[1]..g[2]..g[3]..g[4])
      if band(g, 1) == 0 then
        line(x0, y0, x0 + grid_size, y0, wall_color)
      end
      if band(g, 2) == 0 then
        line(x0 + grid_size, y0, x0 + grid_size, y0 + grid_size, wall_color)
      end
      if band(g, 4) == 0 then
        line(x0, y0 + grid_size, x0 + grid_size, y0 + grid_size, wall_color)
      end
      if band(g, 8) == 0 then
        line(x0, y0, x0, y0 + grid_size, wall_color)
      end
    end
  end
end

function renderUser()
  x = flr((user_pos[1] - 1) * grid_size) + user_move_delta[1] + offset_x
  y = flr((user_pos[2] - 1) * grid_size) + user_move_delta[2] + offset_y
  -- rectfill(x + 2, y + 2, x + grid_size - 2, y + grid_size - 2, 8)
  t = flr(_tt / 10)
  if is_win or t % 2 == 0 then
    t = 2
  else
    t = 3
  end
  spr(t, x, y)
end

function renderDestination()
  x = flr((destination_pos[1] - 1) * grid_size) + offset_x
  y = flr((destination_pos[2] - 1) * grid_size) + offset_y
  -- r = flr(grid_size / 2) - 1
  -- circfill(x + r + 1, y + r + 1, r, 3)
  spr(1, x, y)
end

function renderWin()
  if is_win == false then
    return
  end

  local h = 84
  if ignore_btn > 0 then
    h = 74
  end
  rectfill(0, 44, 127, h, 3)
  spr(17, 32, 56, 8, 1)

  if ignore_btn <= 0 then
    spr(33, 16, 68, 12, 1)

    for i = 0, 5 do
      if btnp(i) then
        ignore_btn = 30
        initMap()
      end
    end
  end
end

function movemap()
  local step = 1
  if btn(0) then
    offset_x += step
  elseif btn(1) then
    offset_x -= step
  elseif btn(2) then
    offset_y += step
  elseif btn(3) then
    offset_y -= step
  end
end

function _doUserMoving()
  -- log('pos:'..user_pos[1]..','..user_pos[2]..';'..user_to_pos[1]..';'..user_to_pos[2])

  local function match()
    return user_pos[1] + user_move_delta[1] / grid_size == user_to_pos[1] and
      user_pos[2] + user_move_delta[2] / grid_size == user_to_pos[2]
  end

  if match() then
    is_user_moving = false
    user_move_delta = {0, 0}
    user_pos[1] = user_to_pos[1]
    user_pos[2] = user_to_pos[2]
    return
  end

  user_move_delta[1] += user_move_v[1]
  user_move_delta[2] += user_move_v[2]
end

function moveUser()
  if is_user_moving then
    _doUserMoving()
    return
  end

  if is_win then
    return
  end

  x = user_pos[1]
  y = user_pos[2]

  if x == destination_pos[1] and y == destination_pos[2] then
    is_win = true
    ignore_btn = 60
    return
  end

  g = grids[(y - 1) * maze_width + x]
  local v = 1

  if btn(0) and band(g, 8) ~= 0 then
    -- left
    -- user_pos[1] -= 1
    is_user_moving = true
    user_move_v = { -v, 0 }
    user_to_pos = { x - 1, y }
  elseif btn(1) and band(g, 2) ~= 0 then
    -- right
    -- user_pos[1] += 1
    is_user_moving = true
    user_move_v = { v, 0 }
    user_to_pos = { x + 1, y }
  elseif btn(2) and band(g, 1) ~= 0 then
    -- up
    -- user_pos[2] -= 1
    is_user_moving = true
    user_move_v = { 0, -v }
    user_to_pos = { x, y - 1 }
  elseif btn(3) and band(g, 4) ~= 0 then
    -- down
    -- user_pos[2] += 1
    is_user_moving = true
    user_move_v = { 0, v }
    user_to_pos = { x, y + 1 }
  end
end

function move_enemy()
	-- move enemy
 	if x < ex then
  	ex -= d
 	end
 	if x > ex then
  	ex += d
 	end
 	if y < ey then
  	ey -= d
 	end
 	if y > ey then
  	ey += d
 	end
end

function check_enemy_col(ax,ay,bx,by)
 	if bx+6>ax and bx<ax+6 and by+6>ay and by<ay+6 then
  	return true
 	else
  	return false
 	end
end

function _init()
  initMap()
  -- enemy start location
 ex = 100
 ey = 10
 -- enemy "speed"
 d = 0.25
end


function _update()
  _tt += 1
  _tt = _tt % 10000
  -- movemap()

  if ignore_btn > 0 then
    ignore_btn -= 1
  else
    moveUser()
  end
 
  move_enemy()
  
  -- check for enemy player collision
 	if check_enemy_col(x,y,ex,ey) then
  	stop()
  	
 	end
end

function _draw()
  rectfill(0, 0, 128, 128, 0)
  renderMap()
  renderDestination()
  renderUser()
  renderWin()
  --draw enemy
  spr(4,ex,ey)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000aaa0000007770000077700004444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000afffa00007fff70007fff70004040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004f40000002f2000002f200004444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000fff000000fff00000fff00044000440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000e0e000000c0c000000c000004040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000004444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000004004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000070000700077770007000070000000000700000700077700070000700007000000000000000000000000000000000000000000000000000000000000
00000000070000700700007007000070000000000700700700007000077000700007000000000000000000000000000000000000000000000000000000000000
00000000007007000700007007000070000000000700700700007000070700700007000000000000000000000000000000000000000000000000000000000000
00000000000770000700007007000070000000000700700700007000070070700007000000000000000000000000000000000000000000000000000000000000
00000000000770000700007007000070000000000707070700007000070007700000000000000000000000000000000000000000000000000000000000000000
00000000000770000077770000777700000000000770007700077700070000700007000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000660066006660066006600060066006600060060006060606660606006660666000660060060060666060600606060666000000000000000000000000
00000000606060606000600060000666060606060606060606060606000606000600606006000606060060060060600606060600000000000000000000000000
00000000606060606660060006000606060606060606060606066006660606000600606006000606066060060060660606060666000000000000000000000000
00000000660066006000006000600666066006600606066066060606000060000600606006000606060660060060606606060600000000000000000000000000
00000000600060606660660066000606060606060060060006060606660060000600666000660060060060060060600600660666000000000000000000000000
