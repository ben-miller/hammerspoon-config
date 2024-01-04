local windowmanager = {}

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

function windowmanager.maximize()
    local win = hs.window.focusedWindow()
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

return windowmanager

