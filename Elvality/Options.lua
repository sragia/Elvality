local addon,ELV = ...
local X,E,L,V,P,G = unpack(ELV)

local function coreOptions()
  E.Options.args.elvality = {
    type = "group",
    name = WrapTextInColorCode("Elvality",X.colors.main),
    desc = L["Plugin by Exality. Contains various minor tweaks"],
    order = 10,
    args = {
      exalitySkins = {
        type = "group",
        order = 1,
        name = L["Exality Skins"],
        childGroups = "tab",
        args = {}
      },
      blizzard = {
        type = "group",
        order = 2,
        name = L["Blizzard"],
        childGroups = "tab",
        args = {}
      },
      colors = {
        type = "group",
        order = 30,
        name = L["Colors"],
        childGroups = "tab",
        args = {}
      },
    },
  }
end
tinsert(X.configs,coreOptions)
