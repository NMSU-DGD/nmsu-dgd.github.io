pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
gameover=false
points=0
hold=false
initpyratk=1--inipyratk
pyratk=initpyratk--pyratk
pyrslwdwn=.08--pyr decel.
pyrspdmax=1.5--max pyr spd
pyrspdup=.5--pyr accel.
pyrspdx=0--pyr hori. spd
pyrspdy=0--pyr vert. spd
pyrspr=21--pyr sprite
pyrx=50--pyr init x
pyry=64--pyr init y
pyrbltspr=2--pyr blt spr
pyrhp=3--pyr hp
predir="up"
initgametime = 0
gametime = initgametime

efrate=1.5--eny blt rate
initnewebrate=1.3--1hp ebrate
enyspda=.5--eny typ a spd
enyspdb=1.1--eny typ b spd
newebrate=initnewebrate--1hp eny blt rate
enybltspr=18--eny blt sprite
enycolsizea=2--eny typ a collision size
enycolsizeb=6--eny typ b collision size
initesrate=3--init eny spawn rate
esrate=initesrate--eny spawn rate
estimer=0--eny spawn timer
num_enemies=0
num_kills=0

bltcolsize=2--blt collision size
initbltrate=.2--init blt rate of fire
bltrate=initbltrate--blt rate of fire
bltspd=5--blt spd
bltxspd=0
bltyspd=0
blttimer=0--blt spawn timer
enybltspd=1--eny blt spd
maxblt=130-- max # of blts
enybltspr=18

function _init()
 cls(0)
 enemies={} --enys
 bullets={} --blts
 do_intro()
 splash_screen()
end

function _draw()
	cls(0)
	if gameover==true then
  game_over()
 else
  drawstars()
  drawframe()
  pyr_draw()
  eny_draw()
  blt_draw()
  point_draw()
  health_draw()
 end 
end

function _update()
 gametime+=1
 if gametime>900 then
  gameover = true
 end
 collision_check()
 pyr_bounds()
 pyr_move() 
 eny_blt()
 eny_bounds()
 eny_homeatk()
 eny_hpstuff()
 eny_spawn()
 blt_bounds()
 blt_count()
 blt_spawn(true)
end

function drawstars()
 spr(0,67,34)
 spr(0,119,103)
 spr(16,20,53)
 spr(32,26,81)
 spr(0,41,71)
 spr(0,80,48)
 spr(16,31,83)
 spr(32,17,25)
 spr(0,117,115)
 spr(0,100,72)

 spr(0,93,99)
 spr(0,50,24)
 spr(16,32,120)
 spr(32,61,102)
 spr(0,68,101)
 spr(0,90,6)
 spr(16,3,42)
 spr(32,64,110)
 spr(0,73,59)
 spr(0,11,65) 
 
 seconds = 30 - flr(gametime/30)
 print("time left:"..seconds,40,2,11)
-- print("e spawned:"..num_enemies,3,120,11)
-- print("e killed:"..num_kills,64,120,11)
 
 
end

function drawframe()
 line(0,0,0,127,7)
 line(0,127,127,127,7)
 line(0,0,127,0,7)
 line(127,0,127,127,7)
end

-->8
function collision_check()
 --pyr-blt collision
 for b in all(bullets) do
  if b["bltx"]-3-pyrx < bltcolsize and b["bltx"]-1-pyrx > -bltcolsize
  and b["blty"]-3-pyry < bltcolsize and b["blty"]-1-pyry > -bltcolsize-2
  and b["safe"]==false then
   pyrhp-=1
   if pyrhp==0 then
    gameover=true
   end
   del(bullets,b)
  end
 end
 --pyr-eny collision
 for e in all(enemies) do
  --eny a
  if e["enytype"]==1 then
   if e["enyx"]-pyrx-3 < enycolsizea  and e["enyx"]-pyrx+2 > -enycolsizea
   and e["enyy"]-pyry-2 < enycolsizea and e["enyy"]-pyry+5 > -enycolsizea
   then
    pyrhp-=1
    if pyrhp==0 then
     gameover=true
    end
   end
  --eny b
  elseif e["enytype"]==2 then
   if e["enyx"]-pyrx < enycolsizeb  and e["enyx"]-pyrx > -enycolsizeb
   and e["enyy"]-pyry < enycolsizeb and e["enyy"]-pyry > -enycolsizeb
   then
    pyrhp-=1
    if pyrhp==0 then
     gameover=true
    end
   end
  end
 end
 
