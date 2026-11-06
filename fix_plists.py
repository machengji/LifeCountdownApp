import plistlib
import os

app_dir = r"C:\Users\Administrator\.gemini\antigravity\scratch\LifeCountdownApp\dist\unpacked\Payload\LifeCountdownApp.app"
widget_dir = os.path.join(app_dir, "PlugIns", "LifeWidget.appex")

# 绝对安全的 Unicode 字符构造：人生倒计时
app_name = "".join([chr(0x4eba), chr(0x751f), chr(0x5012), chr(0x8ba1), chr(0x65f6)])

app_plist = {
    "CFBundleDevelopmentRegion": "zh_CN",
    "CFBundleDisplayName": app_name,
    "CFBundleExecutable": "LifeCountdownApp",
    "CFBundleIdentifier": "com.lifecountdown.app",
    "CFBundleInfoDictionaryVersion": "6.0",
    "CFBundleName": "LifeCountdownApp",
    "CFBundlePackageType": "APPL",
    "CFBundleShortVersionString": "1.0.1",
    "CFBundleVersion": "2",
    "LSRequiresIPhoneOS": True,
    "MinimumOSVersion": "17.0",
    "UIDeviceFamily": [1, 2],
    "UIRequiredDeviceCapabilities": ["arm64"],
    "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"],
    "CFBundleIcons": {
        "CFBundlePrimaryIcon": {
            "CFBundleIconFiles": ["AppIcon60x60"],
            "CFBundleIconName": "AppIcon"
        }
    },
    "CFBundleIcons~ipad": {
        "CFBundlePrimaryIcon": {
            "CFBundleIconFiles": ["AppIcon60x60", "AppIcon76x76"],
            "CFBundleIconName": "AppIcon"
        }
    }
}

widget_plist = {
    "CFBundleDevelopmentRegion": "zh_CN",
    "CFBundleDisplayName": app_name,
    "CFBundleExecutable": "LifeWidget",
    "CFBundleIdentifier": "com.lifecountdown.app.widget",
    "CFBundleInfoDictionaryVersion": "6.0",
    "CFBundleName": "LifeWidget",
    "CFBundlePackageType": "XPC!",
    "CFBundleShortVersionString": "1.0.1",
    "CFBundleVersion": "2",
    "MinimumOSVersion": "17.0",
    "UIDeviceFamily": [1, 2],
    "UIRequiredDeviceCapabilities": ["arm64"],
    "NSExtension": {
        "NSExtensionPointIdentifier": "com.apple.widgetkit-extension"
    }
}

with open(os.path.join(app_dir, "Info.plist"), "wb") as f:
    plistlib.dump(app_plist, f, fmt=plistlib.FMT_XML)

with open(os.path.join(widget_dir, "Info.plist"), "wb") as f:
    plistlib.dump(widget_plist, f, fmt=plistlib.FMT_XML)

print("Saved UTF-8 Info.plist with chr() successfully!")
