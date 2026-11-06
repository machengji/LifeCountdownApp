import os
import shutil
import zipfile

base_dir = r"C:\Users\Administrator\.gemini\antigravity\scratch\LifeCountdownApp"
dist_dir = os.path.join(base_dir, "dist")
app_dir = os.path.join(dist_dir, "unpacked", "Payload", "LifeCountdownApp.app")
plugin_dir = os.path.join(app_dir, "PlugIns", "LifeWidget.appex")

# 1. 修复主 App Info.plist (包含 UILaunchScreen 确保全面屏铺满，杜绝上下黑边！)
app_plist_content = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>zh_CN</string>
	<key>CFBundleDisplayName</key>
	<string>&#20154;&#29983;&#20498;&#35745;&#26102;</string>
	<key>CFBundleExecutable</key>
	<string>LifeCountdownApp</string>
	<key>CFBundleIdentifier</key>
	<string>com.lifecountdown.app</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>LifeCountdownApp</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0.3</string>
	<key>CFBundleVersion</key>
	<string>4</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>UILaunchScreen</key>
	<dict/>
	<key>MinimumOSVersion</key>
	<string>17.0</string>
	<key>UIDeviceFamily</key>
	<array>
		<integer>1</integer>
		<integer>2</integer>
	</array>
	<key>UIRequiredDeviceCapabilities</key>
	<array>
		<string>arm64</string>
	</array>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
	</array>
	<key>CFBundleIcons</key>
	<dict>
		<key>CFBundlePrimaryIcon</key>
		<dict>
			<key>CFBundleIconFiles</key>
			<array>
				<string>AppIcon60x60</string>
			</array>
			<key>CFBundleIconName</key>
			<string>AppIcon</string>
		</dict>
	</dict>
	<key>CFBundleIcons~ipad</key>
	<dict>
		<key>CFBundlePrimaryIcon</key>
		<dict>
			<key>CFBundleIconFiles</key>
			<array>
				<string>AppIcon60x60</string>
				<string>AppIcon76x76</string>
			</array>
			<key>CFBundleIconName</key>
			<string>AppIcon</string>
		</dict>
	</dict>
</dict>
</plist>
"""

with open(os.path.join(app_dir, "Info.plist"), "wb") as f:
    f.write(app_plist_content.encode("utf-8"))

# 2. 修复 Widget Info.plist
widget_plist_content = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>zh_CN</string>
	<key>CFBundleDisplayName</key>
	<string>&#20154;&#29983;&#20498;&#35745;&#26102;</string>
	<key>CFBundleExecutable</key>
	<string>LifeWidget</string>
	<key>CFBundleIdentifier</key>
	<string>com.lifecountdown.app.widget</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>LifeWidget</string>
	<key>CFBundlePackageType</key>
	<string>XPC!</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0.3</string>
	<key>CFBundleVersion</key>
	<string>4</string>
	<key>MinimumOSVersion</key>
	<string>17.0</string>
	<key>UIDeviceFamily</key>
	<array>
		<integer>1</integer>
		<integer>2</integer>
	</array>
	<key>UIRequiredDeviceCapabilities</key>
	<array>
		<string>arm64</string>
	</array>
	<key>NSExtension</key>
	<dict>
		<key>NSExtensionPointIdentifier</key>
		<string>com.apple.widgetkit-extension</string>
	</dict>
</dict>
</plist>
"""

with open(os.path.join(plugin_dir, "Info.plist"), "wb") as f:
    f.write(widget_plist_content.encode("utf-8"))

# 3. 复制图标资源与 iTunesArtwork
for icon_name in ["AppIcon60x60@2x.png", "AppIcon60x60@3x.png", "AppIcon76x76@2x~ipad.png"]:
    src = os.path.join(base_dir, "LifeCountdownApp", icon_name)
    dst = os.path.join(app_dir, icon_name)
    shutil.copy2(src, dst)

shutil.copy2(os.path.join(base_dir, "preview", "app_icon.png"), os.path.join(app_dir, "iTunesArtwork@2x.png"))

# 4. 确保 PkgInfo 存在
with open(os.path.join(app_dir, "PkgInfo"), "wb") as f:
    f.write(b"APPL????")

with open(os.path.join(plugin_dir, "PkgInfo"), "wb") as f:
    f.write(b"XPC!????")

# 5. 打包生成完美的全面屏 LifeCountdownApp.ipa
ipa_path = os.path.join(dist_dir, "LifeCountdownApp.ipa")
payload_root = os.path.join(dist_dir, "unpacked")

if os.path.exists(ipa_path):
    os.remove(ipa_path)

with zipfile.ZipFile(ipa_path, "w", zipfile.ZIP_DEFLATED) as zipf:
    for root, dirs, files in os.walk(os.path.join(payload_root, "Payload")):
        for file in files:
            full_path = os.path.join(root, file)
            rel_path = os.path.relpath(full_path, payload_root)
            zipf.write(full_path, rel_path)

print("Created perfect FullScreen IPA successfully, file size:", os.path.getsize(ipa_path))
