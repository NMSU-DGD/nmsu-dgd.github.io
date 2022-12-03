pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
grid_size = 4
ticks = 3
tick = 1
addlength = 3

game = {}
snake = {}
apple = {}

function newgame()
    game._draw=drawgame
    game._update=updategame
    snake.x = 1
    snake.y = 1
    snake.deltay = 0
    snake.deltax = 0
    snake.grid_size = grid_size
    snake.count = 1
    snake.body = {}
    snake.adding = false
    snake.addcount = 0
    apple.grid_size = grid_size
    apple:move()
end

function drawmenu()
    cls()
    sspr(0,0,104,32,0,0)
    print("start game!",50,50,7)
    print("press z.",57,57,7)
end

function updatemenu()
   if btn(4) then
        newgame()
   end
end

function drawdeath()
    cls()
    print("game over!",47,60,7)
    print("press z to try again",27,67,7)
end

function updatedeath()
    if btn(4) then newgame() end
end

function updategame()
    snake:keypress()
    if tick==ticks then
        snake:move()
        tick=1
    else
        tick+=1
    end
end

function drawgame()
    cls()
    color(7)
    rect(0,0,127,127)
    apple:draw()
    snake:draw()
    color(7)
    print("score:"..snake.count,90,2)
end

function _init()
    game._update = updatemenu
    game._draw = drawmenu
end

function _update()
    game._update()
end

function _draw()
    game._draw()
end

function apple:draw()
    color(8)
    rectfill(self.x,self.y,self.x+self.grid_size-2,self.y+self.grid_size-2)
end

function apple:move()
    self.x = (flr(rnd(126/self.grid_size))*self.grid_size)+1
    self.y = (flr(rnd(126/self.grid_size))*self.grid_size)+1
end

function snake:draw()
    color(11)
   
    rectfill(self.x,self.y,self.x+self.grid_size-2,self.y+self.grid_size-2)
   
    for i=1,#self.body do
        color(11)
        rectfill(self.body[i].x,self.body[i].y,self.body[i].x+self.grid_size-2,self.body[i].y+self.grid_size-2)
    end
end

function snake:keypress()
    if btn(⬅️) and
       self.deltax!=1 then
        self.deltax=-1
        self.deltay=0
    end
    if btn(➡️) and
       self.deltax!=-1 then
        self.deltax=1
        self.deltay=0
    end
    if btn(⬆️) and
       self.deltay!=1 then
        self.deltay=-1
        self.deltax=0
    end
    if btn(⬇️) and
       self.deltay!=-1 then 
        self.deltay=1
        self.deltax=0
    end
end

function snake:move()
    self:eat() 
   
    self.x+=self.deltax*(self.grid_size)
    self.y+=self.deltay*(self.grid_size)
   
    for i=1,#self.body do
        if self.body[i].x==self.x and self.body[i].y==self.y then
            game._draw=drawdeath
            game._update=updatedeath
        end
    end

    if self.x>126 then 
        game._draw=drawdeath 
        game._update=updatedeath end
    if self.x<1 then 
        game._draw=drawdeath 
        game._update=updatedeath end
    if self.y>126 then 
        game._draw=drawdeath 
        game._update=updatedeath end
    if self.y<1 then 
        game._draw=drawdeath 
        game._update=updatedeath end
end

function snake:eat()
    if self.x==apple.x and self.y==apple.y then
        apple:move()
        self.adding=true
        sfx(0)
    end

    if self.adding then
        if self.addcount==addlength then
            self.adding=false
            self.addcount=0
        else
            self.addcount+=1
            self.count+=1
        end
    end
    if self.count-1==#self.body then
        for i=1,#self.body-1 do 
            self.body[i] = self.body[i+1]
        end
    end
   
    self.body[self.count-1] = {}
    self.body[self.count-1].x = self.x
    self.body[self.count-1].y = self.y
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
