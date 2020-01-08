local noise = require("noise")

local function water_level_correct(to_be_corrected, map)
  return noise.max(
    map.wlc_elevation_minimum,
    to_be_corrected + map.wlc_elevation_offset
  )
end

local function water_level_correct2(to_be_corrected, map)
  return noise.max(
    map.wlc_elevation_minimum,
    to_be_corrected + noise.clamp(map.wlc_elevation_offset,-100,100)
  )
end

local function clamp_var(var)
	return noise.ridge(var, -10, 10)
end

local function clamp_var2(var, map)
	return noise.ridge(var * map, -40, 40)
end


data:extend{
  {
    type = "noise-expression",
    name = "rings",
    intended_property = "elevation",
    expression = noise.define_noise_function(function(x, y, tile, map)
      local raw_elevation = noise.ridge(tile.distance * map.segmentation_multiplier, -20, 20) / map.segmentation_multiplier
      return water_level_correct(raw_elevation, map)
    end)
  },
  {
    type = "noise-expression",
    name = "diamonds",
    intended_property = "elevation",
    expression = noise.define_noise_function(function(x, y, tile, map)
    	local m = map.segmentation_multiplier
    	local raw_elevation = (noise.ridge(clamp_var2(x, m),-40,40)) / m + (noise.ridge(clamp_var2(y, m),-40,40)) / m
    	return water_level_correct(raw_elevation, map)
    end)
  },
  {
    type = "noise-expression",
    name = "large-rings-with-connections",
    intended_property = "elevation",
    expression = noise.define_noise_function(function(x, y, tile, map)
    	local m = map.segmentation_multiplier
    	local raw_elevation = noise.ridge(tile.distance * map.segmentation_multiplier, -80, 80) / (map.segmentation_multiplier*4)
    	local raw_cross = (noise.clamp(noise.clamp(40*x - x^2,-100, 100) + noise.clamp(40*y - y^2, -100, 100), -100, 100))
    	raw_elevation = noise.clamp(raw_elevation, -100, 100)
    	raw_elevation = raw_elevation + 101 + raw_cross
    	return water_level_correct2(raw_elevation, map)
    end)
  },
  {
    type = "noise-expression",
    name = "rings-with-connections",
    intended_property = "elevation",
    expression = noise.define_noise_function(function(x, y, tile, map)
    	local m = map.segmentation_multiplier
    	local raw_elevation = noise.ridge(tile.distance * map.segmentation_multiplier, -40, 40) / (map.segmentation_multiplier*2)
    	local raw_cross = (noise.clamp(noise.clamp(40*x - x^2,-100, 100) + noise.clamp(40*y - y^2, -100, 100), -100, 100))
    	raw_elevation = noise.clamp(raw_elevation, -100, 100)
    	raw_elevation = raw_elevation + 101 + raw_cross
    	return water_level_correct2(raw_elevation, map)
    end)
  }
}