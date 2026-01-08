from PIL import Image, ImageDraw, ImageFont
import subprocess
import sys
import os

def create_image():
    env = os.environ.copy()
    env["PYTHONIOENCODING"] = "utf-8"
    result = subprocess.run([sys.executable, "hello2.py"], capture_output=True, text=True, encoding='utf-8', env=env)
    text = result.stdout.strip()
    
    width = 800
    height = 200
    background_color = (255, 255, 255)
    text_color = (0, 0, 0)
    font_size = 24
    
    image = Image.new('RGB', (width, height), background_color)
    draw = ImageDraw.Draw(image)
    
    try:
        font = ImageFont.truetype("C:\\Windows\\Fonts\\malgun.ttf", font_size)
    except IOError:
        try:
            font = ImageFont.truetype("arial.ttf", font_size)
        except IOError:
            font = ImageFont.load_default()
            
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
        
    x = (width - text_width) // 2
    y = (height - text_height) // 2
    
    try:
        draw.text((x, y), text, font=font, fill=text_color)
        
        output_path = "hello_output.png"
        image.save(output_path)
        print(f"Image saved to {output_path}")
        
    except Exception as e:
        print(f"Error drawing text: {e}")

if __name__ == "__main__":
    create_image()
