local shortcuts = {}

local applications = require("./applications")
local home = os.getenv("HOME")

-- Take an application and output a dummy html file into ./shortcuts
-- This file will be named based on the application name.
function shortcuts.generateHtml()
    hs.alert.show("Applications: " .. #applications.all)

    -- iterate over all applications
    for _, app in pairs(applications.all) do
        hs.alert.show("Generating shortcut doc for " .. app.appName)
        local name = app.shortName
        local html = [[
          <!DOCTYPE html>
          <html>
            <head>
              <meta charset="utf-8">
              <title>]] .. name .. [[</title>
              <link rel="stylesheet" href="style.css">
            </head>
            <body>
              <div class="container">
                <div class="icon">
                </div>
                <div class="name">]] .. name .. [[</div>
              </div>
            </body>
          </html>
        ]]
    
        local filename = home .. "/src/infra/config/hammerspoon/.hammerspoon/shortcuts/" .. name .. ".html"
        local file = io.open(filename, "w")
        if not file then
            hs.alert.show("Could not open file " .. filename)
            return
        end
        file:write(html)
        file:close()
    end
end

return shortcuts

