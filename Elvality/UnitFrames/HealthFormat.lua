local addon, ELV = ...
local X, E, L, V, P, G = unpack(ELV)
local EXUF = E:NewModule('Exality UF Format');
local UF = ElvUF
local formats = {}

-- localize
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax

local function ShortenNumber(number)
    if type(number) ~= "number" then number = tonumber(number) end
    if not number then return end
    local affixes = {"", "k", "m", "b", "t"}
    local affix = 1
    local dec = 0
    local num1 = math.abs(number)
    while num1 >= 1000 and affix < #affixes do
        num1 = num1 / 1000
        affix = affix + 1
    end
    if affix > 1 then
        dec = 2
        local num2 = num1
        while num2 >= 10 and dec > 0 do
            num2 = num2 / 10
            dec = dec - 1
        end
    end
    if number < 0 then num1 = -num1 end

    return string.format("%." .. dec .. "f" .. affixes[affix], num1)
end

function EXUF:NewTags()
    -- CURRENT | PERC  [health:current-percent-ex]
    local currPerc = {
        name = 'health:current-percent-ex',
        events = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED',
        method = function(unit)
            local status =
                UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and
                    L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
            if status then return status end
            local curr = UnitHealth(unit)
            local max = UnitHealthMax(unit)
            local perc = curr / max
            if perc == 1 then
                return format("%s | %.0f%%", ShortenNumber(curr), 100)
            end
            return format("%s | %.1f%%", ShortenNumber(curr), perc * 100)
        end
    }
    table.insert(formats, currPerc)

    local perc = {
        name = 'health:percent-ex',
        events = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED',
        method = function(unit)
            local status =
                UnitIsDead(unit) and L["DEAD"] or UnitIsGhost(unit) and
                    L["GHOST"] or not UnitIsConnected(unit) and L["OFFLINE"]
            if status then return status end
            local curr = UnitHealth(unit)
            local max = UnitHealthMax(unit)
            local perc = curr / max
            if perc == 1 then return format("%.0f%%", 100) end
            return format("%.1f%%", perc * 100)
        end
    }
    table.insert(formats, perc)

    -- NAME UPPERCASE [name:uppercase:medium]
    local nameUpper = {
        name = 'name:uppercase:medium',
        events = 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT',
        method = function(unit)
            local name = UnitName(unit)
            if name then
                name = string.upper(name)
                if (strlen(name) > 12) then
                    name = string.sub(name, 1, 9) .. "..."
                end
            end
            return name
        end
    }
    table.insert(formats, nameUpper)

    -- NAME UPPERCASE [name:uppercase:short]
    local nameUpper = {
        name = 'name:uppercase:short',
        events = 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT',
        method = function(unit)
            local name = UnitName(unit)
            if name then
                name = string.upper(name)
                if (strlen(name) > 10) then
                    name = string.sub(name, 1, 7) .. "..."
                end
            end
            return name
        end
    }
    table.insert(formats, nameUpper)

    -- Add
    for _, form in ipairs(formats) do
        UF.Tags.Methods[form.name] = form.method
        UF.Tags.Events[form.name] = form.events
    end
end

function EXUF:Initialize() EXUF:NewTags() end

E:RegisterModule(EXUF:GetName())
