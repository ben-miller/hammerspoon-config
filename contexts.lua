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

function contexts.loadWritingContext()

    local win = nil

    -- Hide all windows
    hideAllWindows()

    -- Open writing context in Obsidian
    local writingContextUrl = "obsidian://open?vault=life&file=Areas%2FLeisure%2FWriting%2FWriting%20Context"
    hs.urlevent.openURL(writingContextUrl)
    hs.application.launchOrFocus("Obsidian")
    local obsidian = hs.application.find("Obsidian")
    if obsidian then
        win = obsidian:mainWindow()
        w.moveToLG(win)
        w.moveMiddleTwoThirds(win)
    end

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
    local obsidian = hs.application.find("Obsidian")
    if obsidian then
        win = obsidian:mainWindow()
        w.moveToRTK(win)
        w.maximize(win)
    end

    -- Open SourceTree
    hs.application.launchOrFocus("SourceTree")
    local sourcetree = hs.application.find("SourceTree")
    if sourcetree then
        win = sourcetree:mainWindow()
        w.moveToRTK(win)
        w.maximize(win)
    end

    -- Open Firefox in main screen
    hs.application.launchOrFocus(C.Firefox)
    local firefox = hs.application.find(C.Firefox)
    if firefox then
        win = firefox:mainWindow()
        w.moveToRetina(win)
        w.maximize(win)
    end

    -- Open iTerm
    hs.application.launchOrFocus("iTerm")
    local iterm = hs.application.find("iTerm")
    if iterm then
        win = iterm:mainWindow()
        w.moveToLG(win)
        w.maximize(win)
    end

    -- Show alert
    hs.alert.show("Dev context loaded")
end

-- Now called main context
function contexts.loadExecutionContext()

    local win = nil

    -- Hide all windows
    hideAllWindows()

    -- Open GMail
    hs.application.launchOrFocus("GMail")
    local gmail = hs.application.find("GMail")
    if gmail then
        win = gmail:mainWindow()
        w.moveToRTK(win)
        w.maximize(win)
    end

    -- Open GCal
    hs.application.launchOrFocus("GCal")
    local sourcetree = hs.application.find("GCal")
    if sourcetree then
        win = sourcetree:mainWindow()
        w.moveToRTK(win)
        w.moveRightHalf(win)
    end

    -- Open Firefox in LG
    hs.application.launchOrFocus(C.Firefox)
    local firefox = hs.application.find(C.Firefox)
    if firefox then
        win = firefox:mainWindow()
        w.moveToLG(win)
        w.maximize(win)
    end

    -- Open main context in Obsidian
    hs.application.launchOrFocus("Obsidian")
    local execContextUrl = "obsidian://open?vault=life&file=Areas%2FExecution%2FMain%20Context"
    hs.urlevent.openURL(execContextUrl)
    local obsidian = hs.application.find("Obsidian")
    if obsidian then
        win = obsidian:mainWindow()
        w.moveToLG(win)
        w.moveRightHalf(win)
    end

    -- Show alert
    hs.alert.show("Execution context loaded")
end

function contexts.loadLeisureContext()

    local win = nil

    -- Hide all windows
    hideAllWindows()

    -- Open GCal
    hs.application.launchOrFocus("GCal")
    local sourcetree = hs.application.find("GCal")
    if sourcetree then
        win = sourcetree:mainWindow()
        w.moveToRTK(win)
        w.maximize(win)
    end

    -- Open execution context in Obsidian
    hs.application.launchOrFocus("Obsidian")
    local execContextUrl = "obsidian://open?vault=life&file=Areas%2FLeisure%2FLeisure%20Context"
    hs.urlevent.openURL(execContextUrl)
    local obsidian = hs.application.find("Obsidian")
    if obsidian then
        win = obsidian:mainWindow()
        w.moveToRTK(win)
        w.maximize(win)
    end

    -- Open Firefox in Retina
    hs.application.launchOrFocus(C.Firefox)
    local firefox = hs.application.find(C.Firefox)
    if firefox then
        win = firefox:mainWindow()
        w.moveToRetina(win)
        w.maximize(win)
    end

    -- Show alert
    hs.alert.show("Leisure context loaded")
end

-- Debugging shortcut
hs.hotkey.bind(hyper, "2", function()
    hs.alert.show("Debugging shortcut for contexts.lua pressed")
end)

return contexts

