local H = os.getenv("HOME") or ""
local U = os.getenv("USER") or ""
local M = "SUPER"

local function raw(cmd) return hl.dsp.exec_raw(cmd) end
local function sh(cmd) return hl.dsp.exec_cmd(cmd) end
local function mbind(keys, action, flags) hl.bind(M .. " + " .. keys, action, flags) end
local function mraw(keys, cmd, flags) mbind(keys, raw(cmd), flags) end
local function msh(keys, cmd, flags) mbind(keys, sh(cmd), flags) end
local function shell_quote(s) return "'" .. s:gsub("'", "'\"'\"'") .. "'" end

local locked = { locked = true }
local repeat_locked = { locked = true, repeating = true }
local mouse = { mouse = true }
local scripts = H .. "/.config/hypr/scripts/"
local gpu_primary = os.getenv("GPU_PRIMARY") or "nvidia"

-- Environment
for k, v in pairs({
    XCURSOR_SIZE = "24",
    SDL_VIDEODRIVER = "wayland",
    CLUTTER_BACKEND = "wayland",
    XDG_CURRENT_DESKTOP = "Hyprland",
    XDG_SESSION_TYPE = "wayland",
    XDG_SESSION_DESKTOP = "Hyprland",
    QT_QPA_PLATFORM = "wayland",
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1",
    QT_QPA_PLATFORMTHEME = "gtk3",
    QT_STYLE_OVERRIDE = "Breeze",
    KDE_SESSION_VERSION = "6",
    GDK_BACKEND = "wayland",
    GTK_THEME = "Breeze-Dark",
}) do hl.env(k, v) end

local gpu_env = gpu_primary == "intel" and {
    GPU_PRIMARY = "intel",
    AQ_DRM_DEVICES = H .. "/.config/hypr/drm-intel:" .. H .. "/.config/hypr/drm-nvidia",
    DRI_PRIME = "0",
    __NV_PRIME_RENDER_OFFLOAD = "0",
    __GLX_VENDOR_LIBRARY_NAME = "mesa",
    __VK_LAYER_NV_optimus = "non_NVIDIA_only",
    LIBVA_DRIVER_NAME = "iHD",
    VK_ICD_FILENAMES = "/usr/share/vulkan/icd.d/intel_icd.json",
} or {
    GPU_PRIMARY = "nvidia",
    AQ_DRM_DEVICES = H .. "/.config/hypr/drm-nvidia",
    DRI_PRIME = "1",
    __NV_PRIME_RENDER_OFFLOAD = "1",
    __GLX_VENDOR_LIBRARY_NAME = "nvidia",
    __VK_LAYER_NV_optimus = "NVIDIA_only",
    __EGL_VENDOR_LIBRARY_FILENAMES = "/usr/share/glvnd/egl_vendor.d/10_nvidia.json",
    VK_ICD_FILENAMES = "/usr/share/vulkan/icd.d/nvidia_icd.json",
    VK_DRIVER_FILES = "/usr/share/vulkan/icd.d/nvidia_icd.json",
}
local gpu_env_assignments = {}
for k, v in pairs(gpu_env) do
    hl.env(k, v)
    table.insert(gpu_env_assignments, shell_quote(k .. "=" .. v))
end
local gpu_env_args = table.concat(gpu_env_assignments, " ")

hl.on("hyprland.start", function()
    hl.exec_cmd(scripts .. "brightness start")
    hl.exec_cmd(scripts .. "contrast start")
    hl.exec_cmd("hypridle")

    hl.exec_cmd([=[
        rm -f /tmp/wobpipe
        mkfifo -m 600 /tmp/wobpipe
        exec sh -c 'exec 3<>/tmp/wobpipe; exec wob <&3'
    ]=])

    hl.exec_cmd([=[
        printf '%s\n' toor | sudo -S sh -c \
            'ip link set wlp4s0 down; macchanger wlp4s0 -r; ip link set wlp4s0 up'
    ]=])

    hl.exec_cmd([=[
        systemctl --user unset-environment GPU_PRIMARY AQ_DRM_DEVICES DRI_PRIME \
            __NV_PRIME_RENDER_OFFLOAD __GLX_VENDOR_LIBRARY_NAME __VK_LAYER_NV_optimus \
            __EGL_VENDOR_LIBRARY_FILENAMES LIBVA_DRIVER_NAME VK_ICD_FILENAMES \
            VK_DRIVER_FILES GBM_BACKEND
    ]=] .. "systemctl --user set-environment " .. gpu_env_args .. [=[
        systemctl --user import-environment WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE \
            XDG_CURRENT_DESKTOP XDG_SESSION_TYPE
        dbus-update-activation-environment --systemd WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE \
            XDG_CURRENT_DESKTOP=Hyprland XDG_SESSION_TYPE=wayland ]=] .. gpu_env_args)

    hl.timer(function()
        hl.exec_cmd(scripts .. "brightness restore; " .. scripts .. "contrast restore")
    end, { timeout = 500, type = "oneshot" })
end)

