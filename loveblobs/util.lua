local function tessellate(vertices, new_vertices)
  local MIX_FACTOR = .5
  new_vertices[#vertices*2] = 0
  for i=1,#vertices,2 do
    local newindex = 2*i
      new_vertices[newindex - 1] = vertices[i];
      new_vertices[newindex] = vertices[i+1]
    if not (i+1 == #vertices) then
      new_vertices[newindex + 1] = (vertices[i] + vertices[i+2])/2
      new_vertices[newindex + 2] = (vertices[i+1] + vertices[i+3])/2
    else
      new_vertices[newindex + 1] = (vertices[i] + vertices[1])/2
      new_vertices[newindex + 2] = (vertices[i+1] + vertices[2])/2
    end
  end

  for i = 1,#new_vertices,4 do
    if i == 1 then
      -- x coordinate
      new_vertices[1] = MIX_FACTOR*(new_vertices[#new_vertices - 1] + new_vertices[3])/2 + (1 - MIX_FACTOR)*new_vertices[1]
      -- y coordinate
      new_vertices[2] = MIX_FACTOR*(new_vertices[#new_vertices - 0] + new_vertices[4])/2 + (1 - MIX_FACTOR)*new_vertices[2]
    else
      -- x coordinate
      new_vertices[i] = MIX_FACTOR*(new_vertices[i - 2] + new_vertices[i + 2])/2 + (1 - MIX_FACTOR)*new_vertices[i]
      -- y coordinate
      new_vertices[i + 1] = MIX_FACTOR*(new_vertices[i - 1] + new_vertices[i + 3])/2 + (1 - MIX_FACTOR)*new_vertices[i + 1]
    end
  end
end

local function dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

local function copy(from)
  local to = {};

  for i,v in pairs(from) do
    to[i] = v;
  end

  return to;
end

return {tessellate = tessellate, dist = dist, copy = copy}
