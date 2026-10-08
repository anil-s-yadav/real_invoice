import re

with open("android/app/src/main/AndroidManifest.xml", "r", encoding="utf-8") as f:
    content = f.read()

# Add meta-data right before </application>
meta_data = """
        <!-- Set custom default icon. This is used when no icon is set for incoming push messages -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@drawable/ic_notification" />
"""

if "com.google.firebase.messaging.default_notification_icon" not in content:
    content = content.replace("</application>", meta_data + "\n    </application>")

with open("android/app/src/main/AndroidManifest.xml", "w", encoding="utf-8") as f:
    f.write(content)
