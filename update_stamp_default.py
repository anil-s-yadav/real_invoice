import re

with open('lib/features/documents/domain/document_model.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("this.showStamp = false,", "this.showStamp = true,")
content = content.replace("showStamp: map['showStamp'] as bool? ?? false,", "showStamp: map['showStamp'] as bool? ?? true,")

with open('lib/features/documents/domain/document_model.dart', 'w', encoding='utf-8') as f:
    f.write(content)
