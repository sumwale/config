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
    name = 'console',
    icon = icons.console,
    defaultApp = apps.default.terminal,
    gap_single_client = false,
    gap = 4,
    layout = awful.layout.suit.floating
  },
  {
    name = 'firefox',
    icon = icons.firefox,
    defaultApp = apps.default.browser,
    gap_single_client = false,
    gap = 0,
    layout = awful.layout.suit.max
  },
  {
    name = 'code',
    icon = icons.code,
    defaultApp = apps.default.editor,
    gap_single_client = false,
    gap = 4,
    layout = awful.layout.suit.floating
  },
  {
    name = 'mail',
    icon = icons.mail,
    defaultApp = apps.default.mail,
    gap_single_client = false,
    gap = 0,
    layout = awful.layout.suit.max
  },
  {
    name = 'social',
    icon = icons.social,
    defaultApp = apps.default.social,
    gap_single_client = false,
    gap = 0,
    layout = awful.layout.suit.max
  },
  {
    name = 'music',
    icon = icons.music,
    defaultApp = apps.default.music,
    gap_single_client = false,
    gap = 4,
    layout = awful.layout.suit.tile
  },
  {
    name = 'any',
    icon = icons.lab,
    defaultApp = apps.default.rofi,
    gap_single_client = false,
    gap = 4,
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

--[[
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
--]]

return tags
