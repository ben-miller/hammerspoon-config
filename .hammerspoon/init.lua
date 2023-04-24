-- TODO Shortcut for own HS config documentation
-- TODO Shortcut for editing HS config
-- TODO Shortcut for HS console
-- TODO Shortcut for reloading HS

local home = os.getenv("HOME")
local log = hs.logger.new("main", "verbose") -- Use 'log.e(xxx)'
local dumper = require('dumper')
local _ = require('underscore')

-- Reload config whenever any *.lua file in ~/.hammerspoon changes
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
watcher = hs.pathwatcher.new(home .. "/.hammerspoon/", reloadConfig):start()

local hyper = { "cmd", "ctrl", "alt" }
local hypo = { "ctrl", "alt", "shift" }

-- Open shortcut documentation

function moveLeftHalf()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  if (f.x == 0 and f.w == max.w / 2) then
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

function moveRightHalf()
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

function moveMiddleTwoThirds()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + max.w / 6
  f.w = 2 * (max.w / 3)

  win:setFrame(f)
end

function maximize()
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

-- Maximize current window
hs.hotkey.bind(hyper, "up", function()
    maximize()
end)

-- Move current window to middle 2/3
hs.hotkey.bind(hyper, "down", function()
    moveMiddleTwoThirds()
end)

-- Move current window to left half of screen
hs.hotkey.bind(hyper, "left", function()
    moveLeftHalf()
end)

-- Move current window to right half of screen
hs.hotkey.bind(hyper, "right", function()
    moveRightHalf()
end)

-- Focus on window to left
hs.hotkey.bind(hyper, "H", function()
    local win = hs.window.focusedWindow()
    local res = win.focusWindowWest()
end)

-- Focus on window to right
hs.hotkey.bind(hyper, "L", function()
    local win = hs.window.focusedWindow()
    local res = win.focusWindowEast()
end)

-- Focus on window below
hs.hotkey.bind(hyper, "J", function()
    local win = hs.window.focusedWindow()
    local res = win.focusWindowSouth()
end)

-- Focus on window above
hs.hotkey.bind(hyper, "K", function()
    local win = hs.window.focusedWindow()
    local res = win.focusWindowNorth()
end)

-- Toggle WIFI power
hs.hotkey.bind(hyper, "W", function()
    local wifiPower = hs.wifi.interfaceDetails().power
    if (wifiPower) then
        hs.wifi.setPower(false)
    else
        hs.wifi.setPower(true)
    end
end)

-- Open New Tab
hs.hotkey.bind(hyper, "T", function()
    hs.urlevent.openURL("http://localhost:8282/index.html")
end)

-- Open Stickies
hs.hotkey.bind(hyper, "S", function()
    hs.application.launchOrFocus("Stickies")
end)

-- Open Browser
hs.hotkey.bind(hyper, "B", function()
    hs.application.launchOrFocus("Firefox")
end)

-- Open Intellij
hs.hotkey.bind(hyper, "I", function()
    hs.application.launchOrFocus("IntelliJ IDEA")
end)

-- URL encoding
-- https://gist.github.com/liukun/f9ce7d6d14fa45fe9b924a3eed5c3d99

local char_to_hex = function(c)
  return string.format("%%%02X", string.byte(c))
end

local function urlencode(url)
  if url == nil then
    return
  end
  url = url:gsub("\n", "\r\n")
  url = url:gsub("([^%w ])", char_to_hex)
  url = url:gsub(" ", "+")
  return url
end

local function focusOtherBrowserWindow()
  hs.application.launchOrFocus("Brave Browser")
  local focused = hs.window.focusedWindow()
  local app = hs.application.find("Brave Browser")
  local windows = app:allWindows()
  if #windows > 1 then
    _.each(windows, function(window)
      if window ~= focused then
        window:focus()
      end
    end)
  end
end

local function formattedSearchTermFromClipboard()
  local term = hs.pasteboard.readString()
  term = string.sub(term, 0, 100)
  term = urlencode(term)
  return term
end

-- Search text in Jisho.org
hs.hotkey.bind(hypo, "J", function()
--hs.alert.show(hs.pasteboard.readString())
  local term = formattedSearchTermFromClipboard()
  local url = string.format("https://jisho.org/search/%s", term)
  focusOtherBrowserWindow()
  hs.urlevent.openURL(url)
end)

-- Search kanji in Jisho.org
hs.hotkey.bind(hypo, "K", function()
  local term = formattedSearchTermFromClipboard()
  local url = "https://jisho.org/search/%23kanji%20" .. term
  focusOtherBrowserWindow()
  hs.urlevent.openURL(url)
end)

-- Translate term in gTranslate
hs.hotkey.bind(hypo, "T", function()
  local term = formattedSearchTermFromClipboard()
  local url = string.format("https://translate.google.com/?sl=ja&tl=en&text=%s&op=translate", term)
  focusOtherBrowserWindow()
  hs.urlevent.openURL(url)
end)

-- Kill Apple Music as soon as it opens
function applicationMusicWatcher(appName, eventType, appObject)
    if (eventType == hs.application.watcher.launching) then
        if (appName == "Music") then
            local op, stat, typ, ec = hs.execute([["/usr/bin/killall" "Music"]])
            hs.alert.show("Killed Apple Music")
            if not (ec == 0) then
                msg = "An error occurred terminating Music."
                hs.notify.new({title="Hammerspoon", informativeText=msg}):send()
            end                     
        end
    end
end
appMusicWatcher = hs.application.watcher.new(applicationMusicWatcher)
appMusicWatcher:start()

-- Announce that config has changed
hs.alert.show("Config loaded")
