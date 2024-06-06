
-- Reload config whenever any *.lua file in ~/.hammerspoon changes
-- This needs to be loaded before the require statements below.
local home = os.getenv("HOME")
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" or file:sub(-4) == ".html" then
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
local applications = require('./applications')
local contexts = require('./contexts')
local shortcuts = require('./shortcuts')
local _ = require('underscore')

local hyper = w.hyper
local hypo = w.hypo

-- Bind hotkey to hammerspoon console
hs.hotkey.bind(hyper, "\\", function()
    hs.toggleConsole()
end)

function getMostVisibleWindowOnScreen(screen)
    local windowFilter = hs.window.filter.new()
    windowFilter:setScreens(screen:id())
    windowFilter:setOverrideFilter({visible = true, currentSpace = true, allowScreens = screen:id()})

    local windows = windowFilter:getWindows(hs.window.filter.sortByFocusedLast)

    local frontmostWindow = windows[1]  -- Get the most recently focused window
    if not frontmostWindow then
        return nil
    end

    return frontmostWindow
end

function listVisibleWindows()
    -- For each screen, get the list of windows
    local windows = {}
    for i,screen in ipairs(hs.screen.allScreens()) do
        local window = getMostVisibleWindowOnScreen(screen)
        if not window then
            break
        end
        windows[#windows + 1] = window
    end
    return windows
end

-- Shortcuts modal
function showShortcuts()
    -- For each visible window, show a shortcuts modal
    for i,win in ipairs(listVisibleWindows()) do

        -- Get screen of window
        local screen = win:screen()

        -- Show shortcuts modal for screen
        showShortcutsForScreen(screen, win)
    end

end
local shortcutModalsByScreen = {}
function showShortcutsForScreen(screen, window)
    if not shortcutModalsByScreen[screen:id()] then
        local shortcutModal = shortcuts.getShortcutsModalForScreen(screen, window)
        if not shortcutModal then
            return
        end
        shortcutModalsByScreen[screen:id()] = shortcutModal
    end
    shortcutModalsByScreen[screen:id()]:show()
end
function hideShortcuts()
    -- Hide all shortcuts modals
    for i,shortcutModal in pairs(shortcutModalsByScreen) do
        shortcutModal:hide()
    end
end
hs.hotkey.bind(hyper, "/", showShortcuts, hideShortcuts)

-- Utility functions
function fuzzyCompare(a, b)
    return math.abs(a - b) < 2
end

-- For each application in applications.all,
-- bind app launcher.
for i,app in pairs(applications.all) do
    w.bindAppLauncher(app.hotkey, app.appName)
end

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

-- Put system to sleep
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "S", function()
        hs.caffeinate.lockScreen()
        hs.caffeinate.systemSleep()
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
            contexts.loadExecutionContext()
        elseif choice.text == "Writing" then
            contexts.loadWritingContext()
        elseif choice.text == "Dev" then
            contexts.loadDevContext()
        elseif choice.text == "Leisure" then
            contexts.loadLeisureContext()
        end
    end):choices({
        {text="Execution"},
        {text="Writing"},
        {text="Dev"},
        {text="Leisure"},
    })
end

-- On hyper+space, show select mode dialog. If already in select mode, then
-- if hyper+space is pressed again, hide the dialog.
local chooser = selectModeChooser()
hs.hotkey.bind(hyper, "space", function()
    if (chooser:isVisible()) then
        chooser:hide()
    else
        -- Set coordinates of chooser to be in middle of main screen
        local mainScreen = hs.screen.primaryScreen()
        local mainFrame = mainScreen:frame()

        -- Set width to 30% of screen width
        chooser:width(30)

        -- Calculate the position to center the chooser
        local x = mainFrame.x + 400
        local y = mainFrame.y + 200

        -- Show in main screen
        chooser:show({x = x, y = y})
    end
end)

-- Announce that config has changed
hs.alert.show("Config loaded")
