import re

filepath = 'android/app/src/main/AndroidManifest.xml'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

if 'DELAY_APP_MEASUREMENT_INIT' not in content:
    content = content.replace(
        '<meta-data\n            android:name="com.google.android.gms.ads.APPLICATION_ID"',
        '<meta-data\n            android:name="com.google.android.gms.ads.DELAY_APP_MEASUREMENT_INIT"\n            android:value="true"/>\n        <meta-data\n            android:name="com.google.android.gms.ads.APPLICATION_ID"'
    )
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print('Added DELAY_APP_MEASUREMENT_INIT')
