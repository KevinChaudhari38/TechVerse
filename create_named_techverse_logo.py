#!/usr/bin/env python3
"""
Advanced TechVerse Android App Icon Generator with App Name
Creates a sophisticated logo with "TechVerse" text and modern color scheme
"""

from PIL import Image, ImageDraw, ImageFont
import os
import math

def create_gradient_background(size, colors):
    """Create a diagonal gradient background"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    for i in range(size):
        for j in range(size):
            # Diagonal gradient
            ratio = (i + j) / (size * 2)
            r = int(colors[0][0] * (1 - ratio) + colors[1][0] * ratio)
            g = int(colors[0][1] * (1 - ratio) + colors[1][1] * ratio)
            b = int(colors[0][2] * (1 - ratio) + colors[1][2] * ratio)
            
            draw.point((i, j), fill=(r, g, b, 255))
    
    return img

def create_named_techverse_icon(size, output_path):
    """Create an advanced TechVerse app icon with app name and modern design"""
    # Create base image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Modern color scheme - Purple to Orange gradient
    primary_gradient = [(139, 69, 19), (255, 140, 0)]  # Brown to Orange
    accent_gradient = [(75, 0, 130), (138, 43, 226)]  # Indigo to Blue Violet
    highlight_color = (255, 255, 255)  # White
    text_color = (255, 255, 255)  # White text
    glow_color = (255, 140, 0, 150)  # Orange glow
    
    # Calculate dimensions
    margin = size // 16
    corner_radius = size // 10
    
    # Create gradient background
    bg_img = create_gradient_background(size, primary_gradient)
    img.paste(bg_img, (0, 0))
    
    # Add geometric pattern overlay
    pattern_size = size // 25
    for i in range(0, size, pattern_size * 3):
        for j in range(0, size, pattern_size * 3):
            if (i + j) % (pattern_size * 6) == 0:
                # Create diamond pattern
                center_x, center_y = i + pattern_size, j + pattern_size
                points = [
                    (center_x, center_y - pattern_size),
                    (center_x + pattern_size, center_y),
                    (center_x, center_y + pattern_size),
                    (center_x - pattern_size, center_y)
                ]
                draw.polygon(points, fill=(255, 255, 255, 15))
    
    # Create main container with advanced styling
    container_margin = margin + size // 32
    draw.rounded_rectangle(
        [container_margin, container_margin, size - container_margin, size - container_margin],
        radius=corner_radius,
        fill=(75, 0, 130, 220)  # Semi-transparent indigo
    )
    
    # Add multiple border layers for depth
    border_widths = [max(3, size // 32), max(2, size // 48), max(1, size // 64)]
    border_colors = [(255, 140, 0, 200), (255, 165, 0, 150), (255, 255, 255, 100)]
    
    for i, (width, color) in enumerate(zip(border_widths, border_colors)):
        draw.rounded_rectangle(
            [container_margin - i, container_margin - i, 
             size - container_margin + i, size - container_margin + i],
            radius=corner_radius + i,
            outline=color,
            width=width
        )
    
    # Create the "TV" monogram with enhanced styling
    center_x, center_y = size // 2, size // 2 - size // 8
    letter_size = size // 4
    letter_width = max(4, size // 20)
    
    # Add glow effect for TV letters
    glow_size = letter_width + 6
    for offset in range(4, 0, -1):
        glow_alpha = 80 - (offset * 20)
        glow_color_with_alpha = (255, 140, 0, glow_alpha)
        
        # T letter glow
        draw.rectangle([
            center_x - letter_size // 2 - offset, center_y - letter_size // 4 - letter_width // 2 - offset,
            center_x + letter_size // 2 + offset, center_y - letter_size // 4 + letter_width // 2 + offset
        ], fill=glow_color_with_alpha)
        
        draw.rectangle([
            center_x - letter_width // 2 - offset, center_y - letter_size // 2 - offset,
            center_x + letter_width // 2 + offset, center_y + letter_size // 2 + offset
        ], fill=glow_color_with_alpha)
        
        # V letter glow
        v_start_x = center_x + letter_size // 6
        v_start_y = center_y - letter_size // 4
        v_end_x = center_x + letter_size // 2
        v_end_y = center_y + letter_size // 2
        
        for i in range(glow_size):
            draw.line([
                v_start_x + i - offset, v_start_y - offset,
                v_end_x - letter_size // 4, v_end_y - letter_width // 2 + i - offset
            ], fill=glow_color_with_alpha, width=1)
            
            draw.line([
                v_end_x - letter_size // 4, v_end_y - letter_width // 2 + i - offset,
                v_end_x + i - offset, v_start_y - offset
            ], fill=glow_color_with_alpha, width=1)
    
    # Draw main "T" letter with gradient effect
    # T horizontal line
    for i in range(letter_width):
        alpha = 255 - (i * 15)
        color = (255, 165, 0, alpha)
        draw.rectangle([
            center_x - letter_size // 2, center_y - letter_size // 4 - letter_width // 2 + i,
            center_x + letter_size // 2, center_y - letter_size // 4 + letter_width // 2 + i
        ], fill=color)
    
    # T vertical line
    for i in range(letter_width):
        alpha = 255 - (i * 15)
        color = (255, 165, 0, alpha)
        draw.rectangle([
            center_x - letter_width // 2 + i, center_y - letter_size // 2,
            center_x + letter_width // 2 + i, center_y + letter_size // 2
        ], fill=color)
    
    # Draw main "V" letter with gradient effect
    v_start_x = center_x + letter_size // 6
    v_start_y = center_y - letter_size // 4
    v_end_x = center_x + letter_size // 2
    v_end_y = center_y + letter_size // 2
    
    for i in range(letter_width):
        alpha = 255 - (i * 15)
        color = (255, 140, 0, alpha)
        
        # Left diagonal of V
        draw.line([
            v_start_x + i, v_start_y,
            v_end_x - letter_size // 4, v_end_y - letter_width // 2 + i
        ], fill=color, width=1)
        
        # Right diagonal of V
        draw.line([
            v_end_x - letter_size // 4, v_end_y - letter_width // 2 + i,
            v_end_x + i, v_start_y
        ], fill=color, width=1)
    
    # Add "TechVerse" text below the TV logo
    text_y = center_y + letter_size + size // 16
    
    # Try to use a system font, fallback to default
    try:
        font_size = max(8, size // 12)
        font = ImageFont.truetype("arial.ttf", font_size)
    except:
        try:
            font = ImageFont.load_default()
        except:
            font = None
    
    # Add text glow effect
    for offset in range(3, 0, -1):
        glow_alpha = 100 - (offset * 30)
        text_glow_color = (255, 140, 0, glow_alpha)
        
        if font:
            # Get text bounding box
            bbox = draw.textbbox((0, 0), "TechVerse", font=font)
            text_width = bbox[2] - bbox[0]
            text_x = (size - text_width) // 2
            
            # Draw glow
            for dx in range(-offset, offset + 1):
                for dy in range(-offset, offset + 1):
                    if dx != 0 or dy != 0:
                        draw.text((text_x + dx, text_y + dy), "TechVerse", 
                                font=font, fill=text_glow_color)
    
    # Draw main text
    if font:
        bbox = draw.textbbox((0, 0), "TechVerse", font=font)
        text_width = bbox[2] - bbox[0]
        text_x = (size - text_width) // 2
        draw.text((text_x, text_y), "TechVerse", font=font, fill=text_color)
    else:
        # Fallback: draw text manually
        text_x = size // 4
        draw.text((text_x, text_y), "TechVerse", fill=text_color)
    
    # Add advanced tech elements - circuit patterns
    circuit_dot_size = max(2, size // 40)
    circuit_dots = [
        (center_x - letter_size, center_y - letter_size // 2),
        (center_x + letter_size, center_y - letter_size // 2),
        (center_x - letter_size // 2, center_y + letter_size // 2),
        (center_x + letter_size // 2, center_y + letter_size // 2),
        (center_x - letter_size // 3, center_y - letter_size // 3),
        (center_x + letter_size // 3, center_y - letter_size // 3),
        (center_x - letter_size // 4, center_y + letter_size // 4),
        (center_x + letter_size // 4, center_y + letter_size // 4)
    ]
    
    for dot_x, dot_y in circuit_dots:
        if 0 <= dot_x < size and 0 <= dot_y < size:
            # Outer glow
            draw.ellipse([
                dot_x - circuit_dot_size - 3, dot_y - circuit_dot_size - 3,
                dot_x + circuit_dot_size + 3, dot_y + circuit_dot_size + 3
            ], fill=(255, 140, 0, 100))
            
            # Main dot
            draw.ellipse([
                dot_x - circuit_dot_size, dot_y - circuit_dot_size,
                dot_x + circuit_dot_size, dot_y + circuit_dot_size
            ], fill=highlight_color)
    
    # Add connecting lines between circuit dots
    if len(circuit_dots) >= 4:
        line_color = (255, 140, 0, 150)
        # Horizontal connections
        draw.line([circuit_dots[0][0], circuit_dots[0][1], circuit_dots[1][0], circuit_dots[1][1]], 
                 fill=line_color, width=1)
        draw.line([circuit_dots[2][0], circuit_dots[2][1], circuit_dots[3][0], circuit_dots[3][1]], 
                 fill=line_color, width=1)
        # Diagonal connections
        draw.line([circuit_dots[4][0], circuit_dots[4][1], circuit_dots[5][0], circuit_dots[5][1]], 
                 fill=line_color, width=1)
        draw.line([circuit_dots[6][0], circuit_dots[6][1], circuit_dots[7][0], circuit_dots[7][1]], 
                 fill=line_color, width=1)
    
    # Add subtle highlight overlay
    highlight_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    highlight_draw = ImageDraw.Draw(highlight_img)
    
    # Top highlight
    highlight_draw.ellipse([
        size // 6, size // 12, size * 5 // 6, size // 3
    ], fill=(255, 255, 255, 25))
    
    # Apply highlight
    img = Image.alpha_composite(img, highlight_img)
    
    # Add final border glow
    final_glow_width = max(2, size // 48)
    for i in range(final_glow_width):
        alpha = 120 - (i * 40)
        glow_color = (255, 140, 0, alpha)
        draw.rounded_rectangle(
            [margin - i, margin - i, size - margin + i, size - margin + i],
            radius=corner_radius + i,
            outline=glow_color,
            width=1
        )
    
    # Save the image
    img.save(output_path, 'PNG')
    print(f"Created named TechVerse icon: {output_path} ({size}x{size})")

def main():
    """Create all required Android icon densities with app name"""
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
        create_named_techverse_icon(size, output_path)
    
    print("All named TechVerse Android app icons created successfully!")
    print("New features included:")
    print("- 'TechVerse' app name integrated")
    print("- Orange/Brown color scheme")
    print("- Enhanced geometric patterns")
    print("- Improved typography")
    print("- Advanced glow effects")
    print("- Professional tech aesthetic")

if __name__ == "__main__":
    main()

