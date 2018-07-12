local addon,ELV = ...
local X,E,L,V,P,G = unpack(ELV)
local db


local function ChangeObjectiveFrameScale(newScale) 
  local oldScale = ObjectiveTrackerFrame:GetScale()
  ObjectiveTrackerFrame:SetScale(newScale)
  local point, relativeTo, relativePoint, xOfs, yOfs = ObjectiveTrackerFrame:GetPoint()
  local change = 1 - newScale/oldScale
  xOfs = xOfs/(1 - change)
  yOfs = yOfs/(1 - change)
  ObjectiveTrackerFrame:ClearAllPoints()
  ObjectiveTrackerFrame:SetPoint(point,relativeTo,relativePoint,xOfs,yOfs)
end

local function init()
  db = E.db.elvality
  if not db.objectiveFrame then
    db.objectiveFrame = {
      scale = 1,
    }
  end
  ChangeObjectiveFrameScale(db.objectiveFrame.scale)
end
tinsert(X.init,init)


local function options()
  E.Options.args.elvality.args.blizzard.args.objectiveframe = {
    type = "range",
    name = L["Objective Frame Scale"],
    order = 1,
    min = 0.05,
    max = 2,
    step = 0.01,
    get = function() return db.objectiveFrame.scale end,
    set = function(self,value) 
      db.objectiveFrame.scale = value
      ChangeObjectiveFrameScale(value)
    end,
  }
end
tinsert(X.configs,options)