-- Monitors
local function apply_monitor_profile()
    if gpu_primary == "intel" then
        hl.monitor({ output = "eDP-1", mode = "1920x1080@60.20", position = "0x0", scale = 1 })
        hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "0x0", scale = 1, mirror = "eDP-1" })
    else
        hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "0x0", scale = 2 })
        hl.monitor({ output = "eDP-1", disabled = true })
    end
    hl.monitor({ output = "", disabled = true })
end

apply_monitor_profile()

-- Only non-default/effective settings are kept.
hl.config({
    general = { border_size = 0, gaps_in = 0, gaps_out = 0, allow_tearing = true },
    decoration = { blur = { enabled = false }, shadow = { enabled = false } },
    animations = { enabled = false },

    input = {
        repeat_rate = 40,
        repeat_delay = 190,
        scroll_method = "2fg",
        special_fallthrough = true,
        emulate_discrete_scroll = 2,
        scroll_factor = 4.5,
        touchpad = { disable_while_typing = false, natural_scroll = true, drag_lock = 1 },
    },

    gestures = { workspace_swipe_forever = true, workspace_swipe_direction_lock = false },
    group = { groupbar = { enabled = false } },

    misc = {
        force_default_wallpaper = 0,
        vrr = 1,
        animate_mouse_windowdragging = true,
        enable_swallow = true,
    },

    binds = { scroll_event_delay = 200, workspace_back_and_forth = true },
    xwayland = { force_zero_scaling = true, create_abstract_socket = true },
    opengl = { nvidia_anti_flicker = false },
    render = { direct_scanout = 2 },

    cursor = {
        no_hardware_cursors = 0,
        no_break_fs_vrr = 1,
        inactive_timeout = 5,
        hide_on_key_press = true,
        zoom_rigid = true,
    },

    ecosystem = { no_update_news = true, no_donation_nag = true, enforce_permissions = true },
})

-- Gestures
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "vertical", action = "resize" })

hl.gesture({
    fingers = 3,
    direction = "pinchin",
    action = function()
        local z = hl.get_config("cursor.zoom_factor")
        hl.config({ cursor = { zoom_factor = z + 1 } })
    end,
})

hl.gesture({
    fingers = 3,
    direction = "pinchout",
    action = function() hl.config({ cursor = { zoom_factor = 1 } }) end,
})

hl.gesture({ fingers = 4, direction = "up", action = "fullscreen" })
hl.gesture({ fingers = 4, direction = "down", action = "float" })
hl.gesture({ fingers = 4, direction = "horizontal", action = "move" })
hl.gesture({ fingers = 4, direction = "pinch", action = "special", workspace_name = "G4" })

-- Lid / workspaces
hl.bind("switch:on:Lid Switch", raw("systemctl suspend-then-hibernate"), locked)
mbind("S", hl.dsp.workspace.toggle_special("S"))
mbind("SHIFT + S", hl.dsp.window.move({ workspace = "special:S", follow = true }))

for i = 1, 10 do
    local key, ws = i == 10 and "0" or tostring(i), tostring(i)
    mbind(key, hl.dsp.focus({ workspace = ws }))
    mbind("SHIFT + " .. key, hl.dsp.window.move({ workspace = ws, follow = true }))
    mbind("CTRL + " .. key, hl.dsp.window.move({ workspace = ws, follow = false }))
end

-- Window management
mbind("mouse:272", hl.dsp.window.drag(), mouse)
mbind("SHIFT + mouse:272", hl.dsp.window.resize(), mouse)
mbind("mouse:273", hl.dsp.window.resize(), mouse)

