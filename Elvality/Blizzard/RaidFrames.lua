local addon,ELV = ...
local X,E,L,V,P,G = unpack(ELV)
local db
local LSM = LibStub("LibSharedMedia-3.0")
local _G = _G
local DB_DEFAULT = {
  texture = "Blizzard Raid Bar",
  useClassBG = false,
  selectionHighlightColor = {1,1,1,1},
  classColorName = false,
}


local function SkinFrame()
  if not X.initialized then return end
  local tex = LSM:Fetch('statusbar',db.raidFrames.texture)
  if not tex then return end
  for i=1,40 do
    local frame = _G["CompactRaidFrame" .. i]
    if frame and frame.unitExists then
      -- modify frame functions -- 
      if not frame.modified then
        frame.modified = true
        frame.healthBar.setSBTex = frame.healthBar.SetStatusBarTexture
        frame.healthBar.SetStatusBarTexture = function(self,texture,...)
          self:setSBTex(tex)
        end
        frame.healthBar.background.setTex = frame.healthBar.background.SetTexture
        frame.healthBar.background.SetTexture = function(self,texture,...)
          self:setTex(tex)
        end
        frame.powerBar.setSBTex = frame.powerBar.SetStatusBarTexture
        frame.powerBar.SetStatusBarTexture = function(self,texture,...)
          self:setSBTex(tex)
        end
        frame.powerBar.background.setTex = frame.powerBar.background.SetTexture
        frame.powerBar.background.SetTexture = function(self,texture,...)
          self:setTex(tex)
        end
      end
       -- texture -- 
      frame.healthBar:SetStatusBarTexture(tex)
      frame.healthBar.background:SetTexture(tex)
      frame.powerBar:SetStatusBarTexture(tex)
      frame.powerBar.background:SetTexture(tex)
      -- colors --
      frame.powerBar.background:SetVertexColor(0.2,0.2,0.2)
      local _,class = UnitClass(frame.unit)
      local colors = db.UFColors[class]
      if db.raidFrames.useClassBG and colors then
        -- class BG --
        frame.healthBar.background:SetVertexColor(colors[1],colors[2],colors[3])
        frame.healthBar:SetStatusBarColor(0.1,0.1,0.1)
      elseif colors then
        -- class FG --
        frame.healthBar.background:SetVertexColor(0.1,0.1,0.1)
        frame.healthBar:SetStatusBarColor(colors[1],colors[2],colors[3])
      end
      -- power Color -- 
      local power = UnitPowerType(frame.unit)
      local powColors = db.UFPowerColors[power]
      if powColors then
        frame.powerBar:SetStatusBarColor(powColors[1],powColors[2],powColors[3])
      end
      -- selection highlight --
      frame.selectionHighlight:SetVertexColor(unpack(db.raidFrames.selectionHighlightColor))
      -- text --
      if db.raidFrames.classColorName and colors then
        frame.name:SetTextColor(colors[1],colors[2],colors[3])
      else
        frame.name:SetTextColor(1,1,1)
      end
    end
  end
end

local function init()
  db = E.db.elvality
  if not db.raidFrames then 
    db.raidFrames = {}
  end
  db.raidFrames = X.AddMissingTableEntries(db.raidFrames,DB_DEFAULT)
  SkinFrame(db.raidFrames.texture)
end
tinsert(X.init,init)

local f = CreateFrame("Frame")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:SetScript("OnEvent",function() SkinFrame() end)
local function checkframe(f)
  if f and f:GetName():find("CompactRaidFrame") then
    SkinFrame()
  end
end
hooksecurefunc("CompactUnitFrame_UpdateHealthColor",checkframe)


local function options()
  local statusBarTextures = LSM:List("statusbar")
  local sbO = E.Options.args.elvality.args.blizzard.args
  local values = {}
  for _,texture in ipairs(statusBarTextures) do
    values[texture] = texture
  end
  sbO.texture = {
    type = "select",
    order = 10,
    name = L["Health Bar Texture"],
    values = values,
    get = function() return db.raidFrames.texture end,
    set = function(self,value) 
      db.raidFrames.texture = value 
      SkinFrame() 
    end
  }
  sbO.classBackdrop = {
    type = "toggle",
    name = L["Use Class Backdrop"],
    order = 11,
    get = function() return db.raidFrames.useClassBG end,
    set = function(self,value)
      db.raidFrames.useClassBG = value
      SkinFrame()
    end
  }
  sbO.selectionHighlightColor = {
    type = "color",
    name = L["Selection Highlight Color"],
    order = 12,
    hasAlpha = true,
    get = function() return unpack(db.raidFrames.selectionHighlightColor) end,
    set = function(self,r,g,b,a) db.raidFrames.selectionHighlightColor = {r,g,b,a} SkinFrame() end
  }
  sbO.classColorName = {
    type = "toggle",
    name = L["Use Class Color Name"],
    order = 13,
    get = function() return db.raidFrames.classColorName end,
    set = function(self,value)
      db.raidFrames.classColorName = value
      SkinFrame()
    end
  }
end
tinsert(X.configs,options)