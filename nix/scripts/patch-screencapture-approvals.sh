screenCaptureApps=(
  "/Applications/CleanShot X.app/Contents/MacOS/CleanShot X"
  "/Applications/zoom.us.app/Contents/MacOS/zoom.us"
)

for app in "${screenCaptureApps[@]}"; do
  defaults write ~/Library/Group\ Containers/group.com.apple.replayd/ScreenCaptureApprovals.plist \
    "$app" -date "3024-09-17 14:59:37 +0000"
done
