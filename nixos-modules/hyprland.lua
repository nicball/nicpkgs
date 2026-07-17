local function runner(cmd) return "uwsm-app -- " .. cmd end

hl.on("hyprland.start", function () 
  hl.exec_cmd(runner("kitty"), { workspace = "1 silent" })
  hl.exec_cmd(runner("@browser@"), { workspace = "2 silent" })
  @sourceXrdb@
end)

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,
    border_size = 2,
    col = {
      active_border = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },
    resize_on_border = true,
    allow_tearing = false,
    layout = "dwindle",
  },
  decoration = {
    rounding = 10,
    rounding_power = 2,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = 0xee1a1a1a,
    },
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.1696,
    },
  },
  animations = {
    enabled = true,
  },
  dwindle = {
    preserve_split = true,
  },
  master = {
    new_status = "master",
  },
  scrolling = {
    fullscreen_on_one_column = true,
  },
  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo = true,
    vrr = 1,
    disable_splash_rendering = true,
  },
})
hl.layer_rule({
  match = { namespace = "notifications|waybar|rofi" },
  blur = true,
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })
hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

hl.config({
  input = {
    kb_layout = "us",
    follow_mouse = 1,
    sensitivity = 0,
    accel_profile = "flat",
    touchpad = {
      natural_scroll = true,
    },
  },
})

hl.monitor({
  output = "desc:YCT Sculptor 0000",
  mode = "modeline 552.75 2560 2608 2640 2720 1600 1603 1609 1694 +hsync -vsync",
  position = "auto",
  scale = 1,
  vrr = 1,
})

hl.window_rule({ float = true, match = { class = "^lact$" } })
hl.window_rule({ float = true, match = { class = "^io\\.github\\.ilya_zlobintsev\\.LACT$" } })
hl.window_rule({ float = true, match = { class = "^org\\.pulseaudio\\.pavucontrol$" } })
hl.window_rule({ float = true, match = { class = "^xdg-desktop-portal-gtk$" } })
hl.window_rule({ float = true, match = { class = "^firefox$", title = "^Extension:.*$" } })

hl.window_rule({ workspace = "4 silent", match = { class = "^steam$" } })
hl.window_rule({ workspace = "4 silent", match = { class = "^steam_app_.*$" } })
hl.window_rule({ workspace = "4 silent", match = { class = "^org\\.prismlauncher\\.PrismLauncher$" } })
hl.window_rule({ workspace = "4 silent", match = { title = "^Minecraft.*$" } })
hl.window_rule({ workspace = "4 silent", match = { class = "^factorio$" } })
hl.window_rule({ workspace = "4 silent", match = { xdg_tag = "^proton-game$" } })

hl.window_rule({ workspace = "5 silent", match = { class = "^vlc$" } })
hl.window_rule({ workspace = "5 silent", match = { class = "^mpv$" } })

hl.window_rule({ workspace = "3 silent", match = { class = "^QQ$" } })
hl.window_rule({ workspace = "3 silent", match = { class = "^Element$" } })
hl.window_rule({ workspace = "3 silent", match = { class = "^org\\.telegram\\.desktop$" } })

hl.workspace_rule({ workspace = "1", default_name = "dev" })
hl.workspace_rule({ workspace = "2", default_name = "browser" })
hl.workspace_rule({ workspace = "3", default_name = "social" })
hl.workspace_rule({ workspace = "4", default_name = "game" })
hl.workspace_rule({ workspace = "5", default_name = "media" })

hl.bind("SUPER + P", hl.dsp.submap("passthru"))
hl.define_submap("passthru", function()
  hl.bind("SUPER + P", hl.dsp.submap("reset"))
end)

hl.bind("SUPER + Return", hl.dsp.exec_cmd(runner("kitty")))
hl.bind("SUPER + C", hl.dsp.exec_cmd(runner("@browser@")))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + Q", hl.dsp.window.kill())
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("uwsm stop"))
hl.bind("SUPER + SHIFT + Space", hl.dsp.window.float())
hl.bind("SUPER + ALT + Space", hl.dsp.window.pin())
hl.bind("SUPER + D", hl.dsp.exec_cmd("rofi -show combi -run-command 'uwsm-app -- {cmd}'"))
hl.bind("SUPER + V", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + G", hl.dsp.group.toggle())
hl.bind("SUPER + N", hl.dsp.group.next())
hl.bind("SUPER + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind("Print", hl.dsp.exec_cmd("@screenshot@"))

hl.bind("SUPER + H", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "d" }))
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "d" }))

hl.bind("SUPER + 1", hl.dsp.focus({ workspace = "1" }))
hl.bind("SUPER + 2", hl.dsp.focus({ workspace = "2" }))
hl.bind("SUPER + 3", hl.dsp.focus({ workspace = "3" }))
hl.bind("SUPER + 4", hl.dsp.focus({ workspace = "4" }))
hl.bind("SUPER + 5", hl.dsp.focus({ workspace = "5" }))
hl.bind("SUPER + 6", hl.dsp.focus({ workspace = "6" }))
hl.bind("SUPER + 7", hl.dsp.focus({ workspace = "7" }))
hl.bind("SUPER + 8", hl.dsp.focus({ workspace = "8" }))
hl.bind("SUPER + 9", hl.dsp.focus({ workspace = "9" }))
hl.bind("SUPER + 0", hl.dsp.focus({ workspace = "10" }))

hl.bind("SUPER + SHIFT + 1", hl.dsp.window.move({ workspace = "1", follow = false }))
hl.bind("SUPER + SHIFT + 2", hl.dsp.window.move({ workspace = "2", follow = false }))
hl.bind("SUPER + SHIFT + 3", hl.dsp.window.move({ workspace = "3", follow = false }))
hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = "4", follow = false }))
hl.bind("SUPER + SHIFT + 5", hl.dsp.window.move({ workspace = "5", follow = false }))
hl.bind("SUPER + SHIFT + 6", hl.dsp.window.move({ workspace = "6", follow = false }))
hl.bind("SUPER + SHIFT + 7", hl.dsp.window.move({ workspace = "7", follow = false }))
hl.bind("SUPER + SHIFT + 8", hl.dsp.window.move({ workspace = "8", follow = false }))
hl.bind("SUPER + SHIFT + 9", hl.dsp.window.move({ workspace = "9", follow = false }))
hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = "10", follow = false }))

hl.bind("SUPER + ESCAPE", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + ESCAPE", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:272", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("@wpctl@ set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("@wpctl@ set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("@wpctl@ set-mute @DEFAULT_AUDIO_SINK@ toggle"), { repeating = true, locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("@wpctl@ set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { repeating = true, locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("@playerctl@ -a previous"), { repeating = true, locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("@playerctl@ -a play-pause"), { repeating = true, locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("@playerctl@ -a next"), { repeating = true, locked = true })
