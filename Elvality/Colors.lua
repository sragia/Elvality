local addon,ELV = ...
local X,E,L,V,P,G = unpack(ELV)
local db
local UF = ElvUF

local powerNames = {
  [0] = "Mana",
  [1] = "Rage",
  [2] = "Focus",
  [3] = "Energy",
  [4] = "Combo Points",
  [5] = "Runes",
  [6] = "Runic Power",
  [7] = "Soul Shards",
  [8] = "Lunar Power",
  [9] = "Holy Power",
  [10] = "Alternate",
  [11] = "Maelstorm",
  [12] = "Chi",
  [13] = "Insanity",
  [16] = "Arcane Charges",
  [17] = "Fury",
  [18] = "Pain"
}


local function ApplyCustomClassColor(class,colors)
  local UFClassColors = UF.colors.class[class]
  if not UFClassColors then return end
  for i,value in ipairs(colors) do
    UFClassColors[i] = value
    db.UFColors[class][i] = value
  end
end

local function ApplyCustomPowerColor(power,colors)
  local UFPowerColors = UF.colors.power[power]
  if not UFPowerColors then return end
  for i,value in ipairs(colors) do
    UFPowerColors[i] = value
    db.UFPowerColors[power][i] = value
  end
end


local function init()
  db = E.db.elvality
  -- Class
  if not db.UFColors then
    db.UFColors = {}
    for class,colors in pairs(UF.colors.class) do
      db.UFColors[class] = colors 
    end
  else
    -- apply my colors
    for class,colors in pairs(db.UFColors) do
      ApplyCustomClassColor(class,colors)
    end
  end

  -- Powers
  if not db.UFPowerColors then
    db.UFPowerColors = {}
    for power in pairs(powerNames) do
      db.UFPowerColors[power] = UF.colors.power[power] 
    end
  else
    -- apply my colors
    for power,colors in pairs(db.UFPowerColors) do
      ApplyCustomPowerColor(indx,colors)
    end
  end

end
tinsert(X.init,init)

-- Change Class colors --
local function options()
  local o = E.Options.args.elvality.args.colors.args
  local i = 2
  o.description = {
    type = "description",
    name = L["Change Class Colors"],
    order = 1,
    width = 'full'
  }
  for class,colors in pairs(db.UFColors) do
    o[class] = {
      type = "color",
      name = class,
      order = i,
      hasAlpha = false,
      get = function() return unpack(colors) end,
      set = function(self,r,g,b) ApplyCustomClassColor(class,{r,g,b}) end
    }
    i = i + 1
  end
  -- Powers --
  o.powerDesc = {
    type = "description",
    name = L["Power Colors"],
    order = i,
    width = "full"
  }
  i = i + 1
  for power,colors in pairs(db.UFPowerColors) do
    o["powers"..power] = {
      type = "color",
      name = powerNames[power],
      order = i,
      hasAlpha = false,
      get = function() return unpack(colors) end,
      set = function(self,r,g,b) ApplyCustomPowerColor(power,{r,g,b}) end
    }
  end

end
tinsert(X.configs,options)
