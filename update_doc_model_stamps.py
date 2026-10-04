import re

with open('lib/features/documents/domain/document_model.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add fields
content = content.replace('final bool enableRoundOff;', 'final bool enableRoundOff;\n  final bool showSignature;\n  final bool showStamp;')
content = content.replace('this.enableRoundOff = true,', 'this.enableRoundOff = true,\n    this.showSignature = true,\n    this.showStamp = false,')

# Update toMap
content = content.replace("'enableRoundOff': enableRoundOff,", "'enableRoundOff': enableRoundOff,\n      'showSignature': showSignature,\n      'showStamp': showStamp,")

# Update fromMap
content = content.replace("enableRoundOff: map['enableRoundOff'] as bool? ?? true,", "enableRoundOff: map['enableRoundOff'] as bool? ?? true,\n      showSignature: map['showSignature'] as bool? ?? true,\n      showStamp: map['showStamp'] as bool? ?? false,")

# Update copyWith
content = content.replace("bool? enableRoundOff,", "bool? enableRoundOff,\n    bool? showSignature,\n    bool? showStamp,")
content = content.replace("enableRoundOff: enableRoundOff ?? this.enableRoundOff,", "enableRoundOff: enableRoundOff ?? this.enableRoundOff,\n      showSignature: showSignature ?? this.showSignature,\n      showStamp: showStamp ?? this.showStamp,")

with open('lib/features/documents/domain/document_model.dart', 'w', encoding='utf-8') as f:
    f.write(content)
