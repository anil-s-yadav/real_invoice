with open('d:/real_invoice/android/app/src/main/AndroidManifest.xml', 'r', encoding='utf-8') as f:
    content = f.read()

tag = """        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-3940256099942544~3347511713"/>"""

if "com.google.android.gms.ads.APPLICATION_ID" not in content:
    content = content.replace("</application>", f"{tag}\n    </application>")
    with open('d:/real_invoice/android/app/src/main/AndroidManifest.xml', 'w', encoding='utf-8') as f:
        f.write(content)
    print("AndroidManifest.xml patched")
else:
    print("AndroidManifest.xml already patched")