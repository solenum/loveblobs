local dir = (...):gsub('%.[^%.]+$', '')
require(dir .. ".util")

local softbody = setmetatable({}, {
  __call = function(self, world, x, y, r, s, t)
    local new = copy(self);
    new:init(world, x, y, r, s, t);

    return setmetatable(new, getmetatable(self));
  end,
  __index = function(self, i)
    return self.nodes[i] or false;
  end,
  __tostring = function(self)
    return "softbody";
  end
});

function softbody:init(world, x, y, r, s, t, reinit)
  self.radius = r;
  self.world = world;

  --create center body
  self.centerBody = physics.newBody(world, x, y, "dynamic");
  self.centerShape = physics.newCircleShape(r/4);
  self.centerfixture = physics.newFixture(self.centerBody, self.centerShape);
  self.centerfixture:setMask(1);
  self.centerBody:setAngularDamping(300);

  --create 'nodes' (outer bodies) & connect to center body
  self.nodeShape = physics.newCircleShape(r/8);
  self.nodes = {};

  local nodes = r/2

  for node = 1, nodes do
    local angle = (2*math.pi)/nodes*node;
    
    local posx = x+r*math.cos(angle);
    local posy = y+r*math.sin(angle);

    local b = physics.newBody(world, posx, posy, "dynamic");
    b:setAngularDamping(5000);
    b:isBullet(true);

    local f = physics.newFixture(b, self.nodeShape);
    f:setFriction(0.5);
    f:setRestitution(0);
    f:setUserData(node);
    
    local j = physics.newDistanceJoint(self.centerBody, b, posx, posy, posx, posy, false);
    j:setDampingRatio(0.2);
    j:setFrequency(0.8);

    table.insert(self.nodes, {body = b, fixture = f, joint = j});
  end


  --connect nodes to eachother
  for i = 1, #self.nodes do
    if i < #self.nodes then
      local j = physics.newDistanceJoint(self.nodes[i].body, self.nodes[i+1].body, self.nodes[i].body:getX(), self.nodes[i].body:getY(),
      self.nodes[i+1].body:getX(), self.nodes[i+1].body:getY(), false);
      self.nodes[i].joint2 = j;
    else
      local j = physics.newDistanceJoint(self.nodes[i].body, self.nodes[1].body, self.nodes[i].body:getX(), self.nodes[i].body:getY(),
      self.nodes[1].body:getX(), self.nodes[1].body:getY(), false);
      self.nodes[i].joint3 = j;
    end
  end

  if not reinit then
    --set tesselation and smoothing
    self.smooth = s or 2;

    local tess = t or 4;
    self.tess = {};
    for i=1,tess do
      self.tess[i] = {};
    end
  end

  self.dead = false;
  self:update();
end

function softbody:update()
  --update tesselation (for drawing)
  local pos = {};
  for i = 1, #self.nodes, self.smooth do
    v = self.nodes[i];

    table.insert(pos, v.body:getX());
    table.insert(pos, v.body:getY());
  end

  tessellate(pos, self.tess[1]);
  for i=1,#self.tess - 1 do
    tessellate(self.tess[i], self.tess[i+1]);
  end
end

function softbody:destroy()
  if self.dead then
    return;
  end

  for i = #self.nodes, 1, -1 do
    self.nodes[i].body:destroy();
    self.nodes[i] = nil;
  end

  self.centerBody:destroy();
  self.dead = true;
end

function softbody:setFrequency(f)
  for i,v in pairs(self.nodes) do
    v.joint:setFrequency(f);
  end
end

function softbody:setDamping(d)
  for i,v in pairs(self.nodes) do
    v.joint:setDampingRatio(d);
  end
end

function softbody:setFriction(f)
  for i,v in ipairs(self.nodes) do
    v.fixture:setFriction(f);
  end
end

function softbody:getPoints()
  return self.tess[#self.tess];
end

function softbody:draw(type, debug)
  if self.dead then
    return;
  end

  graphics.setLineStyle("smooth");
  graphics.setLineJoin("miter");
  graphics.setLineWidth(self.nodeShape:getRadius()*2.5);

  if type == "line" then
    graphics.polygon("line", self.tess[#self.tess]);
  elseif type == "fill" then
    graphics.polygon("fill", self.tess[#self.tess]);
    graphics.polygon("line", self.tess[#self.tess]);
  end

  graphics.setLineWidth(1);

  if debug then
    for i,v in ipairs(self.nodes) do
      graphics.setColor(255, 255, 255)
      graphics.circle("line", v.body:getX(), v.body:getY(), self.nodeShape:getRadius());
    end
  end
end

return softbody;