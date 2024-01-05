-- TODO Shortcut for own HS config documentation
-- TODO Shortcut for editing HS config
-- TODO Shortcut for HS console
-- TODO Shortcut for reloading HS

-- Reload config whenever any *.lua file in ~/.hammerspoon changes
-- This needs to be loaded before the require statements below.
local home = os.getenv("HOME")
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

local log = hs.logger.new("main", "verbose") -- Use 'log.e(xxx)'
local dumper = require('dumper')
local windowManager = require('./windowmanager')
local contexts = require('./contexts')
local _ = require('underscore')

local hyper = { "cmd", "ctrl", "alt" }
local hypo = { "ctrl", "alt" }

-- Bind hotkey to hammerspoon console
hs.hotkey.bind(hyper, "\\", function()
    hs.toggleConsole()
end)

function fuzzyCompare(a, b)
    return math.abs(a - b) < 2
end

function bindAppLauncher(key, app)
    hs.hotkey.bind(hyper, key, function()
        local focused = hs.window.focusedWindow()
        local focusedApp = focused:application()

        -- Special logic for iTerm2
        if (app == "iTerm2") then
            hs.application.launchOrFocus("iTerm")
        else
            hs.application.launchOrFocus(app)
        end

        -- If app is already focused, hide it
        if (focusedApp:name() == app) then
            focused:application():hide()
        end
    end)
end

bindAppLauncher("S", "Stickies")
bindAppLauncher("F", "Firefox")
bindAppLauncher("O", "Obsidian")
bindAppLauncher("I", "IntelliJ IDEA")
bindAppLauncher("G", "GMail")
bindAppLauncher("C", "GCal")
bindAppLauncher("L", "LibraryThing")
bindAppLauncher("N", "Finder")
bindAppLauncher("T", "Agenda") -- Trello
bindAppLauncher("M", "iTerm2")
bindAppLauncher(";", "Timer")

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
hs.hotkey.bind(hypo, "T", function()
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

-- Show chooser for selecting between 'Execution', 'Writing', and 'Dev' modes
function selectModeChooser()
    return hs.chooser.new(function(choice)
        if not choice then return end
        if choice.text == "Execution" then
            hs.alert.show("Execution mode loaded")
        elseif choice.text == "Writing" then
            contexts.loadWritingContext()
        elseif choice.text == "Dev" then
            contexts.loadDevContext()
        end
    end):choices({
        {text="Execution"},
        {text="Writing"},
        {text="Dev"},
    })
end

-- On hyper+space, show select mode dialog. If already in select mode, then
-- if hyper+space is pressed again, hide the dialog.
local chooser = selectModeChooser()
hs.hotkey.bind(hyper, "space", function()
    if (chooser:isVisible()) then
        chooser:hide()
    else
        chooser:show()
    end
end)

-- Announce that config has changed
hs.alert.show("Config loaded")
