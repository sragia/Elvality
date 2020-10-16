local addon, ELV = ...
local X, E, L, V, P, G = unpack(ELV)
local db
local DB_DEFAULT = {timeVisible = 100, chatCopyPosition = "TOPRIGHT"}

local function MoveChatTabs()
    -- TABS --
    local frame = GeneralDockManager
    local point1, relativeTo1, relativePoint1, xOfs1, yOfs1 = frame:GetPoint(1)
    local point2, relativeTo2, relativePoint2, xOfs2, yOfs2 = frame:GetPoint(2)
    frame:ClearAllPoints()

    frame:SetPoint("TOPLEFT", relativeTo1, "BOTTOMLEFT", xOfs1, 5)
    frame:SetPoint("TOPRIGHT", relativeTo2, "BOTTOMRIGHT", xOfs2, 5)

    -- MOVE ChatFrameX up --
    for i = 1, NUM_CHAT_WINDOWS do
        if i ~= 2 then
            local chat = _G["ChatFrame" .. i]
            if chat then
                local p, rt, rp, x, y = chat:GetPoint()
                chat:ClearAllPoints()
                chat:SetPoint(p, rt, rp, x, frame:GetHeight())
            end
        end
        -- Copy Chat Tab
        local copyBtn = _G["CopyChatButton" .. i]
        if copyBtn then
            local point, relativeTo, relativePoint, xOfs, yOfs =
                copyBtn:GetPoint()
            copyBtn:ClearAllPoints()
            copyBtn:SetPoint(db.chat.chatCopyPosition, relativeTo, xOfs, yOfs)
        end
    end
end

local function ModifyChatFrames()
    local DB = db.chat
    for _, frameName in pairs(CHAT_FRAMES) do
        local frame = _G[frameName]
        frame:SetTimeVisible(DB.timeVisible)
        frame:SetFadeDuration(1.5);
    end
end

local function init()
    db = E.db.elvality
    if not db.chat then db.chat = {} end
    db.chat = X.AddMissingTableEntries(db.chat, DB_DEFAULT)

    local function options()
        local o = E.Options.args.elvality.args.blizzard.args
        local DB = db.chat
        o.timeVisible = {
            type = "range",
            name = L["Chat Fade Time"],
            desc = "Set the time, lines added to chat are visible before they start to fade",
            order = 10,
            min = 0,
            max = 300,
            step = 1,
            get = function() return DB.timeVisible end,
            set = function(self, value)
                DB.timeVisible = value
                ModifyChatFrames()
            end
        }
        o.chatCopyPosition = {
            type = "select",
            order = 11,
            name = L["Copy Chat Button Position"],
            values = {
                ["TOPRIGHT"] = L["Top Right"],
                ["TOP"] = L["Top"],
                ["TOPLEFT"] = L["Top Left"],
                ["LEFT"] = L["Left"],
                ["BOTTOMLEFT"] = L["Bottom Left"],
                ["BOTTOM"] = L["Bottom"],
                ["BOTTOMRIGHT"] = L["Bottom Right"],
                ["RIGHT"] = L["Right"]
            },
            get = function() return DB.chatCopyPosition end,
            set = function(self, value)
                DB.chatCopyPosition = value
                -- MoveChatTabs()
            end
        }
    end
    tinsert(X.configs, options)

    C_Timer.NewTicker(5, function()
        -- MoveChatTabs()
        ModifyChatFrames()
    end) -- hmmm
end
table.insert(X.init, init)
