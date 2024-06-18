local awful = require('awful')
local sharedtags = require('sharedtags')
local gears = require('gears')
local icons = require('theme.icons')
local apps = require('configuration.apps')

awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.floating,
  awful.layout.suit.max
}

local tags = sharedtags({
  {
    icon = icons.console,
    type = 'console',
    defaultApp = apps.default.terminal,
    layout = awful.layout.suit.floating
  },
  {
    icon = icons.firefox,
    type = 'firefox',
    defaultApp = apps.default.browser,
    layout = awful.layout.suit.max
  },
  {
    icon = icons.code,
    type = 'code',
    defaultApp = apps.default.editor,
    layout = awful.layout.suit.floating
  },
  {
    icon = icons.mail,
    type = 'mail',
    defaultApp = apps.default.mail,
    layout = awful.layout.suit.max
  },
  {
    icon = icons.social,
    type = 'social',
    defaultApp = apps.default.social,
    layout = awful.layout.suit.max
  },
  {
    icon = icons.music,
    type = 'music',
    defaultApp = apps.default.music,
    layout = awful.layout.suit.tile
  },
  {
    icon = icons.lab,
    type = 'any',
    defaultApp = apps.default.rofi,
    layout = awful.layout.suit.floating
  }
})

awful.screen.connect_for_each_screen(
  function(s)
--[[
    for i, tag in pairs(tags) do
      awful.tag.add(
        i,
        {
          icon = tag.icon,
          icon_only = true,
          layout = tag.layout,
          gap_single_client = false,
          gap = 4,
          screen = s,
          defaultApp = tag.defaultApp,
          selected = i == 1
        }
      )
    end
--]]
  end
)

_G.tag.connect_signal(
  'property::layout',
  function(t)
    local currentLayout = awful.tag.getproperty(t, 'layout')
    if (currentLayout == awful.layout.suit.max) then
      t.gap = 0
    else
      t.gap = 4
    end
  end
)

return tags
