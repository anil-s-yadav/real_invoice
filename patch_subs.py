with open('d:/real_invoice/lib/features/subscription/presentation/subscription_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

old = """              // Plan Cards Carousel
              SizedBox(
                height: 480,
                child: PageView.builder("""

new = """              // Plan Cards Carousel
              SizedBox(
                height: 580,
                child: PageView.builder("""

text = text.replace(old, new)

with open('d:/real_invoice/lib/features/subscription/presentation/subscription_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("Updated height to 580")