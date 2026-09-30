with open('d:/real_invoice/lib/features/onboarding/presentation/onboarding_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("if (widget.isAddingNewCompany {", "if (widget.isAddingNewCompany) {")

with open('d:/real_invoice/lib/features/onboarding/presentation/onboarding_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("Fixed missing parenthesis")