--blt-eny collision
 for b in all(bullets) do
  for e in all(enemies) do
   --eny a
   if b["bltx"]-e["enyx"]-4 < enycolsizea and b["bltx"]-e["enyx"]-1 > -enycolsizea
    and b["blty"]-e["enyy"]-5 < enycolsizea and b["blty"]-e["enyy"]-2 > -enycolsizea
    and b["safe"]==true and e["enytype"]==1 then
     del(bullets,b)
     e["enyhp"]-=1
     if e["enyhp"]==0 then
      del(enemies, e)
      points+=2
      num_kills+=1
     end
    --eny b
   elseif b["bltx"]-e["enyx"] < enycolsizeb and b["bltx"]-e["enyx"]-5 > -enycolsizeb
    and b["blty"]-e["enyy"] < enycolsizeb and b["blty"]-e["enyy"]-5> -enycolsizeb
    and b["safe"]==true and e["enytype"]==2 then
     del(bullets,b)
     e["enyhp"]-=1
     if e["enyhp"]==0 then
      del(enemies, e)
      points+=4
      num_kills+=1
     end
   end
  end
 end
end

function point_draw()
 print("points="..points,90,2,11)
end

function health_draw()
 print("health="..pyrhp,2,2,11)
end

function game_won()
 print("thank you for sparing them!",10,64,12)
end

function game_lost()
 print("try to survive for longer!",12,64,12)
end

function game_over()
 drawframe()
 spared = num_enemies - num_kills
  if pyrhp < 1 then
   game_lost()
  elseif spared > num_kills then 
   game_won()
  else
   print("why would you kill them?",14,64,12)
  end
end
-->8
function pyr_bounds()
 --left
 if pyrx<=-1 then
  pyrx=pyrx+2
  pyrspdx=0
 end
 --right
 if pyrx>=113 then
  pyrx=pyrx-2
  pyrspdx=0
 end
 --top
 if pyry<=7 then
  pyry=pyry+2
  pyrspdy=0
 end
 --bottom
 if pyry>=121 then
  pyry=pyry-2
  pyrspdy=0
 end
end

function pyr_draw()
 spr(pyrspr,pyrx,pyry)
 pyrx=pyrx+pyrspdx
 pyry=pyry+pyrspdy
end

function pyr_move()
  --left
  if btn(0) then
   pyrx=pyrx-pyrspdmax
   predir="left"
  end
  --right
  if btn(1) then
   pyrx=pyrx+pyrspdmax
   predir="right"
  end
  --up
  if btn(2) then
   pyry=pyry-pyrspdmax
   predir="up"
  end
  --down
  if btn(3) then
   pyry=pyry+pyrspdmax
   predir="down"
  end
end
-->8
function eny_blt()
 for e in all(enemies) do
  if t()-e["ebtimer"]>e["ebrate"] and (e["enytype"]==1) then
   blt_spawn(false,e["enyx"],e["enyy"],e["enytype"])
   e["ebtimer"]=t()
  end
 end
end

--eny in bounds
function eny_bounds()
 for e in all(enemies) do
  --eny a
  if e["enytype"] == 1 then
   if e["enyx"]>112 or e["enyx"]<0 or e["enyy"]>120 or e["enyy"]<6 then
    del(enemies,e)
   end
  --eny b
  elseif e["enytype"] == 2 then
   --left
   if e["enyx"] < 1 then
    e["enyspdx"]=-e["enyspdx"]
    e["enyx"]=e["enyx"]+1
   --right
   elseif e["enyx"] > 112 then
    e["enyspdx"]=-e["enyspdx"]
    e["enyx"]=e["enyx"]-1
   end
   --top
   if e["enyy"] < 7 then
    e["enyspdy"]=-e["enyspdy"]
    e["enyy"]=e["enyy"]+1
   --bottom
   elseif e["enyy"] > 120 then
    e["enyspdy"]=-e["enyspdy"]
    e["enyy"]=e["enyy"]-1
   end
  end
 end
end


--eny a & b dir x
function eny_dirx(x,etype)
 --eny a
 if etype == 1 then
  if x <= 0 then
   return enyspda
  elseif x  >= 112 then
   return -enyspda
  else
   return 0
  end
 end
 --eny b
 if etype == 2 then
  if x <= 56 then
   return enyspdb
  elseif x>= 57 then
   return -enyspdb
  else
   return 0
  end
 end
