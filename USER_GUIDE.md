# OXO Menus - User Guide

Welcome to OXO Menus! This guide will help you create beautiful, customizable menu templates and generate professional PDF menus.

## Table of Contents

1. [Getting Started](#getting-started)
2. [User Roles](#user-roles)
3. [Creating Your First Menu](#creating-your-first-menu)
4. [Working with Templates](#working-with-templates)
5. [Widget System](#widget-system)
6. [Styling Your Menu](#styling-your-menu)
7. [Generating PDFs](#generating-pdfs)
8. [Tips and Best Practices](#tips-and-best-practices)

---

## Getting Started

### Accessing OXO Menus

1. Open your web browser
2. Navigate to the OXO Menus application (e.g., http://localhost:8080)
3. Log in with your credentials

**First Time Login**:
- Contact your administrator for credentials
- Change your password after first login

### Dashboard Overview

After logging in, you'll see the dashboard with:
- **Quick Actions**: Create menu, browse templates
- **Recent Menus**: Your recently edited menus
- **Template Library**: Available templates (regular users see published templates only)

---

## User Roles

### Regular User

**Can do**:
- Browse and select published templates
- Create menus from templates
- Add and edit widgets (dishes, sections, text, images)
- Customize menu styling (colors, fonts)
- Generate PDF menus
- Save and manage personal menus

**Cannot do**:
- Modify template structure (pages, containers, columns)
- Create new templates
- Create custom widget types
- See draft templates

### Admin User

**Can do everything regular users can, plus**:
- Create and edit menu templates
- Define template structure (pages, containers, columns)
- Publish/unpublish templates
- Create custom widget types
- Manage all users' menus
- Configure system-wide settings

---

## Creating Your First Menu

### Step 1: Choose a Template

1. From the dashboard, click **"Create Menu"**
2. Browse available templates
3. Preview templates by clicking on them
4. Click **"Use This Template"** on your chosen template

### Step 2: Name Your Menu

1. Enter a name for your menu (e.g., "Summer Lunch Menu 2024")
2. Optionally add a description
3. Click **"Create"**

### Step 3: Add Widgets

The menu editor shows:
- **Left Panel**: Widget palette with available widget types
- **Center**: Canvas showing your menu pages
- **Right Panel**: Properties and styling options

**To add a widget**:
1. Drag a widget from the palette (e.g., "Dish")
2. Drop it into a column on the canvas
3. The widget appears with default content

### Step 4: Edit Widget Content

**Click on any widget to edit it**:

#### Dish Widget
- **Name**: The dish name (e.g., "Grilled Salmon")
- **Price**: Price in your currency
- **Description**: Optional description
- **Allergens**: Comma-separated list (e.g., "Fish, Dairy")
- **Dietary**: Tags like "Gluten-Free", "Vegan"
- **Show Price**: Toggle to hide/show price
- **Show Allergens**: Toggle to hide/show allergen chips

#### Section Widget
- **Title**: Section heading (e.g., "APPETIZERS")
- **Uppercase**: Convert title to uppercase
- **Show Divider**: Add a line under the title

#### Text Widget
- **Text**: Your custom text
- **Alignment**: Left, Center, or Right
- **Bold**: Make text bold
- **Italic**: Italicize text

#### Image Widget
- **URL**: Image URL or upload
- **Alt Text**: Description for accessibility
- **Height**: Image height in pixels
- **Fit**: Cover, Contain, or Fill

### Step 5: Reorder Widgets

**To reorder widgets**:
1. Click and hold on a widget
2. Drag it to the desired position
3. Drop it between other widgets or in a different column

### Step 6: Save Your Menu

1. Click **"Save"** in the top toolbar
2. Your menu is saved automatically
3. You can continue editing anytime

---

## Working with Templates

### Understanding Template Structure

Templates define the layout structure:
- **Pages**: Multiple pages (e.g., page 1 for appetizers, page 2 for mains)
- **Containers**: Horizontal sections on a page
- **Columns**: Vertical divisions within containers
- **Widgets**: Content you add (dishes, text, etc.)

**Example Structure**:
```
Menu
 └─ Page 1
     ├─ Container 1 (Header)
     │   └─ Column 1 (Full width)
     │       └─ [Your widgets here]
     └─ Container 2 (Main Content)
         ├─ Column 1 (50% width)
         │   └─ [Your widgets here]
         └─ Column 2 (50% width)
             └─ [Your widgets here]
```

**Note**: Regular users cannot change this structure - it's defined by the template.

### Selecting the Right Template

Consider:
- **Number of columns**: Single column for simple menus, multi-column for extensive menus
- **Page count**: One page for short menus, multiple pages for categories
- **Style**: Formal, casual, modern, classic
- **Purpose**: Restaurant menu, catering menu, event menu

### Template Preview

Before selecting a template:
1. Click the template card
2. View the full preview
3. Check page structure and layout
4. Click **"Use This Template"** or **"Cancel"**

---

## Widget System

### Available Widget Types

#### 1. Dish Widget

**Best for**: Menu items with prices, descriptions, and dietary information

**Fields**:
- Name (required)
- Price (required)
- Description (optional)
- Allergens (optional, comma-separated)
- Dietary tags (optional, comma-separated)
- Display toggles (show price, show allergens)

**Example**:
```
Grilled Atlantic Salmon          $28.00
Fresh salmon fillet with seasonal vegetables
[Fish] [Dairy]
[Gluten-Free]
```

#### 2. Section Widget

**Best for**: Category headers and dividers

**Fields**:
- Title (required)
- Uppercase option
- Divider option

**Example**:
```
─────────────────────────────────
       MAIN COURSES
─────────────────────────────────
```

#### 3. Text Widget

**Best for**: Custom descriptions, notes, disclaimers

**Fields**:
- Text content
- Alignment (left/center/right)
- Bold option
- Italic option

**Example**:
```
All dishes are prepared fresh daily.
Please inform staff of any allergies.
```

#### 4. Image Widget

**Best for**: Logos, photos, decorative elements

**Fields**:
- Image URL
- Alt text
- Height
- Fit mode

### Widget Best Practices

**Dish Widgets**:
- Keep names concise but descriptive
- Include key ingredients in description
- List major allergens
- Use consistent pricing format

**Section Widgets**:
- Use clear category names
- Keep consistent capitalization
- Consider visual hierarchy

**Text Widgets**:
- Use for disclaimers and notes
- Keep text brief
- Use formatting sparingly

**Image Widgets**:
- Use high-quality images (at least 800px wide)
- Optimize images for web (keep file size < 500KB)
- Provide descriptive alt text

---

## Styling Your Menu

### Global Styling

Click **"Styles"** in the toolbar to access global menu styling:

#### Typography
- **Font Family**: Choose from available fonts
- **Base Font Size**: Default text size (affects all widgets)
- **Primary Color**: Main brand color
- **Secondary Color**: Accent color
- **Background Color**: Page background

#### Spacing
- **Margin Top/Bottom**: Page margins
- **Margin Left/Right**: Page side margins
- **Padding**: Space around content

#### Page Settings
- **Page Size**: A4, Letter, Custom
- **Custom Width/Height**: For custom sizes (in mm)

### Widget-Specific Styling

Each widget can have individual styling overrides:

1. Select a widget
2. Click **"Widget Styles"** in the properties panel
3. Adjust:
   - Font size
   - Font color
   - Background color
   - Padding
   - Border

**Note**: Widget styles override global styles

### Style Tips

**Professional Look**:
- Use 2-3 colors maximum
- Maintain consistent spacing
- Choose readable fonts
- Keep font sizes appropriate (body: 12-14pt, headings: 16-20pt)

**Brand Consistency**:
- Use your brand colors
- Match your existing marketing materials
- Include your logo (use Image widget)

**Readability**:
- Ensure good contrast (dark text on light background or vice versa)
- Avoid overly decorative fonts for body text
- Use adequate spacing between sections

---

## Generating PDFs

### Creating a PDF

1. Open your menu in the editor
2. Click **"Generate PDF"** in the toolbar
3. Wait for PDF generation (usually 2-5 seconds)
4. PDF preview appears in a dialog

### PDF Preview

In the preview dialog:
- **Zoom**: Use zoom controls to inspect details
- **Pages**: Navigate between pages
- **Download**: Save PDF to your computer
- **Print**: Send directly to printer

### Downloading Your PDF

1. In the preview dialog, click **"Download"**
2. Choose save location
3. File is saved as `menu_YYYY-MM-DD_HH-MM-SS.pdf`

### Printing Your PDF

**Option 1: Direct Print**
1. In the preview dialog, click **"Print"**
2. Select your printer
3. Adjust print settings (quality, paper size)
4. Print

**Option 2: Download and Print Later**
1. Download the PDF
2. Open in Adobe Reader, Preview, or browser
3. Print using your preferred method

### PDF Quality Tips

**For Best Results**:
- Use vector logos (SVG) when possible
- Ensure images are high resolution
- Preview PDF before printing
- Test print one page first
- Use proper paper size setting

**Common Issues**:
- **Colors look different**: Screens use RGB, printers use CMYK. Colors may vary.
- **Text too small**: Increase base font size in global styles
- **Images blurry**: Use higher resolution images (300 DPI recommended)

---

## Tips and Best Practices

### Menu Organization

**Single-Column Menus**:
- Best for simple menus (< 20 items)
- Easy to read top-to-bottom
- Good for mobile viewing

**Multi-Column Menus**:
- Best for extensive menus (> 20 items)
- Space-efficient
- Professional appearance
- Use for categorized menus

**Multi-Page Menus**:
- One page per category (appetizers, mains, desserts)
- Easier to navigate
- Suitable for formal dining

### Content Guidelines

**Dish Names**:
- Be descriptive but concise
- Capitalize key words
- Avoid abbreviations
- Include preparation method if relevant

**Descriptions**:
- Highlight key ingredients
- Mention cooking style
- Keep under 20 words
- Focus on appeal, not instructions

**Pricing**:
- Be consistent with format ($12.00 vs $12 vs 12.00)
- Consider price psychology (e.g., $19.99 vs $20.00)
- Update regularly
- Show currency symbol

**Allergens**:
- List major allergens (dairy, nuts, gluten, fish, shellfish)
- Use standard names
- Keep updated
- Consider legal requirements

### Workflow Efficiency

**Save Frequently**:
- Auto-save every 30 seconds
- Manual save with Ctrl+S (Cmd+S on Mac)
- Version history available (admin only)

**Duplicate Widgets**:
- Click widget → "Duplicate"
- Faster than adding new widgets
- Maintains styling

**Template Switching**:
- Start with similar template
- Less manual adjustment needed

**Keyboard Shortcuts**:
- `Ctrl+S` / `Cmd+S`: Save
- `Ctrl+Z` / `Cmd+Z`: Undo
- `Ctrl+Y` / `Cmd+Y`: Redo
- `Delete`: Remove selected widget
- `Arrow Keys`: Navigate widgets

### Seasonal Updates

**Quarterly Review**:
- Update seasonal dishes
- Adjust prices
- Refresh descriptions
- Check for outdated items

**Version Control**:
- Save menu versions (e.g., "Summer 2024", "Winter 2024")
- Keep old versions for reference
- Easy rollback if needed

### Accessibility

**Make Menus Accessible**:
- Use sufficient color contrast
- Provide text alternatives for images
- Use readable font sizes
- Clear section headers
- Logical reading order

### Common Mistakes to Avoid

❌ **Don't**:
- Overcrowd pages
- Use too many fonts
- Neglect allergen information
- Forget to save
- Use low-quality images
- Make text too small
- Ignore brand guidelines

✅ **Do**:
- Leave white space
- Maintain consistency
- Update regularly
- Test print before bulk printing
- Get feedback from others
- Keep backups
- Follow legal requirements

---

## Troubleshooting

### I Can't Find a Widget

**Solution**:
- Check if you're on the correct page
- Use widget search (if available)
- Check if widget was accidentally deleted
- Restore from auto-save

### PDF Looks Different from Screen

**Why**: Screens use RGB colors, PDFs use CMYK for printing

**Solution**:
- Preview PDF before printing
- Adjust colors in global styles
- Test print one page
- Use web-safe colors

### My Changes Aren't Saving

**Possible Causes**:
- Network connection lost
- Session expired
- Browser issue

**Solution**:
1. Check internet connection
2. Refresh page (changes may auto-save)
3. Log out and log back in
4. Clear browser cache
5. Contact administrator if persistent

### Widget Won't Move

**Solution**:
- Ensure you're in edit mode
- Check if widget is locked (admin feature)
- Try refreshing page
- Contact support if issue persists

### Image Not Displaying

**Possible Causes**:
- Invalid URL
- Image file too large
- Unsupported format

**Solution**:
- Verify URL is correct and accessible
- Compress image (recommended < 500KB)
- Use supported formats (JPG, PNG, SVG)
- Check image permissions

---

## Getting Help

### In-App Help

- **Help Icon** (?) in toolbar: Context-sensitive help
- **Tooltips**: Hover over buttons for quick info
- **Tutorial**: First-time user walkthrough

### Support Channels

- **User Manual**: This document
- **Video Tutorials**: (if available)
- **Administrator**: Contact your system admin
- **Email Support**: support@example.com (if configured)

### Reporting Issues

When reporting problems, include:
1. What you were trying to do
2. What happened instead
3. Screenshots (if applicable)
4. Your browser and version
5. Steps to reproduce the issue

---

## Appendix

### Keyboard Shortcuts Reference

| Action | Windows/Linux | macOS |
|--------|---------------|-------|
| Save | Ctrl + S | Cmd + S |
| Undo | Ctrl + Z | Cmd + Z |
| Redo | Ctrl + Y | Cmd + Y |
| Delete Widget | Delete | Delete |
| Duplicate Widget | Ctrl + D | Cmd + D |
| Select All | Ctrl + A | Cmd + A |
| Find | Ctrl + F | Cmd + F |

### Supported Browsers

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

### Supported Page Sizes

| Size | Dimensions (mm) | Use Case |
|------|----------------|----------|
| A4 | 210 × 297 | International standard |
| Letter | 215.9 × 279.4 | US standard |
| Legal | 215.9 × 355.6 | US legal |
| Tabloid | 279.4 × 431.8 | Large menus |
| Custom | User-defined | Special requirements |

---

**Version**: 1.0.0
**Last Updated**: January 2024

For the latest version of this guide, visit your OXO Menus installation.
