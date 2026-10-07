import re

with open("lib/core/services/local_notification_service.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("'@mipmap/ic_launcher'", "'@drawable/ic_notification'")

with open("lib/core/services/local_notification_service.dart", "w", encoding="utf-8") as f:
    f.write(content)
