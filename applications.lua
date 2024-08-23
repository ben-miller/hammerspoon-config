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

function applications.getApplication(shortName)
  return applications.all[shortName]
end

-- Get app by app name
function applications.getApplicationByAppName(appName)
  for _, app in pairs(applications.all) do
    if app.appName == appName then
      return app
    end
  end
  return nil
end

-- We define the specific applications and their metadata here.
-- The metadata is used to generate the hammerspoon per-app shortcuts
-- documentation. This may be distilled into a config file in the future.
applications.all = {

    -- Emacs
    emacs = Application("emacs", "Emacs", "J", {}),

    -- ChatGPT
    chatgpt = Application("chatgpt", "ChatGPT", "U", {}),

    -- Firefox
    firefox = Application("firefox", C.Firefox, "K", {}),

    -- Stickies
    stickies = Application("stickies", "Stickies", "S", {}),

    -- Obsidian
    obsidian = Application("obsidian", "Obsidian", "O", {}),

    -- IntelliJ IDEA
    idea = Application("idea", "IntelliJ IDEA", "I", {}),

    -- PyCharm
    pycharm = Application("pycharm", "PyCharm", "P", {}),

    -- WebStorm
    pycharm = Application("webstorm", "WebStorm", "B", {}),

    -- GMail
    gmail = Application("gmail", "GMail", "G", {}),

    -- GCal
    gcal = Application("gcal", "GCal", "C", {}),

    -- Finder
    finder = Application("finder", "Finder", "F", {}),

    -- Trello
    trello = Application("trello", "Agenda", "T", {}),

    -- Tech Learning
    techlearning = Application("techlearning", "Tech Learning", "H", { }),

    -- Terminal
    term = Application(C.Terminal, C.Terminal, "M", {}),

    -- Timer
    timer = Application("timer", "Timer", ";", {}),

    -- SourceTree
    sourcetree = Application("sourcetree", "Sourcetree", "E", {}),

    -- Tidal
    tidal = Application("tidal", "TIDAL", "Z", {}),
}

return applications

