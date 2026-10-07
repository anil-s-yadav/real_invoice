from PIL import Image, ImageChops
import numpy as np

# Load the image
img_path = r'C:\Users\USER\.gemini\antigravity\brain\d22a9ab0-14b5-4832-a28a-0be5cd2f2758\.user_uploaded\media_1791392751090.png'
img = Image.open(img_path).convert('RGBA')
arr = np.array(img)

# The logo is bright blue, text is dark navy, background is white/transparent
# Let's extract the blue color. 
# Blue logo roughly has High B, lower R and G.
r, g, b, a = arr[:,:,0], arr[:,:,1], arr[:,:,2], arr[:,:,3]

# Create a mask for the bright blue document
# Let's use a threshold: B > 150, R < 150 (to exclude white background where R>200)
mask = (b > 150) & (r < 150) & (a > 100)

# The two white lines inside the document are currently excluded because they are white (R>200). 
# Wait, if we just extract the blue, the holes (lines) will naturally be transparent! Which is PERFECT for a silhouette!

# Create a completely transparent image
out_arr = np.zeros_like(arr)

# Wherever the mask is true, make it solid white with full opacity
out_arr[mask] = [255, 255, 255, 255]

out_img = Image.fromarray(out_arr)

# Get bounding box of the non-zero alpha
bbox = out_img.getbbox()
out_img = out_img.crop(bbox)

# Add 15% padding so it looks good in the status bar (Android recommends some padding)
width, height = out_img.size
padding = int(max(width, height) * 0.15)
new_width = width + padding * 2
new_height = height + padding * 2

padded_img = Image.new('RGBA', (new_width, new_height), (0, 0, 0, 0))
padded_img.paste(out_img, (padding + (max(width, height)-width)//2, padding + (max(width, height)-height)//2))

# Resize to standard notification icon size (96x96 for xxhdpi is a good generic size)
padded_img = padded_img.resize((96, 96), Image.Resampling.LANCZOS)

# Save to Android drawable folder
import os
os.makedirs('android/app/src/main/res/drawable', exist_ok=True)
padded_img.save('android/app/src/main/res/drawable/ic_notification.png')
print('Notification icon created successfully at android/app/src/main/res/drawable/ic_notification.png')
