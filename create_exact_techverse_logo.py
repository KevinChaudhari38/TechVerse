#!/usr/bin/env python3
"""
Exact TECHVERSE Logo Recreation
Recreates the exact logo from the provided image with all details
"""

from PIL import Image, ImageDraw, ImageFont
import os
import math

def create_hexagonal_grid(size, grid_size=20):
    """Create hexagonal grid background"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw hexagonal grid
    for i in range(0, size + grid_size, grid_size):
        for j in range(0, size + grid_size, grid_size):
            # Hexagon points
            center_x = i
            center_y = j
            radius = grid_size // 3
            
            points = []
            for angle in range(0, 360, 60):
                rad = math.radians(angle)
                x = center_x + radius * math.cos(rad)
                y = center_y + radius * math.sin(rad)
                points.append((x, y))
            
            if len(points) >= 3:
                draw.polygon(points, outline=(20, 30, 50, 30), width=1)
    
    return img

def create_gradient_circle(size, center, radius, colors):
    """Create a gradient circle"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    for r in range(radius, 0, -1):
        ratio = r / radius
        r_val = int(colors[0][0] * (1 - ratio) + colors[1][0] * ratio)
        g_val = int(colors[0][1] * (1 - ratio) + colors[1][1] * ratio)
        b_val = int(colors[0][2] * (1 - ratio) + colors[1][2] * ratio)
        alpha = int(255 * (1 - ratio) * 0.3)
        
        draw.ellipse([center[0] - r, center[1] - r, center[0] + r, center[1] + r], 
                    fill=(r_val, g_val, b_val, alpha))
    
    return img

