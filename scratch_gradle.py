import re

filepath = 'android/app/build.gradle.kts'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

old_release = '''        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }'''

new_release = '''        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }'''

if 'isMinifyEnabled' not in content:
    content = content.replace(old_release, new_release)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print('Updated build.gradle.kts with proguard rules')
else:
    print('Already updated')
