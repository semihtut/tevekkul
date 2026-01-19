#!/usr/bin/env python3
"""Generate QalbHz app icon with EKG heartbeat design"""

from PIL import Image, ImageDraw
import os

def create_ekg_icon(size, output_path):
    """Create an EKG-style icon"""
    # Create image with teal gradient background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Background - rounded rectangle with gradient effect
    padding = size // 8
    corner_radius = size // 4

    # Draw rounded rectangle background
    # Teal color: #0D9488
    bg_color = (13, 148, 136, 255)

    # Create rounded rectangle
    draw.rounded_rectangle(
        [(padding//2, padding//2), (size - padding//2, size - padding//2)],
        radius=corner_radius,
        fill=bg_color
    )

    # Draw EKG line
    line_color = (255, 255, 255, 255)
    line_width = max(2, size // 40)

    # Calculate EKG path points
    center_y = size // 2
    margin = size // 6

    # EKG pattern points (normalized to 0-1, then scaled)
    points = [
        (0.0, 0.5),      # Start
        (0.2, 0.5),      # Flat line
        (0.25, 0.45),    # Small P wave up
        (0.3, 0.5),      # Back to baseline
        (0.35, 0.5),     # Flat
        (0.4, 0.6),      # Q wave down
        (0.45, 0.15),    # R wave spike UP (main peak)
        (0.5, 0.75),     # S wave down
        (0.55, 0.5),     # Back to baseline
        (0.65, 0.5),     # Flat
        (0.7, 0.38),     # T wave up
        (0.8, 0.5),      # Back to baseline
        (1.0, 0.5),      # End
    ]

    # Scale points to image size
    scaled_points = []
    for px, py in points:
        x = margin + px * (size - 2 * margin)
        y = margin + py * (size - 2 * margin)
        scaled_points.append((x, y))

    # Draw the EKG line with anti-aliasing effect
    for i in range(len(scaled_points) - 1):
        x1, y1 = scaled_points[i]
        x2, y2 = scaled_points[i + 1]
        draw.line([(x1, y1), (x2, y2)], fill=line_color, width=line_width)

    # Add small circles at key points for smoothness
    circle_radius = line_width // 2
    for point in scaled_points:
        x, y = point
        draw.ellipse(
            [(x - circle_radius, y - circle_radius),
             (x + circle_radius, y + circle_radius)],
            fill=line_color
        )

    # Save
    img.save(output_path, 'PNG')
    print(f"Created: {output_path}")

def main():
    base_path = os.path.dirname(os.path.abspath(__file__))

    # Android icon sizes
    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }

    # Generate Android icons
    for folder, size in android_sizes.items():
        output_dir = os.path.join(base_path, 'android', 'app', 'src', 'main', 'res', folder)
        os.makedirs(output_dir, exist_ok=True)
        output_path = os.path.join(output_dir, 'ic_launcher.png')
        create_ekg_icon(size, output_path)

    # iOS icon sizes
    ios_sizes = {
        'Icon-App-20x20@1x.png': 20,
        'Icon-App-20x20@2x.png': 40,
        'Icon-App-20x20@3x.png': 60,
        'Icon-App-29x29@1x.png': 29,
        'Icon-App-29x29@2x.png': 58,
        'Icon-App-29x29@3x.png': 87,
        'Icon-App-40x40@1x.png': 40,
        'Icon-App-40x40@2x.png': 80,
        'Icon-App-40x40@3x.png': 120,
        'Icon-App-60x60@2x.png': 120,
        'Icon-App-60x60@3x.png': 180,
        'Icon-App-76x76@1x.png': 76,
        'Icon-App-76x76@2x.png': 152,
        'Icon-App-83.5x83.5@2x.png': 167,
        'Icon-App-1024x1024@1x.png': 1024,
    }

    ios_dir = os.path.join(base_path, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')
    if os.path.exists(ios_dir):
        for filename, size in ios_sizes.items():
            output_path = os.path.join(ios_dir, filename)
            create_ekg_icon(size, output_path)

    print("\nApp icons generated successfully!")

if __name__ == '__main__':
    main()
