local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')

local dpi = require('beautiful').xresources.apply_dpi

local textclock = wibox.widget.textclock('<span font="Fira Code 6">%b  %d</span>')

-- uncomment below and comment out panel/backdrop connect_signal calls if no gsimplecal

--[[
local month_calendar = awful.widget.calendar_popup.month({
  screen = s,
  start_sunday = false,
  week_numbers = true
})
month_calendar:attach(textclock)
--]]

-- Popup showing full date with weekday
local textclock_popup =
  awful.tooltip(
  {
    objects = {textclock},
    timer_function = function()
      return os.date('%a, %b %d, %Y')
    end,
    timeout = 60,
    font = 'Fira Code 9',
    margin_leftright = dpi(6),
    margin_topbottom = dpi(6),
    mode = 'mouse',
    align = 'right'
  }
)


local date_widget = wibox.container.margin(textclock, dpi(4), dpi(4), dpi(4), dpi(4))

local DatePanel = function(s, offset)
  local panel =
    wibox(
    {
      ontop = false,
      screen = s,
      height = dpi(30),
      width = dpi(24),
      x = s.geometry.x + dpi(4),
      y = s.geometry.y + s.geometry.height - dpi(100),
      stretch = false,
      bg = beautiful.primary.hue_900,
      fg = beautiful.fg_normal,
      opacity = 0.75,
      struts = {
        left = dpi(24)
      }
    }
  )

  panel:struts(
    {
      left = dpi(0)
    }
  )

  panel:setup {
      layout = wibox.layout.fixed.vertical,
      date_widget,
  }

  -- used to open/close the calendar widget when clicked anywhere on date
  -- (close_on_unfocus in gsimplecal config closes if any other window clicked;
  --  ontop is false here else the clicks on gsimplecal are also captured by backdrop)
  local backdrop =
    wibox {
    ontop = false,
    visible = false,
    screen = s,
    bg = '#00000000',
    type = 'dock',
    x = s.geometry.x,
    y = s.geometry.y,
    width = s.geometry.width,
    height = s.geometry.height,
  }

  function panel:toggle(force_close)
    awful.spawn.easy_async('pidof gsimplecal', function(out)
      if out and string.len(out) > 0 then
        awful.spawn.easy_async('gsimplecal', function() end)
        backdrop.visible = false
        panel.ontop = false
      elseif force_close then
        backdrop.visible = false
        panel.ontop = false
      else
        awful.spawn.easy_async('gsimplecal', function() end)
        backdrop.visible = true
        panel.ontop = true
      end
    end)
  end

  backdrop:connect_signal('button::release', function() panel:toggle(true) end)
  panel:connect_signal('button::release', function() panel:toggle(false) end)

  return panel
end

return DatePanel
