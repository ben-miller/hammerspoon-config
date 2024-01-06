local shortcuts = {}

local applications = require("./applications")
local home = os.getenv("HOME")
local htmlTemplateFile = home .. "/src/infra/config/hammerspoon/.hammerspoon/template.html"

-- Search and replace patterns in html template string
function simpleTemplate(str, data)
    return (str:gsub('($%b{})', function(w)
        return data[w:sub(3, -2)] or w
    end))
end

function readHtmlFile(filePath)
    local file = io.open(filePath, "r")  -- Open the file for reading
    if not file then return nil, "Could not open file: " .. filePath end
    local content = file:read("*a")  -- Read the entire content
    file:close()
    return content
end

function genHtmlForApp(app)

    -- Open html file for app
    local template = readHtmlFile(htmlTemplateFile)

    -- Values to replace in template
    local data = {
        ["shortName"] = app.shortName,
        ["appName"] = app.appName
    }

    -- Replace values
    local html = simpleTemplate(template, data)

    -- Write to file
    local filename = shortcuts.htmlFileForApp(app.shortName)
    local file = io.open(filename, "w")
    if not file then
        hs.alert.show("Could not open file " .. filename)
        return
    end
    file:write(html)
    file:close()
end

-- Take an application and output a dummy html file into ./shortcuts
-- This file will be named based on the application name.
function shortcuts.generateHtml()

    -- iterate over all applications
    for _, app in pairs(applications.all) do
        genHtmlForApp(app)
    end
end

function shortcuts.htmlFileForApp(shortName)
    return home .. "/src/infra/config/hammerspoon/.hammerspoon/shortcuts/" .. shortName .. ".html"
end

function shortcuts.showShortcuts()
    -- For each visible window, show a shortcuts modal
    for i,win in ipairs(listVisibleWindows()) do

        -- Get screen of window
        local screen = win:screen()

        -- Show shortcuts modal for screen
        showShortcutsForScreen(screen, win)
    end
end

function shortcuts.getShortcutsModalForScreen(screen, window)
    local screenFrame = screen:frame()

    local webViewFrame = {
        x = screenFrame.x + 100,
        y = screenFrame.y + 100,
        w = screenFrame.w - 200,
        h = screenFrame.h - 200
    }

    local app = window:application()

    -- get app name
    local appName = app:name()

    -- TODO: Differentiate between own and hs concept of application
    local myApp = applications.getApplicationByAppName(appName)

    if not myApp then
        return nil
    end

    local htmlFileForApp = shortcuts.htmlFileForApp(myApp.shortName)

    local shortcutModal = hs.webview.new(webViewFrame)

    -- Set to floating
    shortcutModal:level(hs.drawing.windowLevels.floating)

    -- Make it semi-transparent
    shortcutModal:alpha(0.9)

    -- Center it on the "Built-in Retina Display"
    local mainScreen = hs.screen.mainScreen()
    local mainRes = mainScreen:fullFrame()
    local modalFrame = shortcutModal:frame()
    modalFrame.x = (mainRes.w - modalFrame.w) / 2

    shortcutModal:url("file://" .. htmlFileForApp) -- Update with the correct path
    shortcutModal:windowStyle("utility")
    shortcutModal:windowTitle("Shortcuts")
    shortcutModal:closeOnEscape(true)

    return shortcutModal
end

return shortcuts

