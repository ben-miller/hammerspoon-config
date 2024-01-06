local C = require("constants")

local applications = {}

-- Shortcut struct. Defines a shortcut for an application.
-- These shortcuts are not (necessarily) hammerspoon shortcuts.
-- They are just a convenient way of documenting shortcuts for
-- a given app.
--
-- 1. Name (string)
-- 2. Hotkey (string)
-- 3. Action (function)
function Shortcut(name, hotkey, action)
  local self = {}
  self.name = name
  self.hotkey = hotkey
  self.action = action
  return self
end

-- Define Application struct, having
-- 1. Name (string)
-- 2. Hotkey (string)
-- 3. Shortcuts (table of Shortcut structs)
function Application(shortName, appName, hotkey, shortcuts)
  local self = {}
  self.shortName = shortName
  self.appName = appName
  self.hotkey = hotkey
  self.shortcuts = shortcuts
  return self
end

-- We define the specific applications and their metadata here.
-- The metadata is used to generate the hammerspoon per-app shortcuts
-- documentation. This may be distilled into a config file in the future.
applications.all = {

    -- Firefox
    firefox = Application("firefox", C.Firefox, "f", {
        Shortcut("New Tab", "Cmd-T", nil),
        Shortcut("New Window", "Cmd-N", nil),
        Shortcut("Close Tab", "Cmd-W", nil),
        Shortcut("Close Window", "Cmd-Shift-W", nil)
    }),

    -- iTerm
    iterm = Application("iterm", "iTerm", "t", {
        Shortcut("New Tab", "Cmd-T", nil),
        Shortcut("New Window", "Cmd-N", nil),
        Shortcut("Close Tab", "Cmd-W", nil),
        Shortcut("Close Window", "Cmd-Shift-W", nil)
    })

}

return applications

