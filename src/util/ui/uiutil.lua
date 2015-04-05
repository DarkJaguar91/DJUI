--
-- Created by
-- User: Brandon
-- Date: 2015-04-05
-- Time: 07:50 AM
--

local NAME = 'DarkJaguar_UI'
local DJUI = LibStub(NAME)

if DJUI.ui and DJUI.ui.util then
    return
end

if not DJUI.ui then
    DJUI.ui = {}
end

DJUI.ui.util = {}
local util = DJUI.ui.util
util.__index = util

function util:CreateMetaFunction(key, object, name)
    local _, prefix, suffix
    if name then
        _,_, prefix, suffix = tostring(key):find('(.*)' .. name ..'(.*)')
    else
        prefix, suffix = key, ''
    end

    if prefix or suffix then
        if object[prefix .. suffix] then
            return function(_, ...)
                return object[prefix .. suffix](object, ...)
            end
        end
    end
end

function util:CommaNumber(v)
    local s = string.format("%d", math.floor(v))
    local pos = string.len(s) % 3
    if pos == 0 then pos = 3 end
    return string.sub(s, 1, pos)
            .. string.gsub(string.sub(s, pos+1), "(...)", ",%1")
end