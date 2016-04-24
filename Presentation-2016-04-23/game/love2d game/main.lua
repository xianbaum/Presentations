local game = {};

local TONES = {
   high = 1;
   medium = 2; 
   low = 4;
}

local beep = function(tone)
  local soundData = love.sound.newSoundData(1000, 1000, 8, 1)
  local sample = 0.1;

  for i = 1, 125 do
    if i % tone == 0 then
      sample = sample * -1;
    end

    soundData:setSample(i, sample)
  end
  
  love.audio.play(love.audio.newSource(soundData))
end

local Actor = {};
local Size = {};
local Point = {};

function Point:new(x, y)  
   local instance = {};
   setmetatable(instance, self);
   self.__index = self;
   instance.x = x or 0;
   instance.y = y or 0;
   return instance;
end

function Size:new(width, height)
   local instance = {};
   setmetatable(instance, self);
   self.__index = self;
   instance.width = width or 1;
   instance.height = height or 1;
   return instance;
end

function Actor:new(size, position, vector)
   local instance = {};
   setmetatable(instance, self);
   self.__index = self;
   instance.position = position or Point:new();
   instance.size = size or Size:new();
   instance.vector = vector or Point:new();
   return instance;
end

function Actor:move(timePassed)
   self.position.x = self.position.x + self.vector.x * timePassed;
   self.position.y = self.position.y + self.vector.y * timePassed;
end

function Actor:isColliding(collider, timePassed, coord)
   local dimension = "width";
   if coord == "y" then
      dimension = "height";
   end

   local newCoord = self.vector[coord] * timePassed + self.position[coord];

   return newCoord < collider.position[coord] + collider.size[dimension] and
      collider.position[coord] < newCoord + self.size[dimension];
end

function Actor:draw()
   love.graphics.rectangle("fill", self.position.x, self.position.y,
         self.size.width, self.size.height);
end

local Paddle = Actor:new();

function Paddle:update(screen, timePassed)
   self.vector.y = 0;
   
   if love.keyboard.isDown(self.upkey) then
      self.vector.y = -1;
   elseif love.keyboard.isDown(self.downkey) then
      self.vector.y = 1;
   end
   
   if not self:isColliding(screen, timePassed, "y") then
      self.vector.y = 0;
   end

   self:move(timePassed);
end

function Paddle:setKeys(up, down)
   self.upkey = up;
   self.downkey = down;
end

local Ball = Actor:new();

function Ball:update(screen, timePassed, paddles, game)
   local colliding = false
   for i, paddle in pairs(paddles) do
      colliding = colliding or self:isColliding( paddle, timePassed, "x") and
	 self:isColliding(paddle, timePassed, "y")
   end
   
   if not self:isColliding(screen, timePassed, "y") then
      self.vector.y = self.vector.y * -1;
      beep(TONES.high);
   end
   
   if self.vector.x < 0.5 and self.vector.x > -0.5 then
      self.vector.x = self.vector.x * 2;
   end

   if colliding then
      self.vector.x = self.vector.x * love.math.random() * -1
      self.vector.y = math.random() * -2 + 1;
      beep(TONES.medium);
   end

   self:move(timePassed);
end

function Ball:isWinner( screen )
   if not self:isColliding(screen, 0, "x") then
      beep(TONES.low);
      return self.vector.x > 0 and 1 or 2;
   end
end

function game.reset()   
   local ballSize = Size:new(1, 1);
   local ballPosition = Point:new(game.screen.size.width / 2,
				  game.screen.size.height / 2);
   local ballVector = Point:new(love.math.random()* -2 + 1,
         love.math.random() * -2 + 1);
   local ball = Ball:new(ballSize, ballPosition, ballVector)

   local leftPaddle = Paddle:new(Size:new(1, 2));
   leftPaddle:setKeys("w","s");

   local rightPaddleSize = Size:new(1, 2);
   local rightPaddlePosition = Point:new(
      game.screen.size.width - rightPaddleSize.width,
      game.screen.size.height - rightPaddleSize.height);
   local rightPaddle = Paddle:new(rightPaddleSize, rightPaddlePosition)
   rightPaddle:setKeys("up","down");

   game.actors = {
      balls = {ball};
      paddles = { leftPaddle, rightPaddle};
   }
end

function love.load()
   game.screen = {
      position = Point:new();
      size = Size:new(48, 36);
   };
   game.score = {0, 0}
   game.reset();
   game.graphics = {};
   game.graphics['0']=
     {{1,1,1},
      {1,0,1},
      {1,0,1},
      {1,0,1},
      {1,1,1}};
   game.graphics['1']=
     {{0,0,1},
      {0,0,1},
      {0,0,1},
      {0,0,1},
      {0,0,1}};
   game.graphics['2']=
     {{1,1,1},
      {0,0,1},
      {1,1,1},
      {1,0,0},
      {1,1,1}};
   game.graphics['3']=
     {{1,1,1},
      {0,0,1},
      {1,1,1},
      {0,0,1},
      {1,1,1}};
   game.graphics['4']=
     {{1,0,1},
      {1,0,1},
      {1,1,1},
      {0,0,1},
      {0,0,1}};
   game.graphics['5']=
     {{1,1,1},
      {1,0,0},
      {1,1,1},
      {0,0,1},
      {1,1,1}};
   game.graphics['6']=
     {{1,1,1},
      {1,0,0},
      {1,1,1},
      {1,0,1},
      {1,1,1}};
   game.graphics['7']=
     {{1,1,1},
      {0,0,1},
      {0,0,1},
      {0,0,1},
      {0,0,1}};
   game.graphics['8']=
     {{1,1,1},
      {1,0,1},
      {1,1,1},
      {1,0,1},
      {1,1,1}};
   game.graphics['9']=
     {{1,1,1},
      {1,0,1},
      {1,1,1},
      {0,0,1},
      {1,1,1}};
end

function love.update(timePassed)
   timePassed = timePassed * 20;

   for junk_var,actor_sublist in pairs(game.actors) do
      for junk_var, actor in pairs(actor_sublist) do
	 actor:update(game.screen, timePassed, game.actors.paddles);
      end
   end

   for junk_var, ball in pairs(game.actors.balls) do
      local winner = ball:isWinner( game.screen);
      if winner then
	 game.reset();
	 game.score[winner] = game.score[winner] + 1;
      end
   end
end

function love.draw()
   local width,height = love.graphics.getDimensions();

   love.graphics.scale(width / game.screen.size.width, height
			  / game.screen.size.height);

   for _,actor_sublist in pairs(game.actors) do
      for _, actor in pairs(actor_sublist) do
	 actor:draw();
      end
   end
   
   for _,actor in pairs(game.actors) do

   end

   for player, score in ipairs(game.score)  do
      local playerNumberOffset = -3 + (2 * player);

      for scoreDigit = 1, string.len(score) do
	 for graphicYPosition, graphicRow in ipairs(
	     game.graphics[string.sub(game.score[player],
	     playerNumberOffset * scoreDigit, playerNumberOffset * scoreDigit)]) do
	    for graphicXPosition, block in ipairs(graphicRow) do
	       if block == 1 then
		  love.graphics.rectangle("fill", playerNumberOffset *
					     4 * scoreDigit +
                      game.screen.size.width / 2 + graphicXPosition
		       - 2, graphicYPosition, 1, 1);
	       end
	    end
	 end
      end
   end

   for i = 0, game.screen.size.height, 2 do
      love.graphics.rectangle("fill",game.screen.size.width / 2, i, 1, 1);
   end
end
