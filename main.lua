--[[
This is an example usage of the loveblobs library
use mouse 1 to grab objects
use mouse 2 to spawn softbodies
--]]

love.blobs = require "loveblobs"

local softbodies = {}
local mousejoint = nil

function love.load()
  -- init the physics world
  love.physics.setMeter(16)
  world = love.physics.newWorld(0, 9.81*16, true)

  -- make a floor out of a softsurface
  local points = {
    0,500,   800,500,
    800,800, 0,800
  }
  local b = love.blobs.softsurface(world, points, 64, "static")
  table.insert(softbodies, b)

  -- some random dynamic softsurface shape
  points = {
    400,0, 550,200,
    400,300,   250,200
  }
  b = love.blobs.softsurface(world, points, 16, "dynamic")
  table.insert(softbodies, b)

  -- a softbody
  local b = love.blobs.softbody(world, 400, -300, 102, 2, 4)
  b:setFrequency(1)
  b:setDamping(0.1)
  b:setFriction(1)
  table.insert(softbodies, b)

  love.graphics.setBackgroundColor(255, 255, 255)
end

function love.update(dt)
  -- update the physics world
  for i=1,4 do
    world:update(dt)

  end

  local mx,my = love.mouse:getPosition()
  for i,v in ipairs(softbodies) do
    v:update(dt)

    local body = nil
    if tostring(v) == "softbody" then
      body = v.centerBody
    elseif tostring(v) == "softsurface" and v.phys then 
      for i,v in ipairs(v.phys) do
        if math.dist(mx, my, v.body:getX(), v.body:getY()) < 16 and v.fixture:getUserData() == "softsurface" then
          body = v.body
        end
      end
    end

    if body then
      if love.mouse.isDown(1) and math.dist(mx, my, body:getX(), body:getY()) < 128 then
        if mousejoint == nil then
          mousejoint = physics.newMouseJoint(body, body:getPosition())
          mousejoint:setMaxForce(50000)
          mousejoint:setFrequency(5000)
          mousejoint:setDampingRatio(1) 
        end
      end
    end
  end

  if mousejoint then
    mousejoint:setTarget(mx, my)
  end

  if mousejoint ~= nil and not love.mouse.isDown(1) then
    mousejoint:destroy()
    mousejoint = nil
  end
end

function love.mousepressed(x, y, button)
  if button == 2 then
    local b = love.blobs.softbody(world, x, y, 102, 2, 4)
    b:setFrequency(1)
    b:setDamping(0.1)
    b:setFriction(1)

    table.insert(softbodies, b)
  end
end

function love.draw()
  for i,v in ipairs(softbodies) do
    if love.getVersion == 0 then
      love.graphics.setColor(50*i, 100, 200*i)
    else
      love.graphics.setColor(0.2*i, 0.4, 0.8*i)
    end
    if (tostring(v) == "softbody") then
      v:draw("fill", false)
    else
      v:draw(false)
    end
  end
end
