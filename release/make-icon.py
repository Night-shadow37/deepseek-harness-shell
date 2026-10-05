from PIL import Image
import os

src = r'D:\dsh\harness-shell\assets\icon.png'
dst = r'D:\dsh\harness-shell\assets\icon-pillow-new.ico'

img = Image.open(src)
if img.mode in ('RGBA', 'LA', 'P'):
    # Ensure alpha channel is preserved
    pass
elif img.mode != 'RGB':
    img = img.convert('RGBA')
else:
    img = img.convert('RGBA')

sizes = [(16,16), (32,32), (48,48), (64,64), (128,128), (256,256)]
images = []
for s in sizes:
    resized = img.resize(s, Image.Resampling.LANCZOS)
    images.append(resized)

images[0].save(dst, format='ICO', sizes=[(im.width, im.height) for im in images])
print('Created', dst)
print('Sizes:', [(im.width, im.height) for im in images])
