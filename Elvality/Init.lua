local addon,ELV = ...
local E, L, V, P, G = unpack(ElvUI)
local X = {}
ELV[1] = X
ELV[2] = E
ELV[3] = L
ELV[4] = V
ELV[5] = P
ELV[6] = G
X.initialized = false
-- Colors
X.colors = {
  main = "fff45342"
}

-- UTIL
local function AddMissingTableEntries(data,DEFAULT)
  if not data or not DEFAULT then return data end
  local rv = data
  for k,v in pairs(DEFAULT) do
     if rv[k] == nil then
        rv[k] = v
     elseif type(v) == "table" then
        rv[k] = AddMissingTableEntries(rv[k],v)
     end
  end
  return rv
end
X.AddMissingTableEntries = AddMissingTableEntries


-- for Options
X.configs = {}
local function GetOptions()
	for _, func in ipairs(X.configs) do
		func()
	end
end

-- Module Init --
X.init = {}

function X:Init()
  X.initialized = true
  -- DB
  if not E.db.elvality then 
    E.db.elvality = {}
  end

  -- initialize module inits
  for _,func in ipairs(X.init) do
    func()
  end

  LibStub("LibElvUIPlugin-1.0"):RegisterPlugin(addon, GetOptions)
end


local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
	X:Init()
end)