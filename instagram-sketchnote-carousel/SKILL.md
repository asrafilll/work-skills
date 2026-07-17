---
name: instagram-sketchnote-carousel
description: 'Create complete 1080x1350 educational Instagram carousels as separate editorial sketchnote images. Use when the user asks for an Instagram carousel, infographic carousel, visual explainer slides, or hand-drawn educational social posts. Unlike general image generation, this skill plans the minimum slide sequence and enforces one reusable visual system plus mobile-readability QA.'
---

# Instagram Sketchnote Carousel

Turn a topic and any supplied source material into a coherent, beginner-friendly Instagram carousel. Produce finished images, not merely a plan or prompt pack.

## Output Contract

- Generate each slide as a separate 1080x1350 px image in 4:5 portrait format.
- Use the fewest slides needed. Never exceed seven.
- Deliver the images in reading order. Do not create a contact sheet.
- Do not include slide numbers, names, logos, handles, watermarks, or footers.
- Keep the bottom 12%—the final 162 px—completely empty for Figma editing.

## Visual System

Repeat the same visual language on every slide:

- Warm-white `#FFFCF5` canvas. This is the only background-color exception to the palette below.
- Black `#111111` hand-drawn ink outlines and primary text.
- Blue `#2563EB` labels, arrows, and small accents.
- Yellow `#FACC15` marker highlights for key phrases.
- Green `#86D36B` only for positive takeaways.
- Red `#EF4444` only for warnings or failure states.
- Light gray `#D1D5DB` only for thin dashed dividers and quiet structure.
- Bold uppercase titles resembling Permanent Marker.
- Neat supporting text resembling Patrick Hand.
- Rounded information cards, simple technical doodles, minimal shading, and generous whitespace.

Do not use gradients, photorealism, 3D, neon, glossy UI, complex textures, stock imagery, or cartoon-heavy styling. Do not introduce other accent colors.

## Fixed Layout Rules

- Keep all meaningful content inside an 80 px left/right margin.
- Place the top title region consistently across like slides.
- Keep all content above y=1188 px; the area from y=1188 through y=1350 must remain blank.
- Maintain at least 35% whitespace.
- Prefer one large explanatory illustration over clusters of small icons.
- Use no more than three information cards or six short bullets on one slide.
- Keep bullets under eight words when possible and paragraphs under two lines.
- Never shrink text to make content fit. Simplify the copy or add a slide.

## Workflow

### 1. Establish the lesson

Read the topic and supplied sources. Write one internal learning objective for a beginner audience. If the topic is broad, narrow it to the most useful teachable idea that still answers the request.

Use supplied sources as the factual baseline. Verify current, niche, medical, legal, financial, or technical claims with authoritative sources when tools are available. Never invent a claim to fill a slide.

### 2. Check generation capability

Confirm that an image-generation tool is available and can create or edit portrait images. If it is unavailable, state the limitation instead of pretending images were generated.

### 3. Plan the minimum sequence

Plan the sequence internally before generating anything:

1. Cover: topic and hook.
2. Content: one main idea per slide in the clearest teaching order.
3. Final content slide: conclusion, practical takeaway, or warning only when the lesson needs one.

Remove repeated or secondary material. Use between two and seven slides, including the cover, and stop as soon as the learning objective is complete.

### 4. Lock the copy

Write the exact text for every slide before image generation. Check spelling, terminology, and reading order. Use short, concrete lines that remain readable on a phone.

Cover slides contain only:

- One large carousel title.
- One short hook or subtitle.
- One large focal doodle illustration.
- Minimal supporting marks and no explanation cards.

Content slides contain:

- A small repeated series title at the top.
- One large concept title.
- One concise definition.
- One large explanatory visual.
- Two or three short supporting points.
- An optional one-sentence takeaway.

### 5. Generate separate slides

Generate one image per slide. Reuse the complete visual-system and fixed-layout constraints in every generation prompt; do not rely on shorthand such as “same style.” Include the exact slide copy and instruct the generator to reproduce it verbatim.

When the tool supports visual references, use the approved cover as a style reference for later slides while still repeating all constraints in text. Preserve the same canvas, margins, title scale, line weight, color meanings, card radius, illustration style, spacing, and empty footer zone.

### 6. Inspect and repair

Inspect every rendered slide individually and then inspect the sequence as a set. Verify:

- Exact 1080x1350 dimensions and 4:5 orientation.
- Correct spelling and verbatim slide copy.
- Large, legible mobile text with no clipped elements.
- No slide numbers, identities, logos, handles, watermarks, or footer content.
- The final 162 px are empty.
- At least 35% whitespace and acceptable density.
- Palette roles, typography, line weight, margins, and card shapes remain consistent.
- Green appears only for positives and red only for warnings.
- The teaching sequence is accurate, non-repetitive, and complete.

Edit or regenerate each failed slide, then inspect it again. Do not deliver a slide with malformed text, cropped content, style drift, or a violated footer safe zone.

## Delivery

Return only the completed slide images in carousel order unless the user asks for supporting copy or rationale. Do not add slide numbers or combine the images after generation.
