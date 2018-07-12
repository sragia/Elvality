local addon,ELV = ...
local X,E,L,V,P,G = unpack(ELV)

local function coreOptions()
  E.Options.args.elvality = {
    type = "group",
    name = WrapTextInColorCode("Elvality",X.colors.main),
    desc = L["Plugin by Exality. Contains various minor tweaks"],
    order = 10,
    args = {
      test = {
        type = "description",
        order = 1,
        name = L["Testing"],
      },
      blizzard = {
        type = "group",
        order = 1,
        name = L["Blizzard"],
        args = {}
      },
      colors = {
        type = "group",
        order = 30,
        name = L["Colors"],
        args = {}
      },
    },
  }
end
tinsert(X.configs,coreOptions)
