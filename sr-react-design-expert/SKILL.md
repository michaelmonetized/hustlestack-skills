---
name: sr-react-design-expert
description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, or applications. Generates creative, polished code that avoids generic AI aesthetics.
---

> **Global Standards:** See [../STANDARDS.md](../STANDARDS.md) for icon library and other cross-platform standards.

# Frontend Design

Create distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Implement real working code with exceptional attention to aesthetic details and creative choices.

## Michael's Preferences (Override Everything)

These are non-negotiable personal preferences that supersede other guidelines:

### BANNED DEFAULT AESTHETICS
Never use these 5 together as a set — they're overused AI defaults:
- Minimal Editorial (magazine-style, serif, whitespace)
- Bold & Playful (vibrant, rounded, energetic)  
- Mountain Modern (dark, topo patterns, adventure)
- Warm Community (earthy, hand-drawn, cozy)
- Tech Forward (glassmorphism, gradients, SaaS)

**Use the 100 aesthetics in `references/aesthetics-library.md` instead.** Pick from DIFFERENT CATEGORIES.

### PHOTOS ARE MANDATORY
- Never use placeholder images or generic icons as hero content
- Source photos from: `~/Projects/www.hustlelaunch.com/public/assets/images/`
- Source photos from: `~/Cloud/Projects/**/Photos/`
- Source photos from: project's own `/public/images/`
- If no photos exist, CREATE the image directory and note which images are needed

### LEAD-GEN BUSINESS MODEL (for directory/listing sites)
Sites like bestwnc.com exist to:
1. **Get free listings** — make it dead simple to list a business for free
2. **Sell upgrades** — placement priority, featured spots, premium badges, ad slots
3. **Collect leads** — capture business owner info to sell them:
   - Marketing services (HustleLaunch)
   - Website redesigns (Cravees, HurleyUS)
   - SEO packages
4. **Drive local discovery** — the directory must feel useful to end users too

