# Remote Device Testing Guide

How to upload and test the theme on a real device over SSH.

> **Pre-flight note:** After every reboot, reconnect the device to Wi-Fi (its IP may change if the DHCP lease expires), enable remote services, and install the SSH keys so no password prompt is required.

## 💻 Target Device System Constraints

```sh
DEVICE_IP="192.168.2.XX"
USER="ark"
```

- **Device Panel Resolution:** 720×720 pixels (strict 1:1 square aspect ratio)
- **Operating System Layout:** ArkOS4Clones (Ubuntu-based backend)
- **Theme Engine:** EmulationStation (normalized layout values, 0.0 to 1.0)
- **Frontend System Sync Location:** `/roms/themes/<your-theme-folder>/`
- **Quick Reload Command:** `touch /tmp/es-restart && killall /usr/bin/emulationstation/emulationstation`

## 🎮 Hardware Controller Device Map (`/dev/input/event2`)

The device inputs register as `EV_KEY` types on `event2`. To navigate EmulationStation sub-menus, the agent must toggle the key states from up to down (`1` down, `0` up) followed by a hardware `--sync`.

### System Mapping Directory

| Action | Key |
| --- | --- |
| A Button (Accept/Enter) | `BTN_SOUTH` |
| B Button (Back/Cancel) | `BTN_EAST` |
| X Button | `BTN_NORTH` |
| Y Button | `BTN_WEST` |
| D-Pad Up | `BTN_DPAD_UP` |
| D-Pad Down | `BTN_DPAD_DOWN` |
| D-Pad Left | `BTN_DPAD_LEFT` |
| D-Pad Right | `BTN_DPAD_RIGHT` |
| Shoulder Modifiers | `BTN_TL` (L1), `BTN_TR` (R1), `BTN_TL2` (L2), `BTN_TR2` (R2) |
| System Functions (Select / Start / Fn) | `BTN_TRIGGER_HAPPY1`, `BTN_TRIGGER_HAPPY2`, `BTN_TRIGGER_HAPPY5` |

## 🔄 The Automation & Validation Loop (Task for the Agent)

Your agent is responsible for managing a sequential state machine to verify layout code changes across multiple EmulationStation view categories (system, basic, detailed, or video). Because it has passwordless SSH keys authorized, it must orchestrate the following workflow step-by-step.

### State 1: File Delta & Injection

1. Identify code or asset modifications within the local 720×720 theme project path.
2. Synchronize modified directories to `/roms/themes/` on the target device via `rsync`.

### State 2: Display Framework Reset

1. Flush active memory and target the display panel engine by executing `touch /tmp/es-restart && killall /usr/bin/emulationstation/emulationstation` remotely over SSH.
2. Hold execution block for 6–8 seconds to ensure asset pre-rendering and UI initialization phases complete.

### State 3: Target View Traversal (State Machine)

To evaluate complex UI changes (such as the main carousel vs. text list positions inside a system folder), the agent must dynamically track which menu it is currently viewing. It can inject artificial player states using `evemu-event` on `/dev/input/event2`:

- **Example:** To evaluate a detailed list layout, issue a sequence that sends a down-stroke on `BTN_SOUTH` (value `1`), waits, releases it (value `0`), and pauses for menu transition animations.

### State 4: Hardcoded Frame Capture

1. Once it navigates to the target view state, capture the raw DRM/KMS hardware display interface using `ffmpeg` coupled with a filter configuration map:

   ```bash
   sudo ffmpeg -y -f kmsgrab -i - -vf "hwdownload,format=bgr0" -vframes 1 /tmp/feedback.png
   ```

2. Download the resulting 720×720 image back to the development environment.

### State 5: Layout Audit (Self-Correction)

1. Read and analyze the pulled image file.
2. Cross-reference layout positioning, asset clipping, aspect-ratio skewing, or text wrapping bugs relative to the 720×720 canvas dimensions.
3. Automatically adjust XML elements within `theme.xml` and loop back to State 1.

## Example Script

```bash
#!/bin/bash

DEVICE_IP="192.168.2.135"
USER="ark"
THEME_NAME="es-theme-SOLO-Ultra"
LOCAL_PATH="./theme_files/"
REMOTE_PATH="/roms/themes/$THEME_NAME/"

# Change these based on what you found via evemu-record
A_BUTTON="BTN_SOUTH"

echo "🚀 Step 1: Pushing layout changes..."
rsync -avz --delete -e ssh ./theme_files/ ark@YOUR_DEVICE_IP:/roms/themes/agent_theme_dev/

echo "🔄 Step 2: Restarting EmulationStation..."
ssh "$USER@$DEVICE_IP" "touch /tmp/es-restart && killall /usr/bin/emulationstation/emulationstation"

echo "⏳ Step 3: Waiting for System View to render..."
sleep 6

# --- INTERACTIVE NAVIGATION SECTION ---
echo "🎮 Step 4: Injecting 'A' button to enter Detailed Gamelist View..."
ssh "$USER@$DEVICE_IP" "sudo evemu-event /dev/input/event2 --type EV_KEY --code $A_BUTTON --value 1 --sync && sleep 0.1 && sudo evemu-event /dev/input/event2 --type EV_KEY --code $A_BUTTON --value 0 --sync"

echo "⏳ Step 5: Waiting for menu transition animation..."
sleep 2

# --- VERIFICATION SECTION ---
echo "📸 Step 6: Grabbing hardware screenshot of the Detailed View..."
ssh -t "$USER@$DEVICE_IP" "sudo ffmpeg -y -f kmsgrab -i - -vf 'hwdownload,format=bgr0' -vframes 1 /tmp/detailed_feedback.png 2>/dev/null"

echo "📥 Step 7: Pulling 720x720 visual validation back to PC..."
scp -q "$USER@$DEVICE_IP:/tmp/detailed_feedback.png" "./last_render_detailed.png"

echo "✅ Task complete. Agent can now audit './last_render_detailed.png'."
```