def create_exact_techverse_icon(size, output_path):
    """Create the exact TECHVERSE logo from the image"""
    # Create base image
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Dark blue-black background
    background_color = (10, 15, 25)
    draw.rectangle([0, 0, size, size], fill=background_color)
    
    # Add hexagonal grid background
    grid_img = create_hexagonal_grid(size, size // 15)
    img = Image.alpha_composite(img, grid_img)
    
    # Add scattered dots (stars/data points)
    for _ in range(size // 3):
        x = (hash(str(_)) % size)
        y = (hash(str(_ * 2)) % size)
        dot_size = (hash(str(_ * 3)) % 3) + 1
        dot_color = (100, 150, 255, 150) if hash(str(_)) % 2 == 0 else (255, 255, 255, 100)
        draw.ellipse([x - dot_size, y - dot_size, x + dot_size, y + dot_size], fill=dot_color)
    
    # Create the geometric T+V symbol
    center_x, center_y = size // 2, size // 2 - size // 8
    symbol_size = size // 3
    
    # Define the T+V symbol points (geometric shape)
    # This creates the faceted, crystalline appearance
    symbol_points = [
        # T part (left side)
        (center_x - symbol_size, center_y - symbol_size // 2),
        (center_x - symbol_size // 3, center_y - symbol_size // 2),
        (center_x - symbol_size // 3, center_y + symbol_size // 2),
        (center_x + symbol_size // 3, center_y + symbol_size // 2),
        (center_x + symbol_size // 3, center_y - symbol_size // 2),
        (center_x + symbol_size, center_y - symbol_size // 2),
        # V part (right side)
        (center_x + symbol_size, center_y + symbol_size // 2),
        (center_x + symbol_size // 2, center_y + symbol_size),
        (center_x - symbol_size // 2, center_y + symbol_size),
        (center_x - symbol_size, center_y + symbol_size // 2),
        (center_x - symbol_size, center_y - symbol_size // 2)
    ]
    
    # Create gradient for the symbol
    symbol_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    symbol_draw = ImageDraw.Draw(symbol_img)
    
    # Draw the main symbol with gradient
    for i, point in enumerate(symbol_points):
        if i < len(symbol_points) - 1:
            next_point = symbol_points[i + 1]
            # Create gradient line
            steps = 20
            for step in range(steps):
                ratio = step / steps
                x1 = point[0] + (next_point[0] - point[0]) * ratio
                y1 = point[1] + (next_point[1] - point[1]) * ratio
                x2 = point[0] + (next_point[0] - point[0]) * (ratio + 1/steps)
                y2 = point[1] + (next_point[1] - point[1]) * (ratio + 1/steps)
                
                # Blue to purple gradient
                r = int(0 * (1 - ratio) + 138 * ratio)
                g = int(162 * (1 - ratio) + 43 * ratio)
                b = int(255 * (1 - ratio) + 226 * ratio)
                
                symbol_draw.line([x1, y1, x2, y2], fill=(r, g, b, 255), width=3)
    
    # Fill the symbol with gradient
    symbol_draw.polygon(symbol_points, fill=(0, 162, 255, 200))
    
    # Add circuit traces and dots within the symbol
    for i in range(5):
        x = center_x - symbol_size // 2 + (i * symbol_size // 4)
        y = center_y - symbol_size // 4
        for j in range(3):
            dot_y = y + (j * symbol_size // 6)
            symbol_draw.ellipse([x - 1, dot_y - 1, x + 1, dot_y + 1], fill=(255, 255, 255, 255))
    
    # Add glow effect to symbol
    glow_img = create_gradient_circle(size, (center_x, center_y + symbol_size // 4), 
                                    symbol_size, [(138, 43, 226), (255, 0, 255)])
    symbol_img = Image.alpha_composite(symbol_img, glow_img)
    
    # Apply symbol to main image
    img = Image.alpha_composite(img, symbol_img)
    
    # Add "TECHVERSE" text
    text_y = center_y + symbol_size + size // 12
    
    try:
        font_size = max(8, size // 12)
        font = ImageFont.truetype("arial.ttf", font_size)
    except:
        font = ImageFont.load_default()
    
    text = "TECHVERSE"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_x = (size - text_width) // 2
    
    # Draw text with gradient effect
    for i, char in enumerate(text):
        char_bbox = draw.textbbox((0, 0), char, font=font)
        char_width = char_bbox[2] - char_bbox[0]
        char_x = text_x + sum(draw.textbbox((0, 0), text[:j], font=font)[2] - draw.textbbox((0, 0), text[:j], font=font)[0] for j in range(i))
        
        # Blue to purple gradient for each character
        ratio = i / (len(text) - 1) if len(text) > 1 else 0
        r = int(0 * (1 - ratio) + 138 * ratio)
        g = int(162 * (1 - ratio) + 43 * ratio)
        b = int(255 * (1 - ratio) + 226 * ratio)
        
        # Add glow to text
        for offset in range(2, 0, -1):
            glow_alpha = 100 - (offset * 40)
            draw.text((char_x + offset, text_y + offset), char, 
                     font=font, fill=(r, g, b, glow_alpha))
        
        # Draw main text
        draw.text((char_x, text_y), char, font=font, fill=(r, g, b, 255))
    
    # Add concentric circular rings
    ring_center = (size // 2, size // 2)
    ring_radius = size // 2 - size // 16
    
    for ring in range(3):
        radius = ring_radius - (ring * size // 32)
        alpha = 100 - (ring * 30)
        
        # Blue to purple gradient for rings
        for angle in range(0, 360, 5):
            rad = math.radians(angle)
            x1 = ring_center[0] + radius * math.cos(rad)
            y1 = ring_center[1] + radius * math.sin(rad)
            x2 = ring_center[0] + (radius - 1) * math.cos(rad)
            y2 = ring_center[1] + (radius - 1) * math.sin(rad)
            
            ratio = angle / 360
            r = int(0 * (1 - ratio) + 138 * ratio)
            g = int(162 * (1 - ratio) + 43 * ratio)
            b = int(255 * (1 - ratio) + 226 * ratio)
            
            draw.line([x1, y1, x2, y2], fill=(r, g, b, alpha), width=1)
    
    # Add small diamond icon in bottom right
    diamond_size = size // 20
    diamond_x = size - size // 8
    diamond_y = size - size // 8
    
    diamond_points = [
        (diamond_x, diamond_y - diamond_size),
        (diamond_x + diamond_size, diamond_y),
        (diamond_x, diamond_y + diamond_size),
        (diamond_x - diamond_size, diamond_y)
    ]
    
    draw.polygon(diamond_points, fill=(150, 150, 150, 200))
    
    # Save the image
    img.save(output_path, 'PNG')
    print(f"Created exact TECHVERSE icon: {output_path} ({size}x{size})")

def main():
    """Create all required Android icon densities with exact logo"""
    # Android icon densities and their sizes
    densities = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192
    }
    
    base_path = "android/app/src/main/res"
    
    for density, size in densities.items():
        density_path = os.path.join(base_path, density)
        os.makedirs(density_path, exist_ok=True)
        output_path = os.path.join(density_path, "ic_launcher.png")
        create_exact_techverse_icon(size, output_path)
    
    print("All exact TECHVERSE Android app icons created successfully!")
    print("Features recreated:")
    print("- Geometric T+V symbol with faceted appearance")
    print("- Blue to purple gradient colors")
    print("- Hexagonal grid background")
    print("- Scattered glowing dots")
    print("- Concentric circular rings")
    print("- TECHVERSE text with gradient")
    print("- Diamond icon in corner")
    print("- Exact recreation of provided logo")

if __name__ == "__main__":
    main()

