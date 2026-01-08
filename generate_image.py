import subprocess
import sys
from PIL import Image, ImageDraw, ImageFont
import os

def create_image():
    env = os.environ.copy()
    env["PYTHONIOENCODING"] = "utf-8"
    env["PYTHONUTF8"] = "1"
    
    result = subprocess.run(
        [sys.executable, "hello2.py"], 
        capture_output=True, 
        text=True, 
        encoding='utf-8',
        env=env
    )
    
    if result.returncode != 0:
        print(f"Error running hello2.py: {result.stderr}")
        text = "Error: Could not get output"
    else:
        text = result.stdout.strip()
        if not text:
            print("Warning: Output was empty")

    width = 800
    height = 200
    background_color = (255, 255, 255)
    text_color = (0, 0, 0)
    
    image = Image.new('RGB', (width, height), background_color)
    draw = ImageDraw.Draw(image)
    
    font_path = "C:/Windows/Fonts/malgun.ttf"
    try:
        font = ImageFont.truetype(font_path, 24)
    except IOError:
        font = ImageFont.load_default()
        print(f"Warning: Could not load {font_path}. Using default font.")

    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    x = (width - text_width) / 2
    y = (height - text_height) / 2
    
    draw.text((x, y), text, fill=text_color, font=font)
    
    output_file = "hello_output.png"
    image.save(output_file)
    print(f"Image saved to {output_file}")

if __name__ == "__main__":
    create_image()
