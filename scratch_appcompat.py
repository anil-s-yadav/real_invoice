import re

filepath = 'android/app/build.gradle.kts'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

if 'appcompat:1.6.1' not in content:
    content = content.replace(
        'dependencies {',
        'dependencies {\n    implementation("androidx.appcompat:appcompat:1.6.1")'
    )
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Added appcompat dependency")