end

--eny a & b dir y
function eny_diry(y,etype)
 --eny a
 if etype == 1 then
  if y <= 7 then
   return enyspda
  elseif y >= 120 then
   return -enyspda
  else
   return 0
  end
 end
 --eny b
 if etype == 2 then
  if y <= 56 then
   return enyspdb
  elseif y >= 56 then
   return -enyspdb
  else
   return 0
  end
 end
end

--draw enys
function eny_draw()
 for e in all(enemies) do
  spr(e["sprite"],e["enyx"],e["enyy"],e["height"],e["width"])
  e["enyx"]=e["enyx"]+e["enyspdx"]
  e["enyy"]=e["enyy"]+e["enyspdy"]
 end
end

--eny init x
function eny_getx(first,second)
 --x 1st
 if first == 1 then
   fenyx= flr(rnd(112))
   return flr(rnd(112))
 --x 2nd
 elseif first == 2 then
  --left
  if second == 1 then
   fenyx= 0
   return 0
  --right
  elseif second == 2 then
   fenyx= 112
   return 112
  else
   fenyx= 0
   return 0
  end
 end
end

--eny init y
function eny_gety(first,second)
 --y 1st
 if first == 2 then
   fenyy= flr(rnd(112))+7
   return flr(rnd(112))+7 
 --y 2nd 
 elseif first == 1 then
  --top
  if second == 1 then
   fenyy= 7
   return 7
  --bottom
  elseif second == 2 then
   fenyy= 120
   return 120
  else
   fenyy= 0
   return 0
  end
 end
end

--homing atk
function eny_homeatk()
 for e in all(enemies) do
  if e["enytype"] == 2 then
   //player left of eny b
   if pyrx<e["enyx"] then
    if e["enyspdx"]-.1<enyspdb and e["enyspdx"]-.1>-enyspdb then
     e["enyspdx"]=e["enyspdx"]-enyspdb
    elseif e["enyspdx"]==-enyspdb then
     e["enyspdx"]=enyspdb+.001
    elseif e["enyspdx"]==enyspdb then
     e["enyspdx"]=enyspdb-.001
    end
   end
   --player right of eny b
   if pyrx>e["enyx"] then
    if e["enyspdx"]+.1<enyspdb and e["enyspdx"]+.1>-enyspdb then
     e["enyspdx"]=e["enyspdx"]+enyspdb
    elseif e["enyspdx"]==-enyspdb then
     e["enyspdx"]=enyspdb+.001
    elseif e["enyspdx"]==enyspdb then
     e["enyspdx"]=enyspdb-.001
    end
   end
  end
 end
end

--hp functions
function eny_hpstuff()
 for e in all(enemies) do
  --delete enemy
  if e["enyhp"]<=0 then
   del(enemies,e)
  end
 end
end