mbind("C", hl.dsp.window.close())
mbind("F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
mbind("Space", hl.dsp.window.float({ action = "toggle" }))
mbind("G", hl.dsp.group.toggle())
mbind("TAB", hl.dsp.group.next())
mbind("SHIFT + TAB", hl.dsp.group.prev())

for key, dir in pairs({ left = "l", right = "r", up = "u", down = "d" }) do
    mbind(key, hl.dsp.focus({ direction = dir }))
    mbind("SHIFT + " .. key, hl.dsp.window.move({ direction = dir, group_aware = true }))
end

-- Commands
msh("X", "cd ~/projects/ai/stt && uv run start.py")
msh("Z", "cd ~/projects/ai/stt && uv run stop.py")
mraw("L", "hyprlock")
msh("SHIFT + M", "hyprlock --immediate --quiet & systemctl hibernate", locked)
msh("CTRL + M", "sudo -n efibootmgr -n 0002 && systemctl hibernate", locked)
mbind("ALT + E", hl.dsp.exit(), locked)

mbind("P", apply_monitor_profile, locked)

mraw("Q", H .. "/.local/bin/gpu-env ghostty")
local type_clipboard = [=[
export YDOTOOL_SOCKET="${YDOTOOL_SOCKET:-$XDG_RUNTIME_DIR/.ydotool_socket}"
if ! command -v wl-paste >/dev/null 2>&1; then
    notify-send "Clipboard typer" "wl-paste is not installed"
elif ! command -v ydotool >/dev/null 2>&1; then
    notify-send "Clipboard typer" "Install ydotool to use Mod+T"
else
    clipboard="$(wl-paste --no-newline 2>/dev/null || true)"
    if [ -z "$clipboard" ]; then
        notify-send "Clipboard typer" "Clipboard is empty"
    else
        printf '%s\n' "$clipboard" | ydotool type -d 0 -f -
    fi
fi
]=]

mbind("T", function()
    hl.timer(function() hl.exec_cmd(type_clipboard) end, { timeout = 750, type = "oneshot" })
end)
mraw("B", H .. "/.local/bin/gpu-brave")
mraw("E", "pcmanfm")
mraw("N", "subl")
local launcher_shell = [=[
set -euo pipefail

entries() {
    local dir
    local -a dirs
    IFS=: read -r -a dirs <<<"$PATH"
    for dir in "${dirs[@]}"; do
        [[ -d $dir ]] || continue
        find -L "$dir" -mindepth 1 -maxdepth 1 -type f -executable -printf '%f\n' 2>/dev/null || true
    done
    { compgen -a; compgen -A function; } | sed 's/^/!/'
}

launcher() {
    if command -v rofi >/dev/null 2>&1; then rofi -dmenu -i -p run
    elif command -v dmenu >/dev/null 2>&1; then dmenu -p run
    elif command -v bemenu >/dev/null 2>&1; then bemenu -p run
    else printf 'no dmenu-compatible launcher found\n' >&2; return 1
    fi
}

choice="$(entries | sort -u | launcher)"
[[ -n ${choice:-} ]] || exit 0

if [[ $choice == '!'* ]]; then
    eval "${choice#!}"
elif [[ $choice != *[[:space:]]* ]] && type -P -- "$choice" >/dev/null 2>&1; then
    exec "$choice"
else
    eval "$choice"
fi
]=]

msh("M", "exec bash -ic " .. shell_quote(launcher_shell))

-- Screenshots
local shot_prefix = [[NAME=$(date +$HOME/Pictures/Screenshots/%Y-%m-%d_%H:%M:%S.%2N.png); ]]
local function shot(keys, capture)
    hl.bind(keys, sh(shot_prefix .. capture .. [[; wl-copy < "$NAME"]]))
end

shot("Print", [[slurp | grim -t png -g - "$NAME"]])
shot(M .. " + Print", [[echo 0, 0 1920x1080 | grim -t png -g - "$NAME"]])
shot("SHIFT + Print", [[
hyprctl activewindow |
awk '/at:/ {sum = $2_}/size:/ {print sum, $2}' |
rev | sed -e 's/, /x/' | rev |
grim -l 9 -t png -g - "$NAME"
]])

-- Brightness / contrast
local function repeat_cmd(keys, cmd) hl.bind(keys, raw(cmd), repeat_locked) end
local brightness = scripts .. "brightness "
local contrast = scripts .. "contrast "

repeat_cmd("CTRL + Insert", brightness .. "-")
repeat_cmd("Insert", brightness .. "+")
repeat_cmd("CTRL + SHIFT + Insert", brightness .. "+")
repeat_cmd("XF86MonBrightnessUp", brightness .. "+")
repeat_cmd("XF86MonBrightnessDown", brightness .. "-")
repeat_cmd("XF86ChannelUp", contrast .. "+")
repeat_cmd("XF86ChannelDown", contrast .. "-")
repeat_cmd("code:192", contrast .. "+")
repeat_cmd("code:191", contrast .. "-")

msh("SHIFT + Z", [[
upower -d /org/freedesktop/UPower/devices/battery_BAT0 |
awk '/percentage:/ {gsub("%","",$2); print $2; exit}' | wl-copy
]])

-- Audio
local wob = scripts .. "wob-push"
local volume_status = [[
wpctl get-volume @DEFAULT_SINK@ |
awk '{muted=($0~/MUTED/?" muted":""); gsub(/[^0-9]/,"",$2); printf "%d%s\n",$2/2,muted}' |
]] .. wob

local function volume(keys, cmd)
    hl.bind(keys, sh(cmd .. " && " .. volume_status), repeat_locked)
end

volume("XF86AudioRaiseVolume", "wpctl set-volume -l 2.0 @DEFAULT_SINK@ 2%+")
volume("XF86AudioLowerVolume", "wpctl set-volume -l 2.0 @DEFAULT_SINK@ 2%-")
volume("XF86AudioMute", "wpctl set-mute @DEFAULT_SINK@ toggle")

-- Misc
msh("CTRL + R", "XDG_MENU_PREFIX=arch- kbuildsycoca6")
mraw("CTRL + E", "systemctl restart --user wireplumber")
mraw("CTRL + SHIFT + O", "loginctl terminate-user " .. U)
hl.bind("F6", raw("ydotool click --repeat 20 --next-delay 6 0xC0"))
