local dir = (...):gsub('%.[^%.]+$', '')

local blobs = {}
blobs.softbody = require(dir .. ".softbody")
blobs.softsurface = require(dir .. ".softsurface")

return blobs