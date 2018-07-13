local addon,ELV = ...
local X,E,L,V,P,G = unpack(ELV)
local db
local LSM = LibStub("LibSharedMedia-3.0")
-- Register Some Blizzard stuff for LSM
LSM:Register("statusbar","Blizzard Absorb Overlay", [[Interface\RaidFrame\Shield-Overlay]])
local _G = _G
local DB_DEFAULT = {
  texture = "Blizzard Raid Bar",
  absorbTexture = "Blizzard Absorb Overlay",
  absorbTextureColor = {1,1,1,1},
  myHealPredictionColor = {1,1,1,1},
  otherHealPredictionColor = {1,1,1,1},
  selectionHighlightColor = {1,1,1,1},
  powerBarHeight = 9,
  useClassBG = false,
  classColorName = false,
  showGroupLabel = true,
  showRaidFrameManager = true,
}

local modifiedFunctions = {
  -- HealthBar Textures --
  {func = "SetStatusBarTexture", keys = {"healthBar"}, defaultTo = "tex"},
  {func = "SetTexture",keys = {"healthBar","background"}, defaultTo = "tex"},
  -- PowerBar Textures --
  {func = "SetStatusBarTexture", keys = {"powerBar"}, defaultTo = "tex"},
  {func = "SetTexture",keys = {"powerBar","background"}, defaultTo = "tex"},
  {func = "SetStatusBarColor", keys = {"powerBar"}, defaultTo = "col"},
  -- Absorb Texture --
  {func = "SetTexture",keys = {"powerBar","totalAbsorbOverlay"}, defaultTo = "tex"},
}

local function ModifyFrame(frame,funcKey,defaultToKey)
  local tmpfunc = "__"..funcKey
  frame[tmpfunc] = frame[funcKey]
  frame[funcKey] = function(...)
    if type(frame[defaultToKey]) == "table" then
      frame[tmpfunc](frame,unpack(frame[defaultToKey]))
    else
      frame[tmpfunc](frame,frame[defaultToKey])
    end
  end
end

local function GetFrame(frame,keyTable)
  local tmp = frame
  for _,key in ipairs(keyTable) do
    tmp = tmp[key]
  end
  return tmp
end

local function SkinFrame(frame)
  local tex = LSM:Fetch('statusbar',db.raidFrames.texture)
  local absorbTex = LSM:Fetch('statusbar',db.raidFrames.absorbTexture)
  if frame and frame.unitExists then
    -- modify frame functions -- 
    if not frame.modified then
      frame.modified = true
      for _,modify in ipairs(modifiedFunctions) do
        local f = GetFrame(frame,modify.keys)
        if f then
          ModifyFrame(f,modify.func,modify.defaultTo)
        end
      end
    end
     -- texture -- 
    frame.healthBar.tex = tex
    frame.healthBar:SetStatusBarTexture(tex)
    frame.healthBar.background.tex = tex
    frame.healthBar.background:SetTexture(tex)
    frame.powerBar.tex = tex
    frame.powerBar:SetStatusBarTexture(tex)
    frame.powerBar.background.tex = tex
    frame.powerBar.background:SetTexture(tex)
    frame.totalAbsorbOverlay.tex = absorbTex
    frame.totalAbsorbOverlay:SetTexture(absorbTex)
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
      frame.powerBar.col = powColors
      frame.powerBar:SetStatusBarColor(powColors[1],powColors[2],powColors[3])
    end
    -- absorb overlay Color --
    frame.totalAbsorb:SetVertexColor(unpack(db.raidFrames.absorbTextureColor))
    frame.totalAbsorbOverlay:SetVertexColor(unpack(db.raidFrames.absorbTextureColor))
    frame.overAbsorbGlow:SetVertexColor(unpack(db.raidFrames.absorbTextureColor))
    -- Heal Prediction Color --
    frame.myHealPrediction:SetVertexColor(unpack(db.raidFrames.myHealPredictionColor))
    frame.otherHealPrediction:SetVertexColor(unpack(db.raidFrames.otherHealPredictionColor))
    -- selection highlight --
    frame.selectionHighlight:SetVertexColor(unpack(db.raidFrames.selectionHighlightColor))
    -- text --
    if db.raidFrames.classColorName and colors then
      frame.name:SetTextColor(colors[1],colors[2],colors[3])
    else
      frame.name:SetTextColor(1,1,1)
    end
    -- Power Bar Height --
    local point, relativeTo, relativePoint, xOfs, yOfs = frame.healthBar:GetPoint(2)
    frame.healthBar:SetPoint(point, relativeTo, relativePoint, xOfs, db.raidFrames.powerBarHeight)
  end
end

