# Photo Indexer with Thumbnails 👀

This Ruby script automatically generates an HTML index page that displays thumbnails of all images in a specified folder. It's perfect for quickly browsing your photo collection! 📸

## Features 🌈

- Creates a `thumbs` directory for thumbnails.
- Creates thumbnails with 1200x1200 pixels using ImageMagick.
- Sanitizes image filenames for URI compatibility. (Be careful, it will rename your original files!)
- Uses Bootstrap for styling.

## Requirements 🛠️

- Ruby installed
- ImageMagick installed
- Bootstrap 5.x (CDN linked)

## Usage 🚀

1. Place the script in a folder containing the images.
2. Run `ruby your_script_name.rb`.

Or use an Bash alias:

```bash
generate-index: aliased to ruby ~/chatgpt-scripts/gallery-generator/gallery.rb
```

Voila! An `index.html` file is generated. Open it in a browser to view the image thumbnails. 🌟

That's it! Simple as pie! 🥧
