local awful = require('awful')
local gears = require('gears')
local client_keys = require('configuration.client.keys')
local client_buttons = require('configuration.client.buttons')

local dpi = require('beautiful').xresources.apply_dpi

-- Rules
awful.rules.rules = {
  -- All clients will match this rule.
  {
    rule = {},
    properties = {
      focus = awful.client.focus.filter,
      raise = true,
      keys = client_keys,
      buttons = client_buttons,
      screen = awful.screen.preferred,
      placement = awful.placement.centered,
      floating = false,
      maximized = false,
      above = false,
      below = false,
      ontop = false,
      sticky = false,
      maximized_horizontal = false,
      maximized_vertical = false
    }
  },
  {
    rule = { name = 'QuakeTerminal' },
    properties = { skip_decoration = true }
  },
  {
    rule = { class = 'conky' },
    properties = {
      floating = true,
      skip_decoration = true
    }
  },
  -- fix large open dialogs of firefox and thunderbird under distrobox
  {
    rule = { class = 'firefox', name = 'Open File' },
    properties = {
      ontop = true,
      floating = true,
      skip_decoration = true,
      x = dpi(300),
      y = dpi(100),
      width = dpi(900),
      height = dpi(675)
    }
  },
  {
    rule = { class = 'thunderbird', name = 'Open Message' },
    properties = {
      ontop = true,
      floating = true,
      skip_decoration = true,
      x = dpi(300),
      y = dpi(100),
      width = dpi(900),
      height = dpi(690)
    }
  },
  {
    rule = { class = 'thunderbird', name = 'Open' },
    properties = {
      ontop = true,
      floating = true,
      skip_decoration = true,
      x = dpi(300),
      y = dpi(100),
      width = dpi(900),
      height = dpi(690)
    }
  },
  -- Titlebars
  {
    rule_any = { type = { 'dialog' }, class = { 'Wicd-client.py', 'calendar.google.com' } },
    properties = {
      placement = awful.placement.centered,
      ontop = true,
      floating = true,
      drawBackdrop = true,
      shape = function()
        return function(cr, w, h)
          gears.shape.rounded_rect(cr, w, h, 8)
        end
      end,
      skip_decoration = true
    }
  },
  {
    rule = { class = 'Gsimplecal' },
    properties = {
      placement = awful.placement.top_right,
      ontop = true,
      floating = true,
      drawBackdrop = true,
      shape = function()
        return function(cr, w, h)
          gears.shape.rounded_rect(cr, w, h, 8)
        end
      end,
      skip_decoration = true
    }
  }
}
