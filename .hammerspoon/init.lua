-- TODO Shortcut for own HS config documentation
-- TODO Shortcut for editing HS config
-- TODO Shortcut for HS console
-- TODO Shortcut for reloading HS

local home = os.getenv("HOME")
local log = hs.logger.new("main", "verbose") -- Use 'log.e(xxx)'
local dumper = require('dumper')
local windowManager = require('./windowmanager')
local _ = require('underscore')

-- Reload config whenever any *.lua file in ~/.hammerspoon changes
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
watcher = hs.pathwatcher.new(home .. "/.hammerspoon/", reloadConfig):start()

local hyper = { "cmd", "ctrl", "alt" }
local hypo = { "ctrl", "alt" }

function fuzzyCompare(a, b)
    return math.abs(a - b) < 2
end

function bindAppLauncher(key, app)
    hs.hotkey.bind(hyper, key, function()
        hs.application.launchOrFocus(app)
    end)
end

bindAppLauncher("S", "Stickies")
bindAppLauncher("F", "Firefox")
bindAppLauncher("O", "Obsidian")
bindAppLauncher("I", "IntelliJ IDEA")
bindAppLauncher("G", "GMail")
bindAppLauncher("C", "GCal")
bindAppLauncher("L", "LibraryThing")

-- Maximize current window
hs.hotkey.bind(hypo, "Up", function()
    windowManager.maximize()
end)

-- Move current window to middle 2/3
hs.hotkey.bind(hypo, "Down", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    -- Fuzzy compare f.x == max.x + max.w / 6
    if (fuzzyCompare(f.x, max.x + max.w / 6)) then
        -- If in middle 2/3, move to middle 1/3
        windowManager.moveMiddleThird()
    else
        -- If not in middle, move to middle 2/3
        windowManager.moveMiddleTwoThirds()
    end
end)

-- Move current window to left half of screen
hs.hotkey.bind(hypo, "Left", function()
    windowManager.moveLeftHalf()
end)

-- Move current window to right half of screen
hs.hotkey.bind(hypo, "Right", function()
    windowManager.moveRightHalf()
end)

-- Focus on window to left
hs.hotkey.bind(hypo, "H", function()
    local win = hs.window.focusedWindow()
    local res = win.focusWindowWest()
end)

-- Focus on window to right
hs.hotkey.bind(hypo, "L", function()
    local win = hs.window.focusedWindow()
    local res = win.focusWindowEast()
end)

-- Focus on window below
hs.hotkey.bind(hypo, "J", function()
    local win = hs.window.focusedWindow()
    local res = win.focusWindowSouth()
end)

-- Focus on window above
hs.hotkey.bind(hypo, "K", function()
    local win = hs.window.focusedWindow()
    local res = win.focusWindowNorth()
end)

-- Move current window to screen left
hs.hotkey.bind(hyper, "Left", function()
    windowManager.moveToScreenLeft()
end)

-- Move current window to screen right
hs.hotkey.bind(hyper, "Right", function()
    windowManager.moveToScreenRight()
end)

-- Toggle WIFI power
hs.hotkey.bind(hyper, "W", function()
    local wifiPower = hs.wifi.interfaceDetails().power
    if (wifiPower) then
        hs.wifi.setPower(false)
    else
        hs.wifi.setPower(true)
    end
end)

-- Open New Tab
hs.hotkey.bind(hyper, "T", function()
    hs.urlevent.openURL("http://localhost:8282/index.html")
end)

-- URL encoding
-- https://gist.github.com/liukun/f9ce7d6d14fa45fe9b924a3eed5c3d99

local char_to_hex = function(c)
    return string.format("%%%02X", string.byte(c))
end

local function urlencode(url)
    if url == nil then
        return
    end
    url = url:gsub("\n", "\r\n")
    url = url:gsub("([^%w ])", char_to_hex)
    url = url:gsub(" ", "+")
    return url
end

local function focusOtherBrowserWindow()
    hs.application.launchOrFocus("Firefox")
    local focused = hs.window.focusedWindow()
    local app = hs.application.find("Firefox")
    local windows = app:allWindows()
    if #windows > 1 then
        _.each(windows, function(window)
            if window ~= focused then
                window:focus()
            end
        end)
    end
end

local function formattedSearchTermFromClipboard()
    local term = hs.pasteboard.readString()
    term = string.sub(term, 0, 100)
    term = urlencode(term)
    return term
end

-- Translate term in gTranslate
hs.hotkey.bind(hypo, "T", function()
    local term = formattedSearchTermFromClipboard()
    local url = string.format("https://translate.google.com/?sl=ja&tl=en&text=%s&op=translate", term)
    focusOtherBrowserWindow()
    hs.urlevent.openURL(url)
end)

-- Kill Apple Music as soon as it opens
function applicationMusicWatcher(appName, eventType, appObject)
    if (eventType == hs.application.watcher.launching) then
        if (appName == "Music") then
            local op, stat, typ, ec = hs.execute([["/usr/bin/killall" "Music"]])
            hs.alert.show("Killed Apple Music")
            if not (ec == 0) then
                msg = "An error occurred terminating Music."
                hs.notify.new({title="Hammerspoon", informativeText=msg}):send()
            end                     
        end
    end
end
appMusicWatcher = hs.application.watcher.new(applicationMusicWatcher)
appMusicWatcher:start()

-- Announce that config has changed
hs.alert.show("Config loaded")
