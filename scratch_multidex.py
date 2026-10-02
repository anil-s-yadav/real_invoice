import re

filepath = 'android/app/build.gradle.kts'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

if 'multiDexEnabled' not in content:
    content = content.replace(
        'versionName = flutter.versionName',
        'versionName = flutter.versionName\n        multiDexEnabled = true'
    )
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print('Added multiDexEnabled')
