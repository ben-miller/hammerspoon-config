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
    hs.alert.show("Looking for " .. appName)
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

    -- Firefox
    firefox = Application("firefox", C.Firefox, ".", {
        Shortcut("New Tab", "Cmd-T", nil),
        Shortcut("New Window", "Cmd-N", nil),
        Shortcut("Close Tab", "Cmd-W", nil),
        Shortcut("Close Window", "Cmd-Shift-W", nil)
    }),

    -- iTerm
    iterm = Application("iterm", "iTerm", "T", {
        Shortcut("New Tab", "Cmd-T", nil),
        Shortcut("New Window", "Cmd-N", nil),
        Shortcut("Close Tab", "Cmd-W", nil),
        Shortcut("Close Window", "Cmd-Shift-W", nil)
    }),

    -- Stickies
    stickies = Application("stickies", "Stickies", "S", {
        Shortcut("New Note", "Cmd-N", nil),
        Shortcut("Close Note", "Cmd-W", nil)
    }),

    -- Obsidian
    obsidian = Application("obsidian", "Obsidian", "O", {
        Shortcut("New Note", "Cmd-N", nil),
        Shortcut("Close Note", "Cmd-W", nil)
    }),

    -- IntelliJ IDEA
    idea = Application("idea", "IntelliJ IDEA", "I", {
        Shortcut("New Project", "Cmd-Shift-N", nil),
        Shortcut("New File", "Cmd-N", nil),
        Shortcut("Close Project", "Cmd-W", nil),
        Shortcut("Close File", "Cmd-W", nil)
    }),

    -- GMail
    gmail = Application("gmail", "GMail", "G", {
        Shortcut("New Message", "Cmd-N", nil),
        Shortcut("Close Message", "Cmd-W", nil)
    }),

    -- GCal
    gcal = Application("gcal", "GCal", "C", {
        Shortcut("New Event", "Cmd-N", nil),
        Shortcut("Close Event", "Cmd-W", nil)
    }),

    -- LibraryThing
    librarything = Application("librarything", "LibraryThing", "L", {
        Shortcut("New Book", "Cmd-N", nil),
        Shortcut("Close Book", "Cmd-W", nil)
    }),

    -- Finder
    finder = Application("finder", "Finder", "F", {
        Shortcut("New Window", "Cmd-N", nil),
        Shortcut("Close Window", "Cmd-W", nil)
    }),

    -- Trello
    -- TODO Handle weirdness with this
    trello = Application("trello", "Agenda", "T", {
        Shortcut("New Card", "Cmd-N", nil),
        Shortcut("Close Card", "Cmd-W", nil)
    }),

    -- iTerm2
    iterm2 = Application("iterm2", "iTerm2", "M", {
        Shortcut("New Tab", "Cmd-T", nil),
        Shortcut("New Window", "Cmd-N", nil),
        Shortcut("Close Tab", "Cmd-W", nil),
        Shortcut("Close Window", "Cmd-Shift-W", nil)
    }),

    -- Timer
    timer = Application("timer", "Timer", ";", {
        Shortcut("New Timer", "Cmd-N", nil),
        Shortcut("Close Timer", "Cmd-W", nil)
    }),

    -- SourceTree
    sourcetree = Application("sourcetree", "SourceTree", "E", {
        Shortcut("New Tab", "Cmd-T", nil),
        Shortcut("New Window", "Cmd-N", nil),
        Shortcut("Close Tab", "Cmd-W", nil),
        Shortcut("Close Window", "Cmd-Shift-W", nil)
    })
}

return applications

