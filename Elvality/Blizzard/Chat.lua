local addon,ELV = ...
local X,E,L,V,P,G = unpack(ELV)

local function MoveChatTabs()
  -- TABS --
  local frame = GeneralDockManager
  local point1, relativeTo1, relativePoint1, xOfs1, yOfs1 = frame:GetPoint(1)
  local point2, relativeTo2, relativePoint2, xOfs2, yOfs2 = frame:GetPoint(2)
  frame:ClearAllPoints()

  frame:SetPoint("TOPLEFT",relativeTo1,"BOTTOMLEFT",xOfs1,5)
  frame:SetPoint("TOPRIGHT",relativeTo2,"BOTTOMRIGHT",xOfs2,5)

  -- MOVE ChatFrameX up --
  for i=1,NUM_CHAT_WINDOWS do
    if i ~= 2 then
      local chat = _G["ChatFrame"..i]
      if chat then
        local p,rt,rp,x,y = chat:GetPoint()
        chat:ClearAllPoints()
        chat:SetPoint(p,rt,rp,x,frame:GetHeight())
      end
    end
  end
end

local function init()
  C_Timer.NewTicker(3,function() MoveChatTabs() end) -- hmmm
end
table.insert( X.init, init )