local function SkinRaidFrames()
  if not X.initialized then return end
  for i=1,40 do
    local frame = _G["CompactRaidFrame" .. i]
    SkinFrame(frame)
  end
  for i=1,5 do
    local frame = _G["CompactPartyFrameMember" .. i]
    SkinFrame(frame)
  end
  for grp=1,8 do
    for member=1,5 do
      local frame = _G["CompactRaidGroup"..grp.."Member"..member]
      SkinFrame(frame)
    end
  end
  if not db.raidFrames.showGroupLabel then
    -- Hide
    local partyFrame =  _G["CompactPartyFrame"]
    if partyFrame and partyFrame:IsShown() then
      -- PARTY
      partyFrame.title:Hide()
      local memberFrame = _G["CompactPartyFrameMember1"]
      memberFrame:ClearAllPoints()
      memberFrame:SetPoint("TOPLEFT",partyFrame,0,0)
      if CUF_HORIZONTAL_GROUPS then
        -- Horizontal
        local memberHeight = memberFrame:GetHeight()
        partyFrame:ClearAllPoints()
        partyFrame:SetPoint("TOPLEFT",CompactRaidFrameContainer,0,0)
        partyFrame:SetHeight(memberHeight)
      end
    else
      -- RAID
      local actualGrp = 0
      for grp = 1,8 do
        local grpFrame = _G["CompactRaidGroup"..grp]
        if grpFrame and grpFrame.title:IsShown() then
          actualGrp = actualGrp + 1
          grpFrame.title:Hide()
          local memberFrame = _G["CompactRaidGroup"..grp.."Member1"]
          memberFrame:ClearAllPoints()
          memberFrame:SetPoint("TOPLEFT",grpFrame,0,0)
          if CUF_HORIZONTAL_GROUPS then
            -- Horizontal
            local memberHeight = memberFrame:GetHeight()
            grpFrame:ClearAllPoints()
            grpFrame:SetPoint("TOPLEFT",CompactRaidFrameContainer,0,-(actualGrp-1)*memberHeight)
            grpFrame:SetHeight(memberHeight)
          end
        end
      end
    end
  else
    -- Show
    local partyFrame =  _G["CompactPartyFrame"]
    if partyFrame and partyFrame:IsShown() then
      -- PARTY
      partyFrame.title:Show()
      local memberFrame = _G["CompactPartyFrameMember1"]
      memberFrame:ClearAllPoints()
      memberFrame:SetPoint("TOPLEFT",partyFrame,0,-14)
      if CUF_HORIZONTAL_GROUPS then
        -- Horizontal
        partyFrame:ClearAllPoints()
        partyFrame:SetPoint("TOPLEFT",CompactRaidFrameContainer,0,0)
        partyFrame:SetHeight(14+memberFrame:GetHeight())
      end
    else
      -- RAID
      local actualGrp = 0
      for grp = 1,8 do
        local grpFrame = _G["CompactRaidGroup"..grp]
        if grpFrame and not grpFrame.title:IsShown() then
          actualGrp = actualGrp + 1
          grpFrame.title:Show()
          local memberFrame = _G["CompactRaidGroup"..grp.."Member1"]
          memberFrame:ClearAllPoints()
          memberFrame:SetPoint("TOPLEFT",grpFrame,0,-14)
          if CUF_HORIZONTAL_GROUPS then
            -- Horizontal
            local memberHeight = memberFrame:GetHeight()
            grpFrame:ClearAllPoints()
            grpFrame:SetPoint("TOPLEFT",CompactRaidFrameContainer,0,-(actualGrp-1)*memberHeight-(actualGrp-1)*(14))
            grpFrame:SetHeight(memberHeight + 14)
          end
        end
      end
    end
  end
end

local function HideRaidManager()
  local point, relativeTo, relativePoint, xOfs, yOfs = CompactRaidFrameManager:GetPoint()
  CompactRaidFrameManager:ClearAllPoints()
  CompactRaidFrameManager:SetPoint(point, relativeTo, relativePoint, xOfs-100, yOfs)
end

local function ShowRaidManager()
  local point, relativeTo, relativePoint, xOfs, yOfs = CompactRaidFrameManager:GetPoint()
  CompactRaidFrameManager:ClearAllPoints()
  CompactRaidFrameManager:SetPoint(point, relativeTo, relativePoint, xOfs+100, yOfs)
end

local function ToggleRaidManager()
  if CompactRaidFrameManager and CompactRaidFrameManager.hidden == nil then
    -- INIT --
    if not db.raidFrames.showRaidFrameManager then
      HideRaidManager()
      CompactRaidFrameManager.hidden = true
    else
      CompactRaidFrameManager.hidden = false
    end
  elseif db.raidFrames.showRaidFrameManager and CompactRaidFrameManager and CompactRaidFrameManager.hidden == true then
    ShowRaidManager()
    CompactRaidFrameManager.hidden = false
  elseif not db.raidFrames.showRaidFrameManager and CompactRaidFrameManager and CompactRaidFrameManager.hidden == false then
    HideRaidManager()
    CompactRaidFrameManager.hidden = true
  end