--spawn eny
function eny_spawn()
 enytype=ceil(rnd(100))
 if enytype <= 20 then
  rng=ceil(rnd(2))--1st rng
  rng2=ceil(rnd(2))--2nd rng
  if t()-estimer>esrate then
   add(enemies, {
    enyx=eny_getx(rng,rng2),
    enyy=eny_gety(rng,rng2),
    ebrate=efrate,
    ebtimer=t(),
    enyhp=1,
    enyspdx=eny_dirx(fenyx,1),
    enyspdy=eny_diry(fenyy,1),
    enytype=1,
    sprite=7,
    height=1,
    width=1
   })
   estimer=t()
   num_enemies+=1
  end
 end
  if enytype > 20 and enytype <=40 then
  rng=ceil(rnd(2))--1st rng
  rng2=ceil(rnd(2))--2nd rng
  if t()-estimer>esrate then
   add(enemies, {
    enyx=eny_getx(rng,rng2),
    enyy=eny_gety(rng,rng2),
    ebrate=efrate,
    ebtimer=t(),
    enyhp=1,
    enyspdx=eny_dirx(fenyx,1),
    enyspdy=eny_diry(fenyy,1),
    enytype=1,
    sprite=8,
    height=1,
    width=1
   })
   estimer=t()
   num_enemies+=1
  end
 end
  if enytype > 40 and enytype <= 60 then
  rng=ceil(rnd(2))--1st rng
  rng2=ceil(rnd(2))--2nd rng
  if t()-estimer>esrate then
   add(enemies, {
    enyx=eny_getx(rng,rng2),
    enyy=eny_gety(rng,rng2),
    ebrate=efrate,
    ebtimer=t(),
    enyhp=1,
    enyspdx=eny_dirx(fenyx,1),
    enyspdy=eny_diry(fenyy,1),
    enytype=1,
    sprite=9,
    height=1,
    width=1
   })
   estimer=t()
   num_enemies+=1
  end
 end
   if enytype > 60 and enytype <= 80 then
  rng=ceil(rnd(2))--1st rng
  rng2=ceil(rnd(2))--2nd rng
  if t()-estimer>esrate then
   add(enemies, {
    enyx=eny_getx(rng,rng2),
    enyy=eny_gety(rng,rng2),
    ebrate=efrate,
    ebtimer=t(),
    enyhp=3,
    enyspdx=eny_dirx(fenyx,1),
    enyspdy=eny_diry(fenyy,1),
    enytype=2,
    sprite=10,
    height=2,
    width=2
   })
   estimer=t()
   num_enemies+=1
  end
 end
  if enytype > 80 then
  rng=ceil(rnd(2))--1st rng
  rng2=ceil(rnd(2))--2nd rng
  if t()-estimer>esrate then
   add(enemies, {
    enyx=eny_getx(rng,rng2),
    enyy=eny_gety(rng,rng2),
    ebrate=efrate,
    ebtimer=t(),
    enyhp=3,
    enyspdx=eny_dirx(fenyx,1),
    enyspdy=eny_diry(fenyy,1),
    enytype=2,
    sprite=12,
    height=2,
    width=1
   })
   estimer=t()
   num_enemies+=1
  end
 end
end
-->8
function blt_bounds()
 for b in all(bullets) do
  if b["bltx"]>115 or b["bltx"]<0 or b["blty"]>123 or b["blty"]<8 then
   del(bullets,b)
  end
 end
end

--max # blt
function blt_count()
 while count(bullets)>maxblt do
  del(bullets,bullets[1])
 end
end

--blt dir x
function blt_dirx(left,right)
 --x spd
 if left==true then
  return -bltspd
 elseif right==true then
  return bltspd
 --not moving
 elseif predir=="left" then
  return -bltspd
 elseif predir=="right" then
  return bltspd
 else
  return 0
 end
end

--blt dir y
function blt_diry(up,down)
 --y spd
 if up==true then
  return -bltspd
 elseif down==true then
  return bltspd
 --not moving
 elseif predir=="up" then
  return -bltspd
 elseif predir=="down" then
  return bltspd
 else
  return 0
 end
end

--draw blt
function blt_draw()
 for b in all(bullets) do
  spr(b["sprite"],b["bltx"]+b["spdx"],b["blty"]+b["spdy"])
  b["bltx"]=b["bltx"]+b["spdx"]
  b["blty"]=b["blty"]+b["spdy"]
 end
end

--spawn blt
function blt_spawn(pyrblt,enyx,enyy,enytype)
 --pyr blt spawn
 if btn(4) and pyrblt==true and t()-blttimer>bltrate and hold==false then
  add(bullets,{
   sprite=pyrbltspr,
   bltx=pyrx+2,
   blty=pyry+2,
   spdx = blt_dirx(btn(0),btn(1)),
   spdy = blt_diry(btn(2),btn(3)),
   safe=true
  })
  bltxspd=blt_dirx(btn(0),btn(1))
  bltyspd=blt_diry(btn(2),btn(3))
  blttimer=t()
  hold=true
 elseif btn(4) and pyrblt==true and t()-blttimer>bltrate and hold==true then
  add(bullets,{
   sprite=pyrbltspr,
   bltx=pyrx+2,
   blty=pyry+2,
   spdx = blt_slidex(),
   spdy = blt_slidey(),
   safe=true
  })
  hold=true
  blttimer=t()
 end
 if not btn(4) then
  hold=false
 end
 --eny blt spawn
 if pyrblt==false then
  if enytype==1 then
    --northeast blt
    add(bullets,{
     sprite=enybltspr,
     bltx=enyx+2,
     blty=enyy+2,
     spdx=enybltspd,
     spdy=-enybltspd,
     safe=false
    })
    --southeast blt
    add(bullets,{
     sprite=enybltspr,
     bltx=enyx+2,
     blty=enyy+2,
     spdx=enybltspd,
     spdy=enybltspd,
     safe=false
    })
    --southwest blt
    add(bullets,{
     sprite=enybltspr,
     bltx=enyx+2,
     blty=enyy+2,
     spdx=-enybltspd,
     spdy=enybltspd,
     safe=false
    })
    --northwest blt
    add(bullets,{
     sprite=enybltspr,
     bltx=enyx+2,
     blty=enyy+2,
     spdx=-enybltspd,
     spdy=-enybltspd,
     safe=false
    })
  elseif enytype==4 then
   for i=0,19+bossb do
    add(bullets,{
     sprite=enybltspr,
     bltx=enyx+6,
     blty=enyy+9,
     spdx=rnd(4)-2,
     spdy=rnd(4)-2,
     safe=false
    })
   end
  end
 end   
