local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local TaskList = require('widget.task-list')
local gears = require('gears')
local clickable_container = require('widget.material.clickable-container')
local mat_icon_button = require('widget.material.icon-button')
local mat_icon = require('widget.material.icon')

local dpi = require('beautiful').xresources.apply_dpi

local icons = require('theme.icons')

-- Clock / Calendar 24h format
local textclock = wibox.widget.textclock('<span font="Fira Code bold 9.5">%d.%m.%Y\n     %H:%M</span>')

-- Clock / Calendar 12AM/PM fornat
-- local textclock = wibox.widget.textclock('<span font="Fira Code bold 9.5">%d.%m.%Y\n  %I:%M %p</span>\n<span font="Fira Code bold 9.5">%p</span>')
-- textclock.forced_height = 56

-- Add a calendar (credits to kylekewley for the original code)
local month_calendar = awful.widget.calendar_popup.month({
  screen = s,
  start_sunday = false,
  week_numbers = true
})
month_calendar:attach(textclock)

--local clock_widget = wibox.container.margin(textclock, dpi(13), dpi(13), dpi(8), dpi(8))

local add_button = mat_icon_button(mat_icon(icons.plus, dpi(24)))
add_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        awful.spawn(
          awful.screen.focused().selected_tag.defaultApp,
          {
            tag = _G.mouse.screen.selected_tag,
            placement = awful.placement.centered
          }
        )
      end
    )
  )
)

-- Create an imagebox widget which will contains an icon indicating which layout we're using.
-- We need one layoutbox per screen.
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

local TasklistPanel = function(s, offset)
  local offsetx = 0
  if offset == true then
    offsetx = dpi(512)
    offsety = dpi(4)
  end
  local panel =
    wibox(
    {
      ontop = false,
      screen = s,
      height = dpi(24),
      width = s.geometry.width - 2 * offsetx,
      x = s.geometry.x + offsetx,
      y = s.geometry.y  + offsety,
      stretch = false,
      bg = beautiful.primary.hue_900,
      fg = beautiful.fg_normal,
      opacity = 0.75,
      struts = {
        top = dpi(24)
      }
    }
  )

  panel:struts(
    {
      top = dpi(32)
    }
  )

  panel:setup {
    layout = wibox.layout.align.horizontal,
    {
      layout = wibox.layout.fixed.horizontal,
      TaskList(s),
      --add_button
    },
    nil,
    nil
  }

  return panel
end

return TasklistPanel
