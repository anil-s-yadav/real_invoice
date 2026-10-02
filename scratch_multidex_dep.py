import re

filepath = 'android/app/build.gradle.kts'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

if 'multidex:2.0.1' not in content:
    content = content.replace(
        'dependencies {',
        'dependencies {\n    implementation("androidx.multidex:multidex:2.0.1")'
    )
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Added multidex dependency")
