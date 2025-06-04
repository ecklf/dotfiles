echo "patching macOS screen capture approvals for user $NIX_RUN_USER"
screenCaptureApps=(
  "/Applications/CleanShot X.app/Contents/MacOS/CleanShot X"
  "/Applications/zoom.us.app/Contents/MacOS/zoom.us"
  "/Applications/Slack.app/Contents/MacOS/Slack"
)

for app in "${screenCaptureApps[@]}"; do
  sudo -u "$NIX_RUN_USER" defaults write /Users/"$NIX_RUN_USER"/Library/Group\ Containers/group.com.apple.replayd/ScreenCaptureApprovals.plist \
    "$app" -date "3000-01-01 00:00:00 +0000"
done
