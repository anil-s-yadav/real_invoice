import re

filepath = 'android/app/build.gradle.kts'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

old_release = '''        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }'''

new_release = '''        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }'''

content = content.replace(old_release, new_release)
with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Reverted isMinifyEnabled but kept proguard rules')
