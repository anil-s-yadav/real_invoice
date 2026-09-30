with open('d:/real_invoice/android/app/src/main/AndroidManifest.xml', 'r', encoding='utf-8') as f:
    content = f.read()

old_id = 'ca-app-pub-3940256099942544~3347511713'
new_id = 'ca-app-pub-3285536359619016~4221250290'

content = content.replace(old_id, new_id)

with open('d:/real_invoice/android/app/src/main/AndroidManifest.xml', 'w', encoding='utf-8') as f:
    f.write(content)

print("AndroidManifest.xml updated with real App ID")