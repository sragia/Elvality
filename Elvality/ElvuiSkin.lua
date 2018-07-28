local addon,ELV = ...
local X,E,L,V,P,G = unpack(ELV)
local db
local DB_DEFAULT = {
  leftChatPanelAlpha = 1,
}

local function SkinElvui()
  local DB = db.skins
  if LeftChatPanel:IsShown() then
    LeftChatPanel.backdrop:SetAlpha(DB.leftChatPanelAlpha)
  end
end

local function init()
  db = E.db.elvality
  if not db.skins then
    db.skins = {}
  end
  db.skins = X.AddMissingTableEntries(db.skins,DB_DEFAULT)

  local function options()
    local o = E.Options.args.elvality.args.exalitySkins.args
    local DB = db.skins
    o.leftChatPanelAlpha = {
      type = "range",
      name = L["Left Chat Panel Alpha"],
      order = 10,
      min = 0,
      max = 1,
      step = .05,
      get = function() return DB.leftChatPanelAlpha end,
      set = function(self,value)
        DB.leftChatPanelAlpha = value
        SkinElvui()
      end,
    }
  end
  tinsert(X.configs,options)

  SkinElvui()
end
table.insert( X.init, init )
