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

return shortcuts

