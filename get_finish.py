with open('lib/features/onboarding/presentation/onboarding_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

start = -1
for i, line in enumerate(lines):
    if "_finishAndNavigate" in line and "Future<void>" in line:
        start = i
        break

if start != -1:
    for i in range(start, start + 30):
        if i < len(lines):
            print(lines[i], end='')
