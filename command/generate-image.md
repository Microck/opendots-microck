---
description: Generate images using Gemini 3 Pro Image model
---

Use the `generate_image` tool to create images from text prompts.

## Basic Usage
```
generate_image({ prompt: "A futuristic city at sunset" })
```

## Options
- `prompt` (required): Description of the image to generate
- `aspect_ratio`: "1:1" (default), "16:9", "9:16", "3:4", "4:3", etc.
- `file_name`: Custom filename (without extension)
- `input_image`: Path to an existing image for editing
- `count`: Number of images to generate (1-4, default: 1)
- `output_path`: Custom directory for saving images
- `session_id`: For character consistency across generations

## Examples

### Generate a single image
```
generate_image({ 
  prompt: "A cyberpunk cat in neon-lit Tokyo streets",
  aspect_ratio: "16:9"
})
```

### With custom filename
```
generate_image({
  prompt: "A majestic dragon",
  file_name: "my-dragon"
})
```

### Edit an existing image
```
generate_image({
  prompt: "Change the sky to a beautiful sunset",
  input_image: "./my-photo.jpg"
})
```

### Generate multiple variations
```
generate_image({
  prompt: "A majestic dragon flying over mountains",
  count: 4
})
```

### Maintain character consistency
```
generate_image({
  prompt: "Create a hero character named Luna",
  session_id: "luna-character"
})
// Then continue with the same session
generate_image({
  prompt: "Show Luna fighting a dragon",
  session_id: "luna-character"
})
```

Images are saved to `.opencode/generated-images/` in your project by default.

IMPORTANT: Display the tool output EXACTLY as it is returned. Do not summarize or reformat.
