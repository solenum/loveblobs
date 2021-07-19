# loveblobs, the softbody library

### What is loveblobs?
loveblobs is a softbody library for the [LÖVE](https://love2d.org/) game framework with support for both dynamic and static *arbitrary* softbodies.

### How do I use it?
Simply add the loveblobs directory to your project and require it like so..
```
local love.blobs = require "loveblobs"
```

Once you've done this using the library is easy, here is a minimal example. (clone the repo and run main.lua for a better example)
```
local softbodies = {}

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

  -- a softbody
  local b = love.blobs.softbody(world, 400, -300, 102, 2, 4)
  b:setFrequency(1)
  b:setDamping(0.1)
  b:setFriction(1)
  table.insert(softbodies, b)
end

function love.update(dt)
  -- update the physics world
  for i=1,4 do
    world:update(dt)
  end

  -- update the softbodies
  for i,v in ipairs(softbodies) do
    v:update(dt)
  end
end

function love.draw()
  for i,v in ipairs(softbodies) do
    love.graphics.setColor(50*i, 100, 200*i)
    if (tostring(v) == "softbody") then
      v:draw("fill", false)
    else
      v:draw(false)
    end
  end
end
```


### Gallery
![a](http://i.imgur.com/DYBv0gt.gif)
![b](https://i.imgur.com/7qP6mBg.gif)
