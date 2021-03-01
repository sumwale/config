local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local gears = require('gears')
local clickable_container = require('widget.material.clickable-container')
local mat_icon_button = require('widget.material.icon-button')
local mat_icon = require('widget.material.icon')

local dpi = require('beautiful').xresources.apply_dpi

local icons = require('theme.icons')

local LayoutBox = function(s)
  local layoutBox = clickable_container(awful.widget.layoutbox(s))
  layoutBox:buttons(
    awful.util.table.join(
      awful.button(
        {},
        1,
        function()
          awful.layout.inc(1)
        end
      ),
      awful.button(
        {},
        3,
        function()
          awful.layout.inc(-1)
        end
      ),
      awful.button(
        {},
        4,
        function()
          awful.layout.inc(1)
        end
      ),
      awful.button(
        {},
        5,
        function()
          awful.layout.inc(-1)
        end
      )
    )
  )
  return layoutBox
end

local ModePanel = function(s, offset)
  if offset == true then
    offsety = dpi(4)
  end
  local panel =
    wibox(
    {
      ontop = false,
      screen = s,
      height = dpi(24),
      width = dpi(24),
      x = s.geometry.width - dpi(36),
      y = s.geometry.y  + offsety,
      stretch = false,
      bg = beautiful.primary.hue_900,
      fg = beautiful.fg_normal,
      struts = {
        top = dpi(24)
      }
    }
  )

  panel:struts(
    {
      top = dpi(0)
    }
  )

  panel:setup {
    layout = wibox.layout.align.horizontal,
    {
      layout = wibox.layout.fixed.horizontal,
      LayoutBox(s)
    },
    nil,
    nil
  }

  return panel
end

return ModePanel
