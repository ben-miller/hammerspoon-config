
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
local C = require('./constants')
local w = require('./windowmanager')
local contexts = require('./contexts')
local _ = require('underscore')

local hyper = w.hyper
local hypo = w.hypo

-- Bind hotkey to hammerspoon console
hs.hotkey.bind(hyper, "\\", function()
    hs.toggleConsole()
end)

-- Shortcuts modal
local shortcutModal = nil
function showShortcuts()
    if not shortcutModal then
        local shortcuts = "file://" .. home .. "/.hammerspoon/shortcuts/sample.html"

        -- Get built-in retina display dimensions
        local mainScreen = hs.screen.mainScreen()
        local screenFrame = mainScreen:frame()

        local webViewFrame = {
            x = screenFrame.x + 100,
            y = screenFrame.y + 100,
            w = screenFrame.w - 200,
            h = screenFrame.h - 200
        }

        shortcutModal = hs.webview.new(webViewFrame)

        -- Set to floating
        shortcutModal:level(hs.drawing.windowLevels.floating)

        -- Make it semi-transparent
        shortcutModal:alpha(0.8)

        -- Center it on the "Built-in Retina Display"
        local mainScreen = hs.screen.mainScreen()
        local mainRes = mainScreen:fullFrame()
        local modalFrame = shortcutModal:frame()
        modalFrame.x = (mainRes.w - modalFrame.w) / 2

        shortcutModal:url(shortcuts) -- Update with the correct path
        shortcutModal:windowStyle("utility")
        shortcutModal:windowTitle("Shortcuts")
        shortcutModal:closeOnEscape(true)
    end
    shortcutModal:show()
end
function hideShortcuts()
    if shortcutModal then
        shortcutModal:hide()
    end
end
hs.hotkey.bind(hyper, "/", showShortcuts, hideShortcuts)

-- Utility functions
function fuzzyCompare(a, b)
    return math.abs(a - b) < 2
end

w.bindAppLauncher("S", "Stickies")
w.bindAppLauncher(".", C.Firefox)
w.bindAppLauncher("O", "Obsidian")
w.bindAppLauncher("I", "IntelliJ IDEA")
w.bindAppLauncher("G", "GMail")
w.bindAppLauncher("C", "GCal")
w.bindAppLauncher("L", "LibraryThing")
w.bindAppLauncher("F", "Finder")
w.bindAppLauncher("T", "Agenda") -- Trello
w.bindAppLauncher("M", "iTerm2")
w.bindAppLauncher(";", "Timer")
w.bindAppLauncher("E", "SourceTree")

-- Maximize current window
hs.hotkey.bind(hypo, "Up", function()
    w.maximize()
end)

-- Move current window to middle 2/3
hs.hotkey.bind(hypo, "Down", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    if (fuzzyCompare(f.x, max.x + max.w / 6)) then
        -- If in middle 2/3, move to middle 1/3
        w.moveMiddleThird()
    else
        -- If not in middle, move to middle 2/3
        w.moveMiddleTwoThirds()
    end
end)

-- Move current window to left half of screen
hs.hotkey.bind(hypo, "Left", function()
    w.moveLeftHalf()
end)

-- Move current window to right half of screen
hs.hotkey.bind(hypo, "Right", function()
    w.moveRightHalf()
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
    w.moveToScreenLeft()
end)

-- Move current window to screen right
hs.hotkey.bind(hyper, "Right", function()
    w.moveToScreenRight()
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
    hs.application.launchOrFocus(C.Firefox)
    local focused = hs.window.focusedWindow()
    local app = hs.application.find(C.Firefox)
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