end

function blt_slidex()
 return bltxspd
end

function blt_slidey()
 return bltyspd
end
-->8
function splash_screen()
 cls()
 drawframe()
	print("star savior ★", 38, 60, 12)
	for x=0,90 do
	 x+=1
	 flip()
	end
end

function do_intro()
	local y = 52.0
	local len = 0
	while  (len < 120) do
		cls()
		sspr(0,32,32,24,48,47,32,24)
		sspr(32,32,8,16,66,flr(y),8,16)
		if(y > 46) then
			y-=0.125
		end
		if(len > 60) then
			print("pico zen",48,72,3)
		elseif(len > 57) then
			spr(0,74,51)
		elseif(len > 53) then
			spr(0,74,56)
		elseif(len > 49) then
			spr(0,70,51)
		end
		flip()
		len+=1
	end
end
__gfx__
0000000000886200000000000026880000000000000000000000000000999a00000000000b300000000009999990000000000cc77cc000000000000000000000
00000000086665000000000000566680000000000000000000000000077a77a0000880000b0000b300099999999990000000cc7777cc00000000000000000000
00700700060700000000000000006060000000000000000000000000a70a70aa088888800b0000b000999aaaaaa99900000cc777777cc0000000000000000000
00077000998fff00000aa00000fff899000000000a0000a0000000000aaaaaa0087787780bbbbbb00999aaaaaaaa9990000c77777777c0000000000000000000
000770008699922a000aa000a2299968000000000000000000000000000aa000887087080bbbbbb0099aaaaaaaaaa990055cccccccccc5500000000000000000
00700700808820000000000000028808000000000000000000000000aaaaaaaa88888888377b77b399aaaaaaaaaaaa9955555555555555550000000000000000
00000000066055000000000000550660000000000000000000000000a0a00a0a88888888070b70b099aaaaaaaaaaaa9955555555555555550000000000000000
0000000088202220000000000222028800000000000000000000000090900909808080800bbbbbb099aaaaaaaaaaaa990c5a5c5a5c5a5c500000000000000000
0000000000000000000000000000000000000000000660000000000000000000000000000000000099aaaaaaaaaaaa9900555555555555000000000000000000
0000070000000000000000000000000000000000050660500000000000000000000000000000000099aaaaaaaaaaaa9900000000000000000000000000000000
0700700000000000000000000000000000000000056b36500000000000000000000000000000000099aaaaaaaaaaaa9900000000000000000000000000000000
00777000000000000008800000000000000000000063360000000000000000000000000000000000099aaaaaaaaaa99000000000000000000000000000000000
000777000000000000088000000000000000000006533560000000000000000000000000000000000999aaaaaaaa999000000000000000000000000000000000
0007007000000000000000000000000000000000666666660000000000000000000000000000000000999aaaaaa9990000000000000000000000000000000000
007000000000000000000000000000000000000009a909a900000000000000000000000000000000000999999999900000000000000000000000000000000000
00000000000000000000000000000000000000000090009000000000000000000000000000000000000009999990000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000003333000000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000033333000000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000333333300000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000333333300000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000002220300000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000002220000000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000022220000000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000022222000000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000022222000000000000000000999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004444444422222444444444400000000909090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004ffffff2222222fff6f6f6400000000909090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004666666666666666f6f6f6400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004ffffffffffffffff6f6f6400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004666666666666666f6f6f6400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004ffffffffffffffff6f6f6400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004666666666666666f6f6f6400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004444444444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004444444444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000044000000000000000440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000044000000000000000440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000044000000000000000440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