**Every design must include:**
- Clear "List Your Business FREE" CTA (primary action)
- "Upgrade Your Listing" or "Get Featured" secondary CTAs
- Trust signals (# of businesses listed, happy testimonials)
- Email capture or contact form
- Local community vibe — this isn't a sterile SaaS

### VISUAL PREFERENCES
- **Dark mode by default** — light mode secondary
- **High contrast** — readable text, not washed out
- **No pure black** — use rich dark tones (slate-950, zinc-950, neutral-950)
- **Photos over illustrations** — real beats illustrated
- **Bold typography** — display fonts that make a statement
- **Avoid sameness** — each project should feel distinct

## Stack Context

This skill targets the HustleStack:

| Layer | Tech | Notes |
|-------|------|-------|
| Framework | Next.js 16+ (App Router) | Use `Image`, `Link`, metadata API |
| Styling | Tailwind CSS v4 | `@theme` block, no `tailwind.config` |
| Components | shadcn/ui + Radix UI | New York variant, extend don't replace |
| Icons | Phosphor (`@phosphor-icons/react`) | Light weight only |
| Animation | CSS-first, Embla Carousel | No Framer Motion unless already installed |

When working in an existing project, read the layout, globals.css, and component library before designing. Match the established patterns.

## Design Thinking

Before coding, answer these questions:

1. **What is this?** — Marketing page, dashboard, form, settings panel, landing page?
2. **Who sees it?** — First-time visitor, returning user, admin?
3. **What should they feel?** — Trust, excitement, urgency, calm, delight?
4. **What's the one action?** — Every page has a primary action. Design toward it.

Then commit to a clear aesthetic direction and execute with precision. Bold maximalism and refined minimalism both work — the key is intentionality, not intensity.

### Direction by Context

| Context | Direction | Why |
|---------|-----------|-----|
| Landing/Marketing | Bold, atmospheric, high-contrast | First impression, brand recall |
| Dashboard/App | Clean, structured, information-dense | Daily-use clarity |
| Forms | Focused, minimal, guided | Reduce friction |
| Content/Blog | Editorial, typographic, readable | Content is the design |
| Error/Empty states | Warm, helpful, on-brand | Don't break immersion |

## Design Rules

These rules override aesthetic preferences. They are non-negotiable.

### Buttons
- **Content-width only** — never `w-full` on buttons
- **Solid backgrounds** — no gradients on buttons
- **Right-align submit buttons** — bottom-right of forms and panels

### Cards
- Title in `<CardHeader>`
- Image + description in `<CardContent>`
- No `rounded-*` on images inside cards — the card handles border radius
- Use `overflow-hidden` on containers, not `rounded-*` on images

### Forms
- **2-column layout** — description/pitch on the left, fields on the right
- Submit button: bottom-right aligned

### Layout
- Follow established UX conventions over trendy styling
- When in doubt, conventional beats clever

## Aesthetics Selection (MANDATORY)

**Read `references/aesthetics-library.md` before designing.**

When asked for multiple variants:
1. Select from DIFFERENT CATEGORIES — never 5 from the same section
2. Match aesthetic to client industry and audience
3. Consider competitor differentiation
4. Test both light AND dark modes

**100 aesthetics organized into 7 categories:**
1. Editorial & Publishing (1-10)
2. Tech & SaaS (11-25)
3. Luxury & High-End (26-40)
4. Creative & Agency (41-55)
5. Cultural & Arts (56-70)
6. Retro & Nostalgic (71-85)
7. Experimental & Avant-Garde (86-100)

## Typography

Choose fonts that serve the design. For standalone projects, pair a distinctive display font with a clean body font.

**Good font choices** (vary between projects):
- Display: Playfair Display, Clash Display, Cabinet Grotesk, Instrument Serif, Syne, General Sans, Satoshi
- Body: DM Sans, Plus Jakarta Sans, Source Serif 4, Outfit, Manrope

**Avoid converging** on the same font across projects.

## Color & Theme

Commit to a cohesive palette. Use CSS variables for consistency.

- Dominant color with sharp accents outperforms evenly-distributed palettes
- Dark themes: avoid pure black (#000) — use rich dark tones
- Light themes: avoid pure white (#fff) backgrounds for large surfaces
- Accent colors should appear in 2-3 places max

## Motion

Prioritize CSS-only animations.

**High-impact moments:**
- Page load: staggered reveals with `@keyframes` and `animation-delay`
- Scroll: IntersectionObserver-based reveals
- Hover: subtle transforms and color shifts

**Skip:**
- Parallax everywhere
- Bouncing distractions
- Loading spinners (use skeletons)

## Working with shadcn/ui

**Extend, don't fight:**
- Use `cn()` to merge custom classes
- Override via Tailwind — don't fork components
- Use CVA variants for multiple visual modes

## Accessibility

Non-negotiable:
- Semantic HTML (`nav`, `main`, `section`, `article`)
- Proper heading hierarchy (one `h1`, sequential h2→h3→h4)
- Alt text on all images
- Keyboard navigation with visible focus rings
- WCAG AA contrast (4.5:1 body, 3:1 large)
- ARIA labels on icon-only buttons

## Anti-Patterns

**Generic AI output:**
- Cookie-cutter hero → heading → 3-card grid → CTA → footer
- Purple-to-blue gradients on white
- Evenly-spaced sections with identical padding
- Placeholder text that wasn't replaced
- NO PHOTOS

**Implementation mistakes:**
- `w-full` buttons
- Gradient button backgrounds
- `rounded-*` on images inside cards
- Centered submit buttons
- Hardcoded colors

## Pre-Flight Checklist

- [ ] Has real photos, not placeholders
- [ ] Renders without console errors
- [ ] Responsive at 375px, 768px, 1024px, 1440px
- [ ] Keyboard navigable
- [ ] Color contrast passes WCAG AA
- [ ] Images have alt text
- [ ] No `w-full` buttons, no gradient buttons
- [ ] Dark/light theme both work
- [ ] Lead-gen CTAs are prominent (if applicable)
- [ ] No banned aesthetic combinations

## Related Skills

- `/sr-production-engineer` — PR workflow after implementation
- `/sr-software-architect` — architectural changes
