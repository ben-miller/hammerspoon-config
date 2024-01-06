local log = hs.logger.new("main", "verbose") -- Use 'log.e(xxx)'
local C = require("./constants")
local w = require("./windowmanager")

local contexts = {}

local hyper = w.hyper
local hypo = w.hypo

function hideAllWindows()
    local allWindows = hs.window.allWindows()
    for _, window in ipairs(allWindows) do
        local app = window:application()
        if app then app:hide() end
    end
end

function rebindTrello(name)
    -- Unbind "T" hotkey
    hs.hotkey.disableAll(hyper, "T")

    -- Rebind "T" hotkey to Trello board of current context
    w.bindAppLauncher("T", name)
end

function contexts.loadWritingContext()

    local win = nil

    -- Hide all windows
    hideAllWindows()

    -- Open writing context in Obsidian
    local writingContextUrl = "obsidian://open?vault=life&file=Areas%2FLeisure%2FWriting%2FWriting%20Context"
    hs.urlevent.openURL(writingContextUrl)
    hs.application.launchOrFocus("Obsidian")
    local obsidian = hs.application.find("Obsidian")
    win = obsidian:mainWindow()
    w.moveToLG(win)
    w.maximize(win)

    -- Open Timer app
    hs.application.launchOrFocus("Timer")

    -- Show alert
    hs.alert.show("Writing context loaded")
end

function contexts.loadDevContext()

    local win = nil

    -- Hide all windows
    hideAllWindows()

    -- Open dev context in Obsidian
    hs.application.launchOrFocus("Obsidian")
    local devContextUrl = "obsidian://open?vault=life&file=Areas%2FDevelopment%2FDevelopment%20Context"
    hs.urlevent.openURL(devContextUrl)

    -- Get Obsidian window
    local obsidian = hs.application.find("Obsidian")
    win = obsidian:mainWindow()

    w.moveToRTK(win)
    w.maximize(win)

    -- Open SourceTree
    hs.application.launchOrFocus("SourceTree")
    local sourcetree = hs.application.find("SourceTree")
    win = sourcetree:mainWindow()
    w.moveToRTK(win)
    w.maximize(win)

    -- Open and rebind Trello (Development)
    hs.application.launchOrFocus("Development")
    local trello = hs.application.find("Development")
    win = trello:mainWindow()
    w.moveToRTK(win)
    w.maximize(win)
    rebindTrello("Development")

    -- Open Firefox in main screen
    hs.application.launchOrFocus(C.Firefox)
    local firefox = hs.application.find(C.Firefox)
    win = firefox:mainWindow()
    w.moveToRetina(win)
    w.maximize(win)

    -- Open iTerm
    hs.application.launchOrFocus("iTerm")
    local iterm = hs.application.find("iTerm")
    win = iterm:mainWindow()
    w.moveToLG(win)
    w.maximize(win)

    -- Show alert
    hs.alert.show("Dev context loaded")
end

-- Debugging shortcut
hs.hotkey.bind(hyper, "2", function()
    hs.alert.show("Debugging shortcut for contexts.lua pressed")
end)

return contexts

