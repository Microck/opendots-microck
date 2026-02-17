---
name: catbox-upload-skill
description: Upload files to catbox.moe (permanent) or litterbox.catbox.moe (temporary). Use when you want to upload files for sharing via catbox services. Trigger phrases: "upload to catbox", "upload file", "share file via catbox".
---

# Catbox/Litterbox File Uploader

Upload files to catbox services for easy sharing and temporary storage.

## How It Works

1. Takes a file path as input
2. Checks file existence and validates arguments
3. Uploads to specified service (litterbox default or catbox)
4. Returns direct URL to uploaded file
5. Supports different expiration times for litterbox

## Usage

```bash
bash ~/.claude/skills/catbox-upload/scripts/upload.sh /path/to/file
```

**Arguments:**
- `file_path` (required) - Path to file to upload
- `--service` (optional) - Service to use: `litterbox` (default, temporary) or `catbox` (permanent)
- `--time` (optional) - Litterbox expiration: `1h`, `12h`, `24h`, `72h` (default: `24h`)
- `--userhash` (optional) - Catbox account hash (required for permanent uploads)

**Examples:**

Upload to litterbox (24h default):
```bash
bash ~/.claude/skills/catbox-upload/scripts/upload.sh ~/Documents/video.mp4
```

Upload to litterbox with 1h expiration:
```bash
bash ~/.claude/skills/catbox-upload/scripts/upload.sh ~/Documents/file.zip --time 1h
```

Upload to catbox (permanent):
```bash
bash ~/.claude/skills/catbox-upload/scripts/upload.sh ~/Documents/image.png --service catbox --userhash YOUR_HASH
```

## Output

```
https://litterbox.catbox.moe/xxxxxxxxx.mp4
```

Or for catbox:
```
https://catbox.moe/xxxxxxxxx.png?userhash=YOUR_HASH
```

## Present Results to User

When a file is successfully uploaded, present the URL to the user in this format:

```
✅ File uploaded successfully!

📤 Download link: https://litterbox.catbox.moe/xxxxxxxxx.mp4

⏰ Expires in: 24 hours

💡 Tip: Share this link with others for easy download access
```

## Troubleshooting

**File not found:**
- Verify the file path is correct
- Use absolute paths or ensure you're in the correct directory
- Check file permissions

**Upload failed:**
- Ensure you have internet connectivity
- Check if catbox services are operational
- Verify file size limits (Litterbox: 1GB, Catbox: 200MB)
- For Catbox uploads, ensure you have a valid userhash

**Python not found:**
- Ensure Python 3 is installed
- Check that `requests` library is available: `pip install requests`

**Permission denied:**
- Ensure the file is readable
- Check directory permissions

## Limits

| Service | Max Size | Duration |
|---------|----------|----------|
| Litterbox | 1 GB | 1h - 72h |
| Catbox | 200 MB | Permanent |

## Notes

- Litterbox is the default service for temporary uploads
- Catbox requires a userhash for permanent storage and tracking
- The URL returned is directly accessible and can be shared immediately
- No account creation required for Litterbox
- Catbox userhash can be obtained from catbox.moe account
