import re

filepath = 'lib/main.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

bad_text = '''              "App Error:
${details.exception}

Stacktrace:
${details.stack}",'''

good_text = '''              "App Error:\\n${details.exception}\\n\\nStacktrace:\\n${details.stack}",'''

content = content.replace(bad_text, good_text)
with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print("Fixed string literal syntax error")
