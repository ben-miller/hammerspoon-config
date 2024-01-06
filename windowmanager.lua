local C = require("./constants")
local log = hs.logger.new("windowmanager.lua", C.LOG_LEVEL)

local windowmanager = {
    -- Keybindings
    hyper = { "cmd", "ctrl", "alt" },
    hypo = { "ctrl", "alt" },

    -- Display names
    builtinRetina = "Built-in Retina Display",
    lg = "LG HDR 4K",
    rtk = "RTK UHD HDR"
}

function windowmanager.bindAppLauncher(key, app)
    hs.hotkey.bind(windowmanager.hyper, key, function()
        local focused = hs.window.focusedWindow()
        if not focused then
            return
        end
        local focusedApp = focused:application()

        -- If app is already focused, hide it
        if (focusedApp:name() == app) then
            focused:application():hide()
        else
            -- Otherwise, focus it (special logic for iTerm2)
            if (app == "iTerm2") then
                hs.application.launchOrFocus("iTerm")
            else
                hs.application.launchOrFocus(app)
            end
        end
    end)
end


-- Move window to display with name
function windowmanager.moveToDisplay(displayName, win)
    local screen = nil
    if (displayName == windowmanager.builtinRetina) then
        screen = hs.screen.primaryScreen()
    else
        screen = hs.screen.findByName(displayName)
    end
    win:moveToScreen(screen)
end

-- Move window to retina display
function windowmanager.moveToRetina(win)
    windowmanager.moveToDisplay(windowmanager.builtinRetina, win)
end

-- Move window to LG display
function windowmanager.moveToLG(win)
    windowmanager.moveToDisplay(windowmanager.lg, win)
end

-- Move window to RTK display
function windowmanager.moveToRTK(win)
    windowmanager.moveToDisplay(windowmanager.rtk, win)
end

-- Print all screens.
function windowmanager.printScreens()
    local screens = hs.screen.allScreens()
    for i, screen in ipairs(screens) do
        print(i, screen:name())
    end
end

function windowmanager.moveLeftHalf()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    if (max.x == f.x and f.w == max.w / 2) then
        -- If already set to left half, set to left 2/3
        f.x = max.x
        f.y = max.y
        f.w = 2 * (max.w / 3)
        f.h = max.h
    else
        -- If not already set to left half, set to left 1/2
        f.x = max.x
        f.y = max.y
        f.w = max.w / 2
        f.h = max.h
    end

    win:setFrame(f)
end

function windowmanager.moveRightHalf()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    if (f.x == max.x + (max.w / 2)) then
        -- If already set to right half, set to right 2/3
        f.x = max.x + (max.w / 3)
        f.y = max.y
        f.w = 2 * (max.w / 3)
        f.h = max.h
    else
        -- If not already set to right half, set to right 1/2
        f.x = max.x + (max.w / 2)
        f.y = max.y
        f.w = max.w / 2
        f.h = max.h
    end

    win:setFrame(f)
end

function windowmanager.moveMiddleTwoThirds()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x + max.w / 6
    f.w = 2 * (max.w / 3)
    f.y = max.y
    f.h = max.h

    win:setFrame(f)
end

function windowmanager.moveMiddleThird()
    local win = hs.window.focusedWindow() local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x + max.w / 3
    f.w = max.w / 3
    f.y = max.y
    f.h = max.h

    win:setFrame(f)
end

function windowmanager.maximize(win)
    if not win then
        win = hs.window.focusedWindow()
    end
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x
    f.y = max.y
    f.w = max.w
    f.h = max.h
    win:setFrame(f)
end

-- Move screen to the left
function windowmanager.moveToScreenLeft()
    local win = hs.window.focusedWindow()
    local screen = win:screen()
    local prevScreen = screen:toWest()
    win:moveToScreen(prevScreen)
end

-- Move screen to the right
function windowmanager.moveToScreenRight()
    local win = hs.window.focusedWindow()
    local screen = win:screen()
    local prevScreen = screen:toEast()
    win:moveToScreen(prevScreen)
end

-- Debugging shortcut
hs.hotkey.bind(windowmanager.hyper, "1", function()
    hs.alert.show("Debugging shortcut for windowmanager.lua pressed")
end)

return windowmanager

