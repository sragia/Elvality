local addon,ELV = ...
local X,E,L,V,P,G = unpack(ELV)

local iconPaths = {
  leader = [[Interface\GROUPFRAME\UI-Group-LeaderIcon]],
  assistant = [[Interface\GROUPFRAME\UI-GROUP-ASSISTANTICON]]
}

local UF = E:GetModule("UnitFrames")

local function CreateLeaderIcon()
  local frame = CreateFrame("Frame",UF.player)
  UF.player.leaderIcon = frame
  frame:SetSize(14,14)
  frame:SetPoint("TOPLEFT",UF.player,5,7)
  local texture = frame:CreateTexture(nil,"ARTWORK")
  texture:SetTexture(iconPaths.leader)
  texture:SetAllPoints()
  frame:RegisterEvent("GROUP_ROSTER_UPDATE")
  frame:SetScript("OnEvent",function(self) 
    if UnitIsGroupLeader('player') then
      self:Show()
    else
      self:Hide()
    end
  end)
  if not UnitIsGroupLeader('player') then
    frame:Hide()
  end
end
local function CreateAssistantIcon()
  local frame = CreateFrame("Frame",UF.player)
  UF.player.assistantIcon = frame
  frame:SetSize(14,14)
  frame:SetPoint("TOPLEFT",UF.player,5,7)
  local texture = frame:CreateTexture(nil,"ARTWORK")
  texture:SetTexture(iconPaths.assistant)
  texture:SetAllPoints()
  frame:RegisterEvent("GROUP_ROSTER_UPDATE")
  frame:SetScript("OnEvent",function(self) 
    if UnitIsGroupAssistant('player') then
      self:Show()
    else
      self:Hide()
    end
  end)
  if not UnitIsGroupAssistant('player') then
    frame:Hide()
  end
end

local function init()
  CreateLeaderIcon()
  CreateAssistantIcon()
end
table.insert( X.init, init )