end

local function init()
  db = E.db.elvality
  if not db.raidFrames then 
    db.raidFrames = {}
  end
  db.raidFrames = X.AddMissingTableEntries(db.raidFrames,DB_DEFAULT)
  SkinRaidFrames(db.raidFrames.texture)

  hooksecurefunc(CompactRaidFrameManager,"Show",function() ToggleRaidManager() end)
end
tinsert(X.init,init)

local f = CreateFrame("Frame")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:SetScript("OnEvent",function() SkinRaidFrames() end)
local function checkframe(f)
  if f and f:GetName():find("CompactRaidFrame") then
    SkinRaidFrames()
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
  sbO.raidFrames = {
    type = "group",
    name = L["Raid Frames"],
    order = 2,
    args = {}
  }
  local raidFrames = sbO.raidFrames.args
  raidFrames.healthtexture = {
    type = "select",
    order = 1,
    name = L["Health Bar Texture"],
    values = values,
    get = function() return db.raidFrames.texture end,
    set = function(self,value) 
      db.raidFrames.texture = value 
      SkinRaidFrames() 
    end
  }
  raidFrames.absorbTexture = {
    type = "select",
    name = L["Absorb Overlay Texture"],
    order = 2,
    values = values,
    get = function() return db.raidFrames.absorbTexture end,
    set = function(self,value) 
      db.raidFrames.absorbTexture = value 
      SkinRaidFrames() 
    end
  }
  raidFrames.powerBarHeight = {
    type = "range",
    name = L["Power Bar Height"],
    order = 2.1,
    min = 1,
    max = 20,
    step = 1,
    get = function() return db.raidFrames.powerBarHeight end,
    set = function(self,value) 
      db.raidFrames.powerBarHeight = value
      SkinRaidFrames()
    end,
  }
  raidFrames.selectionHighlightColor = {
    type = "color",
    name = L["Selection Highlight Color"],
    order = 3,
    hasAlpha = true,
    get = function() return unpack(db.raidFrames.selectionHighlightColor) end,
    set = function(self,r,g,b,a) db.raidFrames.selectionHighlightColor = {r,g,b,a} SkinRaidFrames() end
  }
  raidFrames.absorbTextureColor = {
    type = "color",
    name = L["Absorb Overlay Color"],
    order = 4,
    hasAlpha = true,
    get = function() return unpack(db.raidFrames.absorbTextureColor) end,
    set = function(self,r,g,b,a) db.raidFrames.absorbTextureColor = {r,g,b,a} SkinRaidFrames() end
  }
  raidFrames.myHealPredictionColor = {
    type = "color",
    name = L["My Heal Prediction Color"],
    order = 5,
    hasAlpha = true,
    get = function() return unpack(db.raidFrames.myHealPredictionColor) end,
    set = function(self,r,g,b,a) db.raidFrames.myHealPredictionColor = {r,g,b,a} SkinRaidFrames() end
  }
  raidFrames.otherHealPredictionColor = {
    type = "color",
    name = L["Other's Heal Prediction Color"],
    order = 6,
    hasAlpha = true,
    get = function() return unpack(db.raidFrames.otherHealPredictionColor) end,
    set = function(self,r,g,b,a) db.raidFrames.otherHealPredictionColor = {r,g,b,a} SkinRaidFrames() end
  }
  raidFrames.classBackdrop = {
    type = "toggle",
    name = L["Use Class Backdrop"],
    order = 7,
    get = function() return db.raidFrames.useClassBG end,
    set = function(self,value)
      db.raidFrames.useClassBG = value
      SkinRaidFrames()
    end
  }
  raidFrames.classColorName = {
    type = "toggle",
    name = L["Use Class Color Name"],
    order = 8,
    get = function() return db.raidFrames.classColorName end,
    set = function(self,value)
      db.raidFrames.classColorName = value
      SkinRaidFrames()
    end
  }
  raidFrames.ToggleRaidManager = {
    type = "toggle",
    name = L["Show Raid Manager"],
    order = 9,
    get = function() return db.raidFrames.showRaidFrameManager end,
    set = function(self,value)
      db.raidFrames.showRaidFrameManager = value
      ToggleRaidManager()
    end
  }
  raidFrames.showGroupLabel = {
    type = "toggle",
    name = L["Show Group Label"],
    order = 10,
    get = function() return db.raidFrames.showGroupLabel end,
    set = function(self,value)
      db.raidFrames.showGroupLabel = value
      SkinRaidFrames()
    end
  }
end
tinsert(X.configs,options)