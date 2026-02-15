# Design Aesthetics Library

225 distinct design aesthetics across 25 categories for frontend implementations. Select based on project context, brand personality, and target audience — not defaults.

**Usage:** When asked for multiple design variants, SELECT FROM DIFFERENT CATEGORIES. Never repeat the same 5 aesthetics.

---

## Editorial & Publishing (1-10)

### 1. New York Times Editorial
Confident serif typography, high-contrast black/cream, dramatic pull quotes, generous line height, restrained imagery with strong photography. Grid-based with intentional breaks.
```css
--font-display: "Cheltenham", Georgia, serif;
--bg: #FAF9F7; --text: #121212; --accent: #567B95;
```

### 2. Kinfolk Lifestyle
Extreme whitespace, lowercase headings, muted earth palette, slow photography, quiet elegance. Typography is breathing room.
```css
--font: "Canela", serif; --spacing: clamp(3rem, 8vw, 8rem);
--bg: #F5F3EF; --text: #2D2D2D;
```

### 3. Bloomberg Terminal
Information-dense, data-forward, monospace accents, high-contrast color coding, dark mode default, financial severity.
```css
--font: "IBM Plex Mono", monospace;
--bg: #0D0D0D; --text: #FFFFFF; --positive: #00E676; --negative: #FF5252;
```

### 4. Vogue Fashion
Ultra-thin serifs, dramatic scale contrast, fashion photography bleeds, luxurious negative space, stark black on white.
```css
--font-display: "Didot", "Bodoni MT", serif;
--letter-spacing: 0.3em; --text-transform: uppercase;
```

### 5. Monocle Magazine
Sophisticated grid, numbered sections, confident color blocks, international modernism, information hierarchy.
```css
--font: "Plantin", Georgia, serif; --grid: 12-column;
--accent: #D4AF37; --bg: #FFFFFF;
```

### 6. The Outline Digital
Vibrant neon on dark, anti-establishment energy, bold sans-serif, animated gradients, punk editorial.
```css
--bg: #0A0A0A; --accent: #FF6B35;
--gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```

### 7. Architectural Digest
Luxury editorial, oversized imagery, minimal text intervention, sophisticated serif/sans pairing, gallery-like presentation.
```css
--font-display: "Freight Display", serif;
--font-body: "Graphik", sans-serif;
```

### 8. SSENSE Editorial
Fashion-forward minimalism, asymmetric layouts, editorial photography, crisp sans-serif, stark contrast.
```css
--font: "Helvetica Neue", Arial, sans-serif;
--bg: #FFFFFF; --text: #000000; --hover: #666666;
```

### 9. It's Nice That
Playful editorial, bold color splashes, creative confidence, mixed typography, design-industry insider energy.
```css
--font-display: "GT America", sans-serif;
--accent: #0000FF; --secondary: #FF00FF;
```

### 10. Eye on Design (AIGA)
Designer-for-designers, typographic experimentation, confident color, design discourse aesthetic.
```css
--font: "Söhne", "Helvetica Neue", sans-serif;
--accent: #FF4D00;
```

---

## Tech & SaaS (11-25)

### 11. Linear App
Precision engineering aesthetic, subtle gradients, dark with purple accents, pixel-perfect, obsessive attention to detail.
```css
--bg: #0A0B0D; --surface: #1A1B1E;
--accent: #5E6AD2; --text: #FFFFFF;
```

### 12. Vercel Black
Pure black canvas, white typography, monospace code blocks, terminal-inspired, developer confidence.
```css
--bg: #000000; --text: #FFFFFF;
--font-mono: "Geist Mono", monospace;
```

### 13. Stripe Gradient
Colorful gradients, animated mesh backgrounds, clean interface, blue-to-purple brand palette, financial trust.
```css
--gradient: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%);
--bg: #0A2540;
```

### 14. Notion Warmth
Off-white warmth, emoji as design element, hand-drawn illustrations, approachable productivity, sepia photography.
```css
--bg: #FFFFFF; --surface: #F7F6F3;
--text: #37352F; --accent: #2EAADC;
```

### 15. Figma Playful
Bright primary colors, geometric shapes, playful illustrations, creative tool energy, collaborative spirit.
```css
--red: #F24E1E; --orange: #FF7262; --purple: #A259FF;
--green: #0ACF83; --blue: #1ABCFE;
```

### 16. Raycast Command
Command palette aesthetic, keyboard-first, monospace, dark with subtle glow, developer productivity.
```css
--bg: #1A1A1A; --surface: #262626;
--accent: #FF6363; --border: rgba(255,255,255,0.1);
```

### 17. Arc Browser
Vibrant gradients, rounded everything, spatial computing feel, playful professionalism.
```css
--gradient: linear-gradient(135deg, #FF6B6B, #FF8E53, #FFD93D);
--radius: 1rem; --blur: 20px;
```

### 18. Superhuman Luxury
Email luxury, keyboard shortcuts prominent, dark with gold accents, speed-obsessed, executive aesthetic.
```css
--bg: #1A1A1A; --accent: #D4AF37;
--text: #FFFFFF; --muted: #666666;
```

### 19. Cal.com Open Source
Clean scheduling, accessibility-first, trustworthy neutrals, open-source pride.
```css
--bg: #FFFFFF; --surface: #F3F4F6;
--accent: #000000; --text: #111827;
```

### 20. Resend Developer
Email for developers, minimal purple accents, code-first presentation, modern developer tooling.
```css
--bg: #000000; --accent: #8B5CF6;
--font-mono: "JetBrains Mono", monospace;
```

### 21. Planetscale Database
Database visualization, branching metaphor, green/teal palette, technical confidence.
```css
--bg: #000000; --accent: #00D9FF;
--surface: #111111;
```

### 22. Clerk Auth
Auth provider aesthetic, secure feeling, purple gradients, developer-friendly.
```css
--accent: #6C47FF; --bg: #FAFAFA;
--surface: #FFFFFF;
```

### 23. Convex Real-time
Real-time visualization, reactive data flows, orange energy, modern backend.
```css
--accent: #F97316; --bg: #0C0A09;
--gradient: linear-gradient(135deg, #F97316, #FB923C);
```

### 24. Supabase Green
Firebase alternative, green everywhere, open-source pride, PostgreSQL elegance.
```css
--accent: #3ECF8E; --bg: #1C1C1C;
--surface: #2D2D2D;
```

### 25. Railway Deploy
Deploy infrastructure, purple gradients, developer experience focus, command line aesthetic.
```css
--bg: #13111C; --accent: #C049FF;
--gradient: linear-gradient(135deg, #C049FF, #844FFC);
```

---

## Luxury & High-End (26-40)

### 26. Hermès Artisan
Rich orange on cream, hand-crafted details, illustration-forward, brand heritage, timeless luxury.
```css
--orange: #F37021; --cream: #F6F1EB;
--font: "Orator", serif;
```

### 27. Cartier Red
Crimson on ivory, jewelry photography, extreme elegance, serif typography, French luxury.
```css
--red: #9D1B2F; --bg: #FAF8F5;
--font: "Didot", serif;
```

### 28. Rolex Precision
Deep green/gold palette, watch photography, Swiss precision, understated excellence.
```css
--green: #006039; --gold: #B4975A;
--bg: #FFFFFF;
```

### 29. Porsche Engineering
Automotive precision, dramatic angles, performance visualization, German engineering.
```css
--red: #D5001C; --bg: #000000;
--font: "Porsche Next", sans-serif;
```

### 30. Aesop Apothecary
Amber/brown warmth, ingredient-focused, apothecary aesthetic, tactile textures.
```css
--amber: #BA8B5E; --bg: #F7F5F3;
--text: #252525;
```

### 31. Tom Ford Night
Deep black, gold accents, masculine luxury, cinematic lighting, nocturnal elegance.
```css
--bg: #0A0A0A; --gold: #C9A962;
--font: "Bodoni", serif;
```

### 32. Bottega Green
Signature green leather, woven texture reference, Italian craft, understated wealth.
```css
--green: #3D6B4F; --bg: #F5F5F0;
--texture: url('/weave-pattern.svg');
```

### 33. Chanel Monochrome
Black and white only, interlocking C patterns, Parisian sophistication, timeless fashion.
```css
--bg: #FFFFFF; --text: #000000;
--font: "Galano Grotesque", sans-serif;
```

### 34. Four Seasons Hospitality
Warm neutrals, serene imagery, hospitality warmth, refined service aesthetic.
```css
--bg: #FAF8F5; --accent: #8B7355;
--font: "Chronicle Display", serif;
```

### 35. Aman Resorts
Extreme minimalism, zen-like whitespace, serene photography, spiritual luxury.
```css
--bg: #FFFFFF; --text: #3D3D3D;
--spacing: clamp(4rem, 10vw, 12rem);
```

### 36. Patek Philippe Heritage
Watchmaking heritage, navy and gold, generational wealth aesthetic, museum quality.
```css
--navy: #1A2744; --gold: #B4975A;
--font: "Times New Roman", serif;
```

### 37. Valentino Drama
High-fashion red, dramatic photography, editorial boldness, Italian drama.
```css
--red: #B01D1D; --bg: #FAF7F2;
--contrast: extreme;
```

### 38. Tiffany Blue
Signature robin's egg blue, jewelry presentation, romantic luxury, gift-giving aesthetic.
```css
--tiffany: #0ABAB5; --bg: #FFFFFF;
--accent: #000000;
```

### 39. Bang & Olufsen Audio
Danish design, aluminum/black palette, audio visualization, minimalist luxury.
```css
--bg: #000000; --surface: #1A1A1A;
--accent: #B4975A;
```

### 40. Rolls-Royce Motor
Coach-building heritage, deep purple/silver, automotive photography, bespoke luxury.
```css
--purple: #281432; --silver: #C0C0C0;
--bg: #0D0D0D;
```

---

## Creative & Agency (41-55)

### 41. Pentagram Identity
Case study focused, dramatic project reveals, confident typography, design authority.
```css
--bg: #FFFFFF; --text: #000000;
--grid: masonry; --transition: 0.6s cubic-bezier(0.16, 1, 0.3, 1);
```

### 42. Studio Dumbar Dutch
Experimental layouts, bold color, Dutch design heritage, conceptual work.
```css
--primary: #0000FF; --secondary: #FF0000;
--layout: asymmetric;
```

### 43. Sagmeister & Walsh Provocative
Artistic provocation, mixed media, hand-crafted digital, memorable visuals.
```css
--palette: dynamic; --imagery: conceptual;
--typography: experimental;
```

### 44. R/GA Digital
Digital innovation, tech-meets-creativity, data visualization, futuristic optimism.
```css
--bg: #0D0D0D; --accent: #00FF88;
--gradient: mesh;
```

### 45. Work & Co Product
Product design showcase, clean interface documentation, systematic presentation.
```css
--bg: #F5F5F5; --surface: #FFFFFF;
--accent: #000000;
```

### 46. Huge Brooklyn
Brooklyn creative energy, bold statements, startup-meets-agency aesthetic.
```css
--accent: #FF4136; --bg: #FFFFFF;
--font-display: "GT America Extended", sans-serif;
```

### 47. MediaMonks Craft
Award-winning craft, technical excellence, creative technology showcase.
```css
--bg: #1A1A1A; --accent: #FFD700;
--animation: complex;
```

### 48. Basic/Dept
Clean portfolio grid, minimal intervention, work speaks for itself aesthetic.
```css
--bg: #FFFFFF; --text: #000000;
--grid: tight; --hover: reveal;
```

### 49. Studio Feixen Swiss
Swiss precision, geometric shapes, playful color, motion-forward.
```css
--primary: #0000FF; --shapes: geometric;
--animation: delightful;
```

### 50. Anti-Agency Brutalist
Raw HTML energy, no framework aesthetic, anti-polish statement, honest web.
```css
--font: "Times New Roman", serif;
--bg: #FFFFFF; --border: 2px solid #000000;
```

### 51. Fantasy Interactive
Big brand work, case study immersion, high production values.
```css
--bg: #0A0A0A; --type-scale: dramatic;
--scroll: smooth;
```

### 52. Wieden+Kennedy Portland
Just Do It energy, brand storytelling, sports and culture, bold typography.
```css
--font: "Futura Bold", sans-serif;
--contrast: maximum;
```

### 53. Wolff Olins Identity
Brand transformation, strategic design, identity systems showcase.
```css
--bg: dynamic; --palette: brand-specific;
--grid: flexible;
```

### 54. Moving Brands Motion
Motion design showcase, animated case studies, dynamic presentations.
```css
--animation: everywhere; --bg: #000000;
--accent: variable;
```

### 55. ueno Iceland
Icelandic design, clean grids, confident color, friendly professionalism.
```css
--bg: #FFFFFF; --accent: #FF3366;
--font: "Circular", sans-serif;
```

---

## Cultural & Arts (56-70)

### 56. MoMA Exhibition
Museum white, artwork showcase, educational clarity, cultural institution.
```css
--bg: #FFFFFF; --text: #000000;
--font: "Franklin Gothic", sans-serif;
```

### 57. Tate Gallery Digital
Contemporary art, bold typography, artistic experimentation, institutional innovation.
```css
--bg: #FFFFFF; --accent: #000000;
--layout: editorial;
```

### 58. Walker Art Center
Minnesota cool, experimental typography, contemporary culture, design-forward museum.
```css
--font: custom variable; --bg: #FFFFFF;
--accent: contextual;
```

### 59. Spotify Wrapped
Data visualization, personal statistics, vibrant gradients, year-in-review energy.
```css
--gradient: radial-gradient(ellipse at top, #1DB954, #191414);
--animation: reveal;
```

### 60. Apple Keynote
Product reveal, dramatic lighting, precision animations, premium technology.
```css
--bg: #000000; --text: #FFFFFF;
--animation: orchestrated;
```

### 61. Nike Training
Athletic energy, performance visualization, motivational typography, swoosh integration.
```css
--bg: #000000; --accent: #FF6B00;
--font: "Nike Futura", sans-serif;
```

### 62. National Geographic
Documentary photography, yellow frame, exploration narrative, educational wonder.
```css
--yellow: #FFCC00; --bg: #000000;
--imagery: full-bleed;
```

### 63. New Museum Contemporary
White cube digital, artist-forward, exhibition documentation, curatorial voice.
```css
--bg: #FFFFFF; --text: #000000;
--spacing: museum;
```

### 64. Criterion Collection
Film preservation, classic cinema, collector aesthetic, curated excellence.
```css
--bg: #FFFFFF; --accent: #000000;
--border: distinctive;
```

### 65. The Met Archive
Cultural heritage, artifact documentation, scholarly presentation, institutional gravitas.
```css
--bg: #F7F5F2; --accent: #C41E3A;
--font: "Plantin", serif;
```

### 66. Whitney Museum
American art, stacked logo reference, contemporary programming, NYC cultural.
```css
--bg: #FFFFFF; --text: #000000;
--font: "Neue Haas Grotesk", sans-serif;
```

### 67. Cooper Hewitt Design
Design museum, educational interaction, object-focused, Smithsonian heritage.
```css
--accent: #FFD200; --bg: #FFFFFF;
--interaction: exploratory;
```

### 68. V&A Museum
Decorative arts, Victorian heritage, digital collection, British institution.
```css
--bg: #FAFAFA; --accent: #E4002B;
--grid: collection;
```

### 69. Serpentine Galleries
Pavilion architecture, contemporary art, London cultural, digital exhibitions.
```css
--bg: #FFFFFF; --text: #000000;
--layout: experimental;
```

### 70. Centre Pompidou
Inside-out architecture, French modernism, bold color coding, cultural programming.
```css
--red: #E30613; --blue: #0066B3;
--green: #00A651; --yellow: #FFF200;
```

---

## Retro & Nostalgic (71-85)

### 71. Y2K Cyber
Metallic gradients, chrome text, cyber aesthetic, millennium nostalgia.
```css
--gradient: linear-gradient(135deg, #C0C0C0, #808080);
--font: "Eurostile", sans-serif; --effects: bevel;
```

### 72. 90s Web Brutalist
Under construction GIFs, visitor counters, Times New Roman, honest HTML.
```css
--bg: #808080; --text: #0000FF;
--border: inset 3px; --font: "Comic Sans MS";
```

### 73. Vaporwave Aesthetic
Pink/cyan gradients, Greek statues, VHS glitch, Japanese text, retro-futurism.
```css
--pink: #FF6AD5; --cyan: #00FFFF;
--bg: linear-gradient(#FF71CE, #01CDFE);
```

### 74. 70s Psychedelic
Orange/brown palette, groovy typography, organic shapes, flower power.
```css
--orange: #FF6B35; --brown: #8B4513;
--font: "Groovy", cursive; --shapes: organic;
```

### 75. Art Deco Gatsby
Gold geometric patterns, 1920s elegance, Gatsby glamour, jazz age.
```css
--gold: #D4AF37; --black: #1A1A1A;
--pattern: chevron; --font: "Poiret One";
```

### 76. Memphis Design
Bold geometric shapes, clashing colors, 80s Italian design, Sottsass energy.
```css
--pink: #FF69B4; --yellow: #FFE135;
--blue: #00BFFF; --pattern: squiggle;
```

### 77. Swiss International
Helvetica, grid system, red/white/black, Müller-Brockmann precision.
```css
--font: "Helvetica", sans-serif;
--grid: strict; --accent: #FF0000;
```

### 78. Bauhaus Functional
Primary colors, geometric shapes, form follows function, modernist purity.
```css
--red: #E30613; --blue: #0033A0;
--yellow: #FFCC00; --font: "Universal";
```

### 79. Mid-Century Modern
Atomic age, boomerang shapes, teak tones, Eames aesthetic.
```css
--orange: #E85D04; --teal: #14746F;
--bg: #FFF8E7;
```

### 80. Cassette Culture
Tape deck aesthetic, Walkman era, neon on black, audio visualization.
```css
--bg: #1A1A1A; --accent: #FF00FF;
--texture: noise;
```

### 81. VHS Tracking
CRT scan lines, tracking errors, VCR timestamps, analog glitch.
```css
--effects: scanlines; --color-bleed: true;
--font: "VCR OSD Mono";
```

### 82. Newspaper Print
Newsprint texture, column layout, halftone images, ink bleed effect.
```css
--bg: #F5F5DC; --text: #1A1A1A;
--texture: newsprint; --columns: 4;
```

### 83. Neon Noir
Rainy city aesthetic, neon reflections, cyberpunk lighting, Blade Runner mood.
```css
--bg: #0D0D0D; --neon-pink: #FF2D95;
--neon-blue: #00D9FF; --rain: overlay;
```

### 84. Pixel Art 8-bit
Retro gaming, pixel fonts, limited palette, chiptune energy.
```css
--font: "Press Start 2P"; --pixels: crisp;
--palette: 16-color;
```

### 85. Polaroid Instant
Photo frame borders, handwritten captions, vintage photography, memory aesthetic.
```css
--bg: #FAF7F2; --frame: #FFFFFF;
--shadow: 0 4px 6px rgba(0,0,0,0.1);
```

---

## Experimental & Avant-Garde (86-100)

### 86. Deconstructed Grid
Broken layouts, overlapping elements, intentional chaos, graphic design school.
```css
--grid: none; --overlap: intentional;
--typography: fragmented;
```

### 87. Kinetic Typography
Text as motion, animated letterforms, scroll-triggered type, GSAP showcase.
```css
--animation: text-reveal; --scroll: trigger;
--split: chars;
```

### 88. Three.js Immersive
WebGL experiences, 3D navigation, spatial computing preview, technical showcase.
```css
--canvas: fullscreen; --interaction: spatial;
--performance: optimized;
```

### 89. Noise Grain Texture
Film grain overlay, analog warmth, texture-rich, tactile digital.
```css
--noise: url('/noise.svg'); --blend: overlay;
--opacity: 0.05;
```

### 90. Cursor Playground
Custom cursors, interaction delight, hover states as content, playful UX.
```css
--cursor: custom; --hover: transform;
--interaction: magnetic;
```

### 91. Scroll Hijack Cinema
Storytelling through scroll, narrative control, cinematic pacing, immersive experience.
```css
--scroll: controlled; --animation: timeline;
--sections: full-viewport;
```

### 92. Variable Font Play
Font-width animation, responsive typography, axis manipulation, type as experience.
```css
--font: variable; --animation: font-weight;
--axis: wght wdth slnt;
```

### 93. Cursor Trail Magic
Following particles, mouse trails, interactive particles, delightful motion.
```css
--particles: mouse-follow; --canvas: overlay;
--blend: screen;
```

### 94. Split Screen Duality
Two-sided narratives, comparison layouts, before/after, dual perspectives.
```css
--layout: split; --interaction: slide;
--contrast: deliberate;
```

### 95. ASCII Art Interface
Text-based UI, terminal aesthetic, character art, hacker culture.
```css
--font: "Fira Code", monospace;
--characters: box-drawing; --bg: #0D1117;
```

### 96. Morphing Shapes
Blob animations, organic transformations, SVG morphing, fluid design.
```css
--shapes: blob; --animation: morph;
--filter: gooey;
```

### 97. Parallax Depth
Z-axis layering, depth perception, scroll-based 3D, dimensional design.
```css
--perspective: 1000px; --layers: multiple;
--scroll: parallax;
```

### 98. Monochrome Dramatic
Single color + black/white, dramatic contrast, bold simplicity, statement design.
```css
--accent: single; --bg: #000000;
--text: #FFFFFF;
```

### 99. Data Viz Art
Information as beauty, chart aesthetics, statistical storytelling, D3.js showcase.
```css
--visualization: custom; --data: real;
--animation: reactive;
```

### 100. Anti-Design Chaos
Intentional ugliness, rule-breaking, punk aesthetic, beautiful destruction.
```css
--rules: broken; --typography: clashing;
--colors: jarring; --layout: chaotic;
```

---

## Skeuomorphism & Rich Realism (101-107)

### 101. Apple iOS 6 Craft
Leather calendars, linen note backgrounds, felt game tables, stitched borders, realistic toggle switches with depth, wood bookshelves. Physical material simulation at its peak.
```css
--bg: #C5B9A0; --surface: #E8DFD0;
--stitch: #8B7D6B; --leather: #6B4226;
--shadow: 0 2px 4px rgba(0,0,0,0.3), inset 0 1px 0 rgba(255,255,255,0.2);
```

### 102. Poolsuite FM
Retro desktop OS window chrome, draggable windows, leisure-class luxury, Miami pool-party energy, fake operating system UI with traffic-light buttons and title bars.
```css
--bg: #1A3A4A; --surface: #F5E6D3;
--chrome: linear-gradient(180deg, #E8E0D4, #D4C8B8);
--accent: #D4956A; --font: "Chicago", monospace;
```

### 103. Panic Software
Playful indie Mac developer, Cabel Sasser energy, app icons as art objects, rich toolbar buttons, whimsical-but-precise, Transmit/Nova personality.
```css
--bg: #FFFFFF; --surface: #F0F0F0;
--accent: #5856D6; --toolbar: linear-gradient(180deg, #F8F8FA, #E8E8EC);
```

### 104. Winamp Heritage
Media player chrome, brushed metal skins, EQ visualization bars, playlist panels, skinnable UI ecosystem, "it really whips the llama's ass."
```css
--chrome: #3A3A3A; --display: #0A1E0A;
--text-led: #00FF00; --button: linear-gradient(180deg, #6A6A6A, #4A4A4A);
```

### 105. Nothing Phone Glyph
Dot-matrix LED realism, transparent-back industrial design, monospace precision, phosphor glow on dark, Teenage Engineering collab energy.
```css
--bg: #000000; --glyph: #FFFFFF;
--surface: rgba(255,255,255,0.05); --font: "Nothing Dot", monospace;
--glow: 0 0 8px rgba(255,255,255,0.4);
```

### 106. Braun Calculator
Dieter Rams product design on screen, honest materials, physical button depth, German engineering precision, round-rect keys with real shadow.
```css
--bg: #F5F5F0; --button: #FFFFFF;
--button-shadow: 0 2px 0 #CCCCCC; --accent: #FF6600;
--font: "Univers", sans-serif;
```

### 107. Playdate Console
Crank-hardware metaphor, 1-bit black-and-white display, playful toy aesthetic, yellow case frame, pixel-precise at 400x240.
```css
--bg: #FFFFFF; --text: #000000;
--case: #FFC500; --display: #B2B5A0;
--font: "Roobert", sans-serif;
```

---

## Neumorphism & Soft UI (108-114)

### 108. Neumorph Dashboard
Soft-extruded cards on matching background, pillow-like buttons, concave inputs, single hue with shadow-only depth. The entire UI feels pressed from clay.
```css
--bg: #E0E5EC; --text: #44476A;
--shadow-light: -6px -6px 12px rgba(255,255,255,0.8);
--shadow-dark: 6px 6px 12px rgba(163,177,198,0.6);
```

### 109. Calm Meditation
Breathing circle animations, soft depth rings, muted blue-grey, gentle inset progress, zen state UI, sleep-timer dials with soft glow.
```css
--bg: #2C3E6B; --surface: #354A7D;
--accent: #92B4F4; --text: #E8EDF5;
--shadow: 8px 8px 16px rgba(0,0,0,0.3), -8px -8px 16px rgba(80,100,160,0.2);
```

### 110. Smart Home Panel
Thermostat dial with soft depth, room-temperature gradients, IoT device tiles, ambient light color, muted comfort palette.
```css
--bg: #E8E2DB; --warm: #E8A87C;
--cool: #7EB8DA; --surface: #F0EBE3;
--dial-shadow: inset 4px 4px 8px rgba(0,0,0,0.1), inset -4px -4px 8px rgba(255,255,255,0.7);
```

### 111. Tesla Cockpit
Automotive soft UI on dark, large touch targets, vehicle silhouette visualization, soft inset gauges, climate-control dials.
```css
--bg: #1A1A1A; --surface: #222222;
--accent: #3E6AE1; --text: #FFFFFF;
--shadow: inset 2px 2px 4px rgba(0,0,0,0.5), inset -2px -2px 4px rgba(60,60,60,0.3);
```

### 112. Elgato Control Surface
Button grid with soft-press feedback, icon-first tiles, customizable surfaces, stream-deck layout, action-on-press.
```css
--bg: #1E1E1E; --tile: #2A2A2A;
--tile-active: #3A3A3A; --accent: #8B5CF6;
--pressed: inset 3px 3px 6px rgba(0,0,0,0.4), inset -1px -1px 2px rgba(80,80,80,0.2);
```

### 113. Samsung One UI Soft
Rounded everything, pastel card backgrounds, large touch targets, gentle shadow depth, approachable mobile. Korean design warmth meets soft realism.
```css
--bg: #F7F7F7; --surface: #FFFFFF;
--accent: #1259A5; --radius: 24px;
--shadow: 0 4px 12px rgba(0,0,0,0.06), 0 1px 3px rgba(0,0,0,0.04);
```

### 114. Audio Mixer
Fader tracks with soft channel strips, VU meter depth, knob rotation, mixing console layout, studio-grade tactile UI.
```css
--bg: #2D2D2D; --channel: #383838;
--fader: linear-gradient(180deg, #555, #444); --vu-green: #4ADE80;
--vu-red: #EF4444; --knob-shadow: 0 2px 4px rgba(0,0,0,0.5);
```

---

## Glassmorphism & Translucency (115-121)

### 115. macOS Sonoma Desktop
Frosted sidebar panels, vibrancy material layers, translucent menu bar, desktop wallpaper bleeding through, system-level depth hierarchy.
```css
--glass: rgba(255,255,255,0.72); --blur: 20px;
--border: 1px solid rgba(255,255,255,0.18);
--shadow: 0 8px 32px rgba(0,0,0,0.12);
```

### 116. Apple Vision Pro Spatial
Floating glass panels in space, ambient light response, specular highlights on panel edges, visionOS window chrome, spatial depth layering.
```css
--glass: rgba(30,30,30,0.4); --blur: 40px;
--border: 1px solid rgba(255,255,255,0.08);
--highlight: linear-gradient(135deg, rgba(255,255,255,0.1), transparent);
```

### 117. Windows Fluent Acrylic
Mica backdrop material, acrylic in-app surfaces, reveal highlight on hover, Fluent Design luminosity, layered depth system.
```css
--acrylic: rgba(255,255,255,0.65); --mica: rgba(243,243,243,0.72);
--blur: 30px; --reveal: radial-gradient(circle at var(--mouse-x) var(--mouse-y), rgba(255,255,255,0.15), transparent 80%);
```

### 118. Glassmorphic Login
Floating card over vibrant gradient background, heavy blur, visible color bleeding through edges, frosted form inputs, glowing submit.
```css
--glass: rgba(255,255,255,0.15); --blur: 12px;
--border: 1px solid rgba(255,255,255,0.25);
--bg-gradient: linear-gradient(135deg, #667eea, #764ba2, #f093fb);
```

### 119. Discord Overlay
Semi-transparent status panels, game-integration glass, voice channel indicators bleeding through, ambient presence awareness.
```css
--overlay: rgba(0,0,0,0.75); --blur: 8px;
--accent: #5865F2; --online: #23A559;
--surface: rgba(30,31,34,0.85);
```

### 120. Spotify Now Playing
Album-art-adaptive glass, blurred album artwork as background, frosted player controls, color-extraction translucency.
```css
--glass: rgba(0,0,0,0.5); --blur: 80px;
--bg: var(--album-dominant-color);
--surface: rgba(255,255,255,0.08);
```

### 121. Dashboard Glasspane
Multi-layer glass cards at different blur levels, nested translucency, data visualization behind frosted panels, depth-sorted widgets.
```css
--layer-1: rgba(255,255,255,0.08); --blur-1: 40px;
--layer-2: rgba(255,255,255,0.12); --blur-2: 20px;
--layer-3: rgba(255,255,255,0.18); --blur-3: 8px;
```

---

## Isometric & 2.5D Illustration (122-128)

### 122. Monument Valley
Impossible geometry, Escher-inspired isometric architecture, pastel block structures, meditative spatial puzzles, touchable impossible objects.
```css
--pink: #E8A0BF; --blue: #7EC8E3;
--yellow: #FFD166; --shadow: #C490A0;
--perspective: isometric 30deg;
```

### 123. Slack Workspace Scenes
Isometric office environments, collaborative metaphors, friendly 2.5D characters at desks, productivity narratives, warm workplace illustration.
```css
--primary: #4A154B; --surface: #F8F8F8;
--illustration-stroke: none; --style: flat-isometric;
```

### 124. Mailchimp Marketing World
Isometric email-workflow scenes, envelope-as-building metaphors, playful product illustration, marketing campaign landscapes.
```css
--yellow: #FFE01B; --bg: #FFFFFF;
--illustration: isometric; --characters: cavendale;
```

### 125. SimCity Builder View
City-builder grid, zoning-colored blocks, infrastructure visualization, god-view management UI, resource bars, bulldozer cursor.
```css
--residential: #4ADE80; --commercial: #60A5FA;
--industrial: #FBBF24; --grid: 64px;
--bg: #2D5016;
```

### 126. Figma Component Isometric
Design tool as 3D space, component instances as blocks, variant properties as dimensions, auto-layout visualized spatially.
```css
--frame: #1E1E1E; --component: #A259FF;
--instance: #0ACF83; --grid: #444444;
```

### 127. Lottie Animation World
Animated isometric scenes, Bodymovin-exported micro-worlds, loading-state landscapes, onboarding illustrations with motion.
```css
--animation: lottie-json; --style: flat-3d;
--palette: vibrant; --framerate: 60;
```

### 128. Low-Poly Terrain
Faceted polygon landscapes, triangulated surfaces, vertex-colored terrain, geometric mountains, stylized nature.
```css
--sky: linear-gradient(180deg, #87CEEB, #E0F0FF);
--terrain: #4A7C59; --snow: #F0F0F0;
--water: #4A90D9; --render: flat-shaded;
```

---

## Macro Typography & Type-Dominant (129-135)

### 129. Huge Inc Statements
Viewport-width headlines, typography IS the hero, words as architecture, massive scale contrast, the logo is a sentence.
```css
--font-display: "GT Super Display", serif;
--font-size-hero: clamp(4rem, 15vw, 12rem);
--leading: 0.85; --tracking: -0.04em;
```

### 130. Nike SNKRS Type
Condensed uppercase, athletic energy, sneaker-name typography at poster scale, bold weight as brand expression, compressed impact.
```css
--font: "Helvetica Neue Condensed", sans-serif;
--weight: 900; --transform: uppercase;
--size: clamp(3rem, 12vw, 10rem); --tracking: -0.02em;
```

### 131. Bloomberg Businessweek Cover
Magazine cover typography as design, overlapping letterforms, editorial type as art, extreme scale contrast, words collide with imagery.
```css
--font-display: "Neue Haas Grotesk", sans-serif;
--weight: 700; --color: #000000;
--overlap: -0.1em; --mix-blend-mode: multiply;
```

### 132. Experimental Jetset
Dutch design precision, Helvetica-only systematic type, grid-locked letterforms, modernist purity, less-is-more-but-more.
```css
--font: "Helvetica", "Arial", sans-serif;
--weight: 400; --size: systematic;
--grid: strict-baseline; --color: #000000;
```

### 133. David Carson Raygun
Anti-grid typography, overlapping text, reading-as-experience, grunge type, deconstruction, legibility is not communication.
```css
--font: mixed; --rotation: random(-15deg, 15deg);
--overlap: aggressive; --opacity: layered;
--rules: none;
```

### 134. Stefan Sagmeister Skin
Typography carved into physical surfaces, text-on-bodies, words as texture, hand-cut letters, pain-as-design-tool.
```css
--font: hand-cut; --texture: physical;
--material: skin|wood|concrete;
--photography: documentation;
```

### 135. Massimo Vignelli Canon
Garamond + Helvetica and nothing else, five sizes, three weights, grid everything, timeless over trendy, "if you can design one thing you can design everything."
```css
--font-serif: "Garamond", serif;
--font-sans: "Helvetica", sans-serif;
--sizes: 6pt 9pt 12pt 18pt 36pt; --grid: modular;
```

---

## Synthwave & Retro-Futurism (136-142)

### 136. Hotline Miami Vice
Neon pink and cyan on midnight, palm tree silhouettes, venetian blind shadows, VHS grain, cocaine-white UI elements, 1986 forever.
```css
--bg: #0D0221; --pink: #FF2975;
--cyan: #00F0FF; --grid-floor: linear-gradient(transparent 90%, #FF2975 100%);
--grain: url('/vhs-noise.svg');
```

### 137. Stranger Things Demogorgon
Chrome-red ITC Benguiat letters on black, flickering bulb animations, Upside Down desaturation, 80s horror title sequence energy.
```css
--bg: #0A0A0A; --red: #B71515;
--font: "Benguiat", serif; --flicker: 0.1s;
--glow: 0 0 20px rgba(183,21,21,0.6);
```

### 138. Tron Legacy Circuit
Cyan light-lines on pure black, circuit-trace patterns, identity disc glow, digital world topology, Daft Punk visual identity.
```css
--bg: #000000; --cyan: #6FC3DF;
--line-width: 1px; --glow: 0 0 12px rgba(111,195,223,0.5);
--grid: perspective-floor;
```

### 139. Outrun Sunset
Pink-orange-purple sunset gradient, chrome-text reflections, grid-floor receding to vanishing point, sports car silhouette, vapor FM.
```css
--gradient: linear-gradient(180deg, #2B1055, #7B2D8E, #D1568C, #F0944D);
--chrome: linear-gradient(180deg, #FFF, #888, #FFF);
--grid: perspective; --font: "Lazer 84";
```

### 140. Cybertruck Angular
Low-polygon futurism, stainless steel surfaces, angular-everything geometry, origami car aesthetic, brutalist-DeLorean energy.
```css
--bg: #000000; --steel: #C0C0C0;
--surface: linear-gradient(135deg, #AAA, #888, #AAA);
--angles: sharp; --radius: 0;
```

### 141. Alien Isolation CRT
Retro-sci-fi computer terminal, amber phosphor on dark, CRT curvature distortion, Nostromo crew manifest, lo-fi future.
```css
--bg: #0A0A0A; --phosphor: #FF9F1A;
--scanline: repeating-linear-gradient(transparent 0, transparent 2px, rgba(0,0,0,0.2) 2px, rgba(0,0,0,0.2) 4px);
--curvature: barrel-distort;
```

### 142. Blade Runner 2049 Hologram
Pink-orange holographic projections, volumetric light, rain-soaked reflections, brutalist interiors, Joi-shimmer transparency.
```css
--bg: #0D0D0D; --hologram: rgba(255,120,50,0.7);
--scan: linear-gradient(transparent 50%, rgba(255,120,50,0.05) 50%);
--blur: 2px; --noise: chromatic-aberration;
```

---

## Y2K & Early Web Revival (143-149)

### 143. MySpace Profile Page
Auto-playing embedded music widget, sparkle GIF background tiles, custom CSS gone wrong, Top 8 friend grid, scene-kid energy, blinkies in the about me.
```css
--bg: tiled url('/sparkle-tile.gif');
--text: #FF00FF; --link: #0000FF;
--font: "Verdana", sans-serif; --cursor: url('/custom.cur');
--border: 2px dotted #FF69B4;
```

### 144. GeoCities Archive
Under-construction GIF banners, visitor hit counters, guestbook links, web ring navigation, tiled marble backgrounds, "Best Viewed in 800x600."
```css
--bg: url('/marble-tile.jpg') repeat;
--text: #000080; --link: #0000FF; --vlink: #800080;
--font: "Times New Roman", serif; --border: ridge 4px;
```

### 145. Neopets Virtual World
Pet adoption UI, point-system headers, game-grid thumbnails, forum signature banners, pixel item inventories, medieval guild pages.
```css
--bg: #FFFFFF; --header: #1B5F8A;
--accent: #F9C22E; --surface: #E8E4D0;
--font: "Verdana", sans-serif; --border: 1px solid #999;
```

### 146. Windows XP Bliss
Luna theme chrome, Tahoma system font, green-hills desktop wallpaper, beveled 3D buttons, Start menu cascade, "log off" nostalgia.
```css
--taskbar: linear-gradient(180deg, #1F5DBD, #3C8EF3, #245EDC);
--button: linear-gradient(180deg, #FFFFFF, #ECE9D8);
--border: 1px solid #003C74; --font: "Tahoma", sans-serif;
--bg: #3A6EA5;
```

### 147. AIM Buddy List
Buddy list sidebar, running-man icon, away-message poetry, door-open/close sounds visualized, screen-name culture, passive-aggressive profiles.
```css
--bg: #FFFFFF; --header: #6699CC;
--online: #000000; --away: #808080;
--font: "Arial", sans-serif; --sidebar: 200px;
```

### 148. Flash Game Portal
Newgrounds/Miniclip game lobby, thumbnail grid with ratings, loading-bar preloaders, category tabs, user-submitted content, Medal of the Day.
```css
--bg: #1A1A1A; --surface: #2D2D2D;
--accent: #FFCC00; --rating: #FFD700;
--font: "Arial Black", sans-serif; --grid: 4-up;
```

### 149. Limewire Download Queue
Peer-to-peer file list, green progress bars, download-speed columns, questionable filenames, skull-and-crossbones icons, "connecting to peers..."
```css
--bg: #D4D0C8; --surface: #FFFFFF;
--progress: #00CC00; --error: #CC0000;
--font: "MS Sans Serif", sans-serif; --table: striped;
```

---

## Small Business & Vernacular Design (150-156)

### 150. Local Pizza Joint
Giant phone number in the header, red-checkered tablecloth pattern, "BEST IN TOWN SINCE 1987" badge, Yelp-photo-quality food shots, family-owned warmth, menu-as-homepage.
```css
--red: #CC0000; --cream: #FFF5E6;
--check: repeating-conic-gradient(#CC0000 0% 25%, #FFFFFF 0% 50%) 50% / 20px 20px;
--font: "Cooper Black", serif;
```

### 151. Nail Salon Homepage
Excessive rose-gold gradients, Comic Sans "WELCOME!" header, animated GIF roses, embedded Google Maps dominating the fold, phone number button, appointment booking buried.
```css
--gradient: linear-gradient(135deg, #F7E7CE, #E8C4A0);
--accent: #D4956A; --text: #4A2C2A;
--font: "Comic Sans MS", cursive; --sparkle: url('/rose.gif');
```

### 152. Chinatown Restaurant
Red and gold everything, jade-green secondary, bilingual menu columns, lazy-susan imagery, dragon border ornaments, "OPEN 7 DAYS" badge, generational family business.
```css
--red: #CC0000; --gold: #FFD700;
--jade: #00A86B; --bg: #1A0000;
--border: url('/dragon-border.svg'); --font: "SimSun", serif;
```

### 153. Corner Bodega
Hand-lettered signage typography, lottery-ticket neon, stacked-inventory grid, community bulletin board section, cash-only badge, "WE ACCEPT EBT" banner.
```css
--bg: #F5F0E0; --neon-green: #39FF14;
--awning: repeating-linear-gradient(90deg, #CC0000 0 20px, #FFFFFF 20px 40px);
--font: "Marker Felt", cursive; --price: "Sharpie", sans-serif;
```

### 154. Roadside Motel
Retro neon sign header, VACANCY/NO-VACANCY toggle, analog star rating, pool photo banner, Route 66 nostalgia, "Free HBO" badge, ice-machine directions.
```css
--neon: #FF6B9D; --dark: #1A1A2E;
--sign: text-shadow: 0 0 10px #FF6B9D, 0 0 40px #FF6B9D;
--font: "Playbill", serif; --stars: #FFD700;
```

### 155. Taco Truck Menu Board
Laminated menu aesthetic, numbered combo items, hand-priced with marker, salsa heat scale (mild/medium/hot/FUEGO), cash-only note, Instagram handle in Sharpie.
```css
--bg: #FFFFFF; --laminate: rgba(255,255,255,0.6);
--text: #222222; --price: #CC0000;
--font: "Permanent Marker", cursive; --hot: #FF4500;
```

### 156. Local Car Wash
Bright primary colors, hand-drawn arrows pointing everywhere, unlimited-plan pricing tiers, before/after photo slider, loyalty punch card graphic, "HAND WAX $49.99" starburst.
```css
--blue: #0066FF; --yellow: #FFD700;
--red: #FF0000; --starburst: conic-gradient(#FFD700 0deg, #FF0000 30deg, #FFD700 60deg);
--font: "Impact", sans-serif;
```

---

## Kawaii & Japanese Pop Culture (157-163)

### 157. Sanrio Hello Kitty
Pink overload, character mascots in every corner, rounded corners as philosophy, bow-tied dividers, cute typography with hearts, pastel gradient backgrounds.
```css
--pink: #FF69B4; --white: #FFFFFF;
--bow-red: #FF0000; --bg: linear-gradient(180deg, #FFB6C1, #FFF0F5);
--radius: 999px; --font: "Kosugi Maru", sans-serif;
```

### 158. LINE Friends Store
Brown/Cony/Sally characters as UI elements, sticker-first communication, cute commerce layouts, plush-merchandise cards, emoji as navigation.
```css
--green: #00C300; --brown: #8B6914;
--bg: #FFFFFF; --surface: #F5F5F5;
--radius: 20px; --shadow: 0 2px 8px rgba(0,0,0,0.06);
```

### 159. Studio Ghibli Forest
Watercolor wash backgrounds, Totoro-soft UI elements, forest-spirit aesthetic, hand-painted gradient warmth, Miyazaki wonder, soot-sprite loading spinners.
```css
--bg: linear-gradient(180deg, #87CEEB, #98D8C8, #F0E68C);
--surface: rgba(255,255,255,0.7); --text: #2D4A22;
--watercolor: url('/watercolor-wash.svg'); --font: "Zen Maru Gothic", serif;
```

### 160. Animal Crossing Island
Pastel island tones, rounded-everything sans-serif, NPC dialogue boxes with character portraits, turnip-economics dashboard, leaf-icon navigation, wholesome commerce.
```css
--sky: #87CEEB; --grass: #7EC850;
--sand: #F5DEB3; --nook: #8B7355;
--font: "Varela Round", sans-serif; --radius: 24px;
```

### 161. Pokémon Center
Type-colored category badges, evolution-chain UI, Pokédex interface panels, catch-rate progress bars, game-to-merchandise pipeline, 151 original energy.
```css
--fire: #F08030; --water: #6890F0;
--grass: #78C850; --electric: #F8D030;
--pokeball-red: #EE1515; --font: "Press Start 2P", monospace;
```

### 162. Shibuya 109 Harajuku
Layered text collisions, busy maximalism, idol-aesthetic photo grids, photo-booth sticker overlays, harajuku fashion energy, Decora accessories as UI.
```css
--pink: #FF1493; --purple: #9B59B6;
--yellow: #FFE135; --bg: #FFFFFF;
--layer: stacked; --overflow: intentional;
```

### 163. Tamagotchi LCD
Tiny pixel-pet on simulated LCD screen, 16x16 character sprites, device-frame border, beep-boop interaction states, handheld egg shape, 3-button control strip.
```css
--lcd-bg: #8BAC0F; --lcd-dark: #306230;
--case: #E8A0BF; --pixel: 4px;
--font: monospace; --display: 32x16-grid;
```

---

## Dark Academia & Scholarly (164-170)

### 164. Oxford Library
Aged leather-spine textures, gold-leaf display typography, card-catalog UI metaphor, mahogany panel warmth, dust-mote particle overlay, brass fixtures.
```css
--leather: #4A2C17; --gold: #C5A55A;
--parchment: #F5F0E1; --mahogany: #420D09;
--font-display: "Cormorant Garamond", serif; --font-body: "EB Garamond", serif;
```

### 165. Penguin Classics
Color-coded genre bands (orange fiction, green crime, blue pelican), iconic tripartite cover, literary serif typography, publishing heritage weight.
```css
--fiction: #E85D26; --crime: #00A14B;
--classics: #000000; --pelican: #0066B3;
--bg: #F5F0E6; --font: "Baskerville", serif;
```

### 166. Criterion Channel
Film-noir stills, scholarly director commentary, curated collection grids, cinephile sophistication, essay-forward layout, film-grain overlay.
```css
--bg: #151515; --surface: #1E1E1E;
--accent: #FFFFFF; --text: #B0B0B0;
--font: "Neue Haas Grotesk", sans-serif; --grain: film-16mm;
```

### 167. Moleskine Notebook
Rounded corner pages, elastic-band accent stripe, cream paper background, fountain-pen ink text, ruled/grid/blank page variants, analog-digital bridge.
```css
--cover: #1A1A1A; --paper: #FFFEF5;
--ink: #2C2C2C; --elastic: #C41E3A;
--rules: repeating-linear-gradient(transparent 0, transparent 27px, #D4CFC4 28px);
```

### 168. Letterboxd Film Diary
Star-rating hover states, watchlist curation grids, poster-first gallery, cinephile community, film-log-entry cards, "liked by" social proof.
```css
--bg: #14181C; --surface: #1C2228;
--accent: #00E054; --orange: #FF8000;
--star: #FFD700; --font: "Graphik", sans-serif;
```

### 169. Wikipedia Deep Dive
Citation-bracketed references, table-of-contents sidebar, disambiguation notices at top, blue link density, neutral-point-of-view gray, crowdsourced authority.
```css
--bg: #FFFFFF; --surface: #F6F6F6;
--link: #0645AD; --visited: #0B0080;
--border: #A2A9B1; --font: "Linux Libertine", "Georgia", serif;
```

### 170. British Museum Catalog
Artifact card with provenance metadata, scholarly description panels, period-room photography, institutional sans-serif, accession numbers, "Room 4, Case 12."
```css
--bg: #FAFAF5; --surface: #FFFFFF;
--accent: #1A1A1A; --metadata: #666666;
--font: "National", sans-serif; --border: 1px solid #E0DDD5;
```

---

## Cottagecore & Pastoral Craft (171-177)

### 171. Rifle Paper Co Botanical
Hand-painted floral illustrations, garden-party color palette, watercolor rose borders, stationery elegance, Anna Bond brushstrokes.
```css
--rose: #D4707A; --leaf: #5A7247;
--cream: #FFF8F0; --gold: #C5A55A;
--font: "Lora", serif; --illustration: hand-painted;
```

### 172. Etsy Handmade Market
Craft marketplace grid, handwritten label photography, pressed-flower product shots, maker stories sidebar, small-batch pricing badges, "ships in 3-5 days."
```css
--orange: #F56400; --bg: #FAFAFA;
--surface: #FFFFFF; --text: #222222;
--font: "Graphik", sans-serif; --badge: hand-drawn;
```

### 173. Anthropologie Eclectic
Bohemian retail mood, mixed-pattern backgrounds, wanderlust photography, eclectic curation, tactile texture overlays, candle-collection grids.
```css
--bg: #FAF6F1; --accent: #9B6B5A;
--text: #3D3D3D; --pattern: mixed-textile;
--font-display: "Caslon", serif; --font-body: "Gill Sans", sans-serif;
```

### 174. Vermont Country Store
Nostalgia-commerce catalog, heirloom product cards, "Since 1946" heritage badge, simple-living editorial, Americana warmth, penny-candy pricing.
```css
--red: #A52A2A; --cream: #FFF8E7;
--green: #2E5A1E; --bg: #F5F0E0;
--font: "Bookman Old Style", serif;
```

### 175. Martha Stewart Kitchen
Garden-to-table photography, recipe card layouts, seasonal color palettes, domestic craft aspiration, linen-texture backgrounds, copper-pot accents.
```css
--sage: #9CAF88; --copper: #B87333;
--linen: #FAF0E6; --text: #333333;
--font: "Chronicle Display", serif;
```

### 176. Food52 Provisions
Kitchen-table photography, recipe-driven commerce, copper and linen palette, home-cook community, artisanal product cards, "genius recipes" editorial.
```css
--bg: #FFFFFF; --surface: #F9F6F2;
--accent: #CC4E2C; --text: #333333;
--font-display: "Canela", serif; --font-body: "Metric", sans-serif;
```

### 177. Wildflower Pressed
Pressed-flower phone-case products, Instagram-native Gen-Z pastoral, colorful dried-flower chaos, handmade-but-scaled, butterfly sticker overlays.
```css
--lavender: #B39DDB; --sage: #A8C68F;
--sunflower: #FFD54F; --bg: #FFF8F0;
--border: hand-torn; --font: "Quicksand", sans-serif;
```

---

## Cyberpunk & Terminal Hacker (178-184)

### 178. Matrix Digital Rain
Green phosphor katakana cascade, CRT glow bloom, terminal-as-portal, "follow the white rabbit" prompt, code-rain canvas overlay.
```css
--bg: #000000; --phosphor: #00FF41;
--glow: 0 0 4px #00FF41, 0 0 12px rgba(0,255,65,0.3);
--font: "Courier New", monospace; --rain: column-cascade;
```

### 179. Mr. Robot fsociety
Kali Linux terminal aesthetic, monospace-only UI, social-engineering-red accents, dark-web interface panels, mask-logo watermark, anti-corporate.
```css
--bg: #0A0A0A; --text: #A0A0A0;
--accent: #FF0000; --surface: #111111;
--font: "Hack", "Fira Code", monospace; --prompt: "root@fsociety:~#";
```

### 180. Fallout Pip-Boy
Retro-future amber-monochrome terminal, Vault-Tec branding, atomic-age computing, S.P.E.C.I.A.L. stat bars, dial-based navigation, irradiated scanlines.
```css
--amber: #1AFF80; --alt: #FF9A00;
--bg: #0A1A0A; --scanline: rgba(0,0,0,0.15);
--font: "Share Tech Mono", monospace; --screen-curve: 4px;
```

### 181. Watch Dogs ctOS
City surveillance overlay, network-node visualization, connected-device maps, hack-progress circles, profiler UI, real-time data streams.
```css
--bg: rgba(0,0,0,0.85); --accent: #00BFFF;
--data: #FFFFFF; --alert: #FF3333;
--font: "Rajdhani", sans-serif; --grid: hexagonal;
```

### 182. DEFCON Conference
Badge-hacking aesthetic, CTF scoreboard tables, exploit-disclosure formatting, hacker-con schedule grid, responsible-disclosure ethics, sticker-bombed laptop energy.
```css
--bg: #000000; --accent: #00FF00;
--warning: #FF0000; --surface: #0A0A0A;
--font: "IBM Plex Mono", monospace; --border: 1px solid #333;
```

### 183. Cyberpunk 2077 Night City
Glitch-artifact overlays, data-corruption visual effects, neon-on-rain-soaked-concrete, corpo-vs-street dual aesthetic, Johnny Silverhand interference.
```css
--bg: #0D0D12; --neon-yellow: #FCE300;
--neon-cyan: #00F0FF; --neon-red: #FF003C;
--glitch: chromatic-aberration 2px; --grain: heavy;
```

### 184. Shodan Search Engine
IoT device scanner results, exposed-service tables, IP geolocation maps, vulnerability severity badges, internet-of-terrible-things, banner-grab monospace.
```css
--bg: #1A1A2E; --accent: #E94560;
--text: #EAEAEA; --surface: #16213E;
--font: "Source Code Pro", monospace; --table: dense;
```

---

## Corporate Memphis & Startup Illustration (185-191)

### 185. Slack Brand Illustrations
Geometric people with disproportionate limbs, saturated flat fills, remote-work collaborative scenes, inclusive representation through abstraction.
```css
--aubergine: #4A154B; --blue: #36C5F0;
--green: #2EB67D; --red: #E01E5A;
--yellow: #ECB22E; --illustration: geometric-people;
```

### 186. Headspace Meditation Blobs
Breathing-dot animations, gentle gradient characters, orange orb mascot, calming motion loops, mental-health-safe palette, Andy Puddicombe's voice visualized.
```css
--orange: #F47D31; --bg: #FFF5EB;
--surface: #FFFFFF; --calm-blue: #2B2D42;
--animation: breathing 4s ease infinite; --shapes: blob;
```

### 187. Hims & Hers DTC
Millennial DTC aesthetic, destigmatizing-copy energy, pastel product photography, wellness-tech branding, accessible healthcare meets Instagram.
```css
--bg: #FFF5F0; --accent: #E8927C;
--text: #1A1A1A; --surface: #FFFFFF;
--font: "Circular", sans-serif; --photography: clinical-but-warm;
```

### 188. Gusto Payroll People
Green geometric people illustrations, payroll-as-simple narrative, small-business hero scenes, compliance-as-friendly, running-payroll-in-your-pajamas energy.
```css
--green: #0A8080; --bg: #FFFFFF;
--surface: #F7FAF9; --accent: #F45D48;
--illustration: flat-geometric; --font: "Centra No2", sans-serif;
```

### 189. Intercom Messenger Widget
Chat-widget illustration world, customer-success scene people, blue geometric humans, support-bot personality bubbles, "we're here to help" energy.
```css
--blue: #0077B5; --surface: #F5F5F5;
--widget: #FFFFFF; --accent: #286EFA;
--font: "Inter", sans-serif; --radius: 16px;
```

### 190. Asana Productivity People
Coral-pink humans completing tasks, project-timeline scenes, celebration confetti moments, teamwork-makes-the-dream-work illustrations.
```css
--coral: #F06A6A; --bg: #FFFFFF;
--surface: #F9F8F8; --accent: #796EFF;
--illustration: celebration-people; --confetti: on-complete;
```

### 191. Duolingo Owl Universe
Green owl mascot ecosystem, gamification UI, streak-fire badges, XP progress bars, heart-lives system, passive-aggressive push-notification energy.
```css
--green: #58CC02; --bg: #FFFFFF;
--gold: #FFC800; --red: #FF4B4B;
--owl: mascot-driven; --font: "Feather Bold", rounded-sans;
```

---

## Biophilic & Nature-Forward (192-198)

### 192. Patagonia Activism
Documentary photography, environmental urgency typography, Jeremiah-Johnson-beard energy, "Don't Buy This Jacket" anti-marketing, trail-dust palette.
```css
--bg: #FFFFFF; --text: #1A1A1A;
--accent: #005387; --earth: #5C4033;
--font-display: "Knockout", sans-serif; --imagery: documentary;
```

### 193. Allbirds Sustainable Material
Merino-wool texture swatches, eucalyptus-fiber closeups, carbon-footprint badges, sustainable-materials showcase, tree-planting counter.
```css
--bg: #F5F5F0; --green: #4A7C59;
--surface: #FFFFFF; --text: #1A1A1A;
--font: "National 2", sans-serif; --texture: natural-fiber;
```

### 194. National Parks WPA Poster
WPA poster flat-illustration, trail-map typography, stewardship branding, ranger-hat green, vintage park signage, "est. 1916" heritage.
```css
--forest: #2D4A22; --sky: #5B8BA0;
--rock: #C4A57B; --sunset: #E8A87C;
--font: "National Park", sans-serif; --illustration: flat-landscape;
```

### 195. 1 Hotel Living Wall
Living-wall photography, reclaimed-wood textures, LEED-certification badges, biophilic-luxury interiors, hotel-as-ecosystem.
```css
--green: #4A7C59; --wood: #8B6914;
--stone: #A09080; --bg: #FAF8F5;
--texture: reclaimed-wood; --font: "Libre Baskerville", serif;
```

### 196. Seedlip Botanical Spirits
Garden-to-glass imagery, botanical distillation diagrams, nature-macro photography-as-product, zero-proof sophistication, copper-still aesthetics.
```css
--copper: #B87333; --botanical: #2D4A22;
--bg: #FFFFFF; --text: #1A1A1A;
--font: "GT Sectra", serif; --illustration: botanical-line;
```

### 197. Timber Press Garden
Horticultural-book-cover energy, plant-identification-guide layouts, seasonal color palettes, pressed-specimen photography, propagation diagrams.
```css
--leaf: #3D7A3D; --soil: #4A3728;
--bloom: #D4707A; --bg: #FFFFF0;
--font: "Bembo", serif; --layout: field-guide;
```

### 198. Muji No-Brand Nature
Unbleached-cardboard minimalism, rice-paper texture, no-brand-is-the-brand, Japanese nature philosophy, muji-to-go simplicity, bamboo materiality.
```css
--bg: #F5F0E6; --text: #4A4A4A;
--surface: #FFFFFF; --accent: #8B0000;
--font: "Noto Sans JP", sans-serif; --texture: washi;
```

---

## Material & Flat System Design (199-205)

### 199. Google Material 3
Dynamic color from content, tonal surface palettes, shape-corner tokens, elevation-to-shadow mapping, motion choreography with spring physics.
```css
--primary: #6750A4; --on-primary: #FFFFFF;
--surface: #FFFBFE; --surface-variant: #E7E0EC;
--radius-sm: 8px; --radius-md: 12px; --radius-lg: 16px;
```

### 200. Microsoft Fluent 2
Segoe UI Variable font, Mica backdrop material, acrylic in-app blur, motion-as-personality, adaptive-density modes (compact/normal/spacious).
```css
--bg: #FAFAFA; --surface: #FFFFFF;
--accent: #0078D4; --text: #242424;
--font: "Segoe UI Variable", sans-serif; --radius: 4px;
```

### 201. IBM Carbon
Enterprise rigor, 2x spacing grid, productive-to-expressive theme scale, accessibility-score-first, Plex font family, information-dense data tables.
```css
--blue-60: #0F62FE; --gray-100: #161616;
--gray-10: #F4F4F4; --white: #FFFFFF;
--font: "IBM Plex Sans", sans-serif; --grid: 2x;
```

### 202. Shopify Polaris
Merchant-focused commerce patterns, admin-panel systematization, emerald-green confidence, product-card components, order-timeline visualizations.
```css
--green: #008060; --bg: #F6F6F7;
--surface: #FFFFFF; --text: #202223;
--font: "Inter", sans-serif; --radius: 8px;
```

### 203. Ant Design Enterprise
Chinese enterprise design, information-dense table layouts, modal-heavy workflows, blue-dominant system, form-heavy admin panels, i18n-first.
```css
--blue: #1890FF; --bg: #F0F2F5;
--surface: #FFFFFF; --text: rgba(0,0,0,0.85);
--font: "PingFang SC", "Microsoft YaHei", sans-serif; --radius: 2px;
```

### 204. Salesforce Lightning
CRM-blue brand presence, record-page layouts, opportunity-pipeline Kanban, related-list sections, utility-bar dock, admin-config aesthetic.
```css
--blue: #1B96FF; --bg: #F3F3F3;
--surface: #FFFFFF; --text: #181818;
--font: "Salesforce Sans", sans-serif; --radius: 4px;
```

### 205. Atlassian Design System
JIRA-blue task management, purpose-driven illustration, team-collaboration metaphors, sprint-board columns, story-point badges, enterprise-friendly.
```css
--blue: #0052CC; --bg: #FAFBFC;
--surface: #FFFFFF; --text: #172B4D;
--font: "Charlie Display", sans-serif; --radius: 3px;
```

---

## Maximalist & Ornamental (206-212)

### 206. Versace Baroque Palace
Gold-scrollwork borders, Medusa-head medallions, Italian-palazzo ceilings, luxury-excess as brand language, Greek-key repeat patterns.
```css
--gold: #D4AF37; --black: #1A1A1A;
--pattern: url('/baroque-scroll.svg') repeat;
--font: "Bodoni Moda", serif; --border: ornamental 3px;
```

### 207. William Morris Arts & Crafts
Intricate floral wallpaper tiles, medieval-illumination borders, handcraft-revival density, botanical-pattern-as-layout, every surface decorated.
```css
--green: #5A7247; --red: #8B3A3A;
--cream: #F5F0E1; --gold: #C5A55A;
--pattern: url('/morris-strawberry-thief.svg') repeat;
```

### 208. Indian Wedding Card
Mandala pattern borders, gold-foil emboss, paisley cornerpieces, rich jewel-tone palette, celebration typography, dense blessing text.
```css
--maroon: #800020; --gold: #FFD700;
--peacock: #009999; --saffron: #FF6600;
--pattern: mandala; --border: double-line gold;
```

### 209. Wes Anderson Symmetry
Obsessive centered composition, saturated pastel palette, whimsical serif typography, miniature-world framing, dollhouse precision.
```css
--pink: #F4A7BB; --mustard: #D4A843;
--teal: #5AAFA7; --cream: #FFF0DB;
--font: "Futura", sans-serif; --alignment: center-everything;
```

### 210. Dolce & Gabbana Sicilian
Majolica-tile pattern backgrounds, Baroque church gold, Mediterranean-summer maximalism, ornamental ceramic borders, Taormina sunshine.
```css
--tile-blue: #1E3A8A; --tile-yellow: #F59E0B;
--red: #DC2626; --bg: #FFFFF0;
--pattern: url('/majolica-tile.svg') repeat 120px;
```

### 211. Takashi Murakami Superflat
Smiling-flower overload, pop-art density, high-low art collision, flat-but-layered infinity, every pixel occupied, cherry-blossom-meets-anime.
```css
--rainbow: conic-gradient(#FF0000, #FF7F00, #FFFF00, #00FF00, #0000FF, #8B00FF, #FF0000);
--bg: #FFFFFF; --flower: url('/murakami-flower.svg');
--density: maximum; --layer: 5+;
```

### 212. Baz Luhrmann Moulin Rouge
Visual-cacophony editing, period-meets-contemporary collision, musical-montage energy, red-curtain drama, excess-as-narrative, sequin-shimmer overlays.
```css
--red: #8B0000; --gold: #FFD700;
--sequin: radial-gradient(circle 2px, #FFD700 100%, transparent 100%);
--bg: #1A0000; --font: "Playfair Display", serif;
```

---

## Spatial & Immersive 3D Web (213-219)

### 213. Bruno Simon Toybox
Three.js portfolio as playground, drivable 3D car on terrain, interactive physics objects, developer-as-toymaker energy, click-to-launch ramps.
```css
--canvas: fullscreen; --physics: cannon.js;
--shadows: soft; --camera: third-person;
--palette: vibrant-lowpoly;
```

### 214. Lusion Lab Experiments
Experimental WebGL particles, real-time shader art, creative-coding as portfolio, interactive fluid simulations, touch-reactive surfaces.
```css
--canvas: fullscreen; --shader: custom-glsl;
--interaction: mouse-reactive; --particles: gpu-computed;
--bg: #000000;
```

### 215. Active Theory Immersive
Spatial brand experiences, 3D product configurators, experiential-agency showpieces, WebGL-meets-commerce, scroll-driven camera paths.
```css
--render: webgl2; --scroll: camera-dolly;
--lighting: studio-three-point; --materials: pbr;
--performance: lod-switching;
```

### 216. 14islands Stockholm
Swedish craft meets WebGL, thoughtful 3D micro-interactions, warm spatial design, accessible immersion, progressive-enhancement-first.
```css
--canvas: inline; --fallback: static-image;
--interaction: subtle; --performance: 60fps;
--palette: scandinavian-neutral;
```

### 217. Awwwards SOTD Showcase
Award-winning WebGL transitions, buttery smooth-scroll, magnetic cursor interactions, technical showmanship, "Site of the Day" ambition level.
```css
--scroll: locomotive-scroll; --cursor: magnetic;
--transition: page-morph; --animation: gsap-timeline;
--fps: 60-or-nothing;
```

### 218. Apple Product Page Depth
Z-axis product floating, scroll-pinned camera orbit, spec-reveal animations, product-photography-as-3D, "shot on iPhone" confidence.
```css
--canvas: product-viewer; --camera: orbit-on-scroll;
--lighting: dramatic; --bg: #000000;
--model: high-poly; --interaction: drag-rotate;
```

### 219. Resn Playground
New Zealand creative studio, boundary-pushing 3D web, game-like interactions, playful spatial navigation, "we made that" pride.
```css
--canvas: fullscreen; --physics: matter.js;
--interaction: game-like; --audio: reactive;
--palette: bold-primary;
```

---

## Analog & Zine Culture (220-225)

### 220. Risograph Print
Soy-based ink color separation, limited 2-3 spot colors, misregistration-as-feature, halftone dot patterns, print-imperfection charm, Riso-blue + fluorescent-pink.
```css
--blue: #0078BF; --pink: #FF48B0;
--paper: #F5F0E6; --halftone: radial-gradient(circle 1px, currentColor 100%, transparent 100%);
--misregister: translate(1px, -1px); --opacity: multiply;
```

### 221. Rookie Mag Teen Zine
Tavi Gevinson collage aesthetic, sticker-annotation overlays, diary-entry voice, scotch-tape-and-magazine-cutout, adolescent earnestness, handwritten margin notes.
```css
--bg: #FFF5F5; --accent: #FF69B4;
--tape: rgba(255,255,200,0.6); --handwriting: "Caveat", cursive;
--collage: layered; --sticker: rotated 5-15deg;
```

### 222. Emigre Type Specimen
Zuzana Licko typeface designs, experimental editorial layouts, foundry-catalog format, template-as-content, Cranbrook-school influence.
```css
--bg: #FFFFFF; --text: #000000;
--font: "Emigre", serif; --specimen: full-alphabet;
--layout: asymmetric-column; --grid: baseline;
```

### 223. Concert Poster Screenprint
Gig-poster typography, hand-screened spot colors, venue/date details, band-artwork collaboration, limited-edition numbering, music-scene identity.
```css
--ink-1: #2D2D2D; --ink-2: #CC3333;
--ink-3: #D4AF37; --paper: #F0E8D8;
--texture: screenprint-grain; --font: "Chunk Five", serif;
```

### 224. Underground Comix
R. Crumb crosshatch density, counterculture panel layouts, hand-lettered speech bubbles, underground-press energy, Keep On Truckin' linework.
```css
--ink: #000000; --paper: #FFF8DC;
--panel-border: 2px solid #000; --lettering: "Comic Neue", cursive;
--crosshatch: url('/hatch-pattern.svg');
```

### 225. Xerox Zine Library
Photocopied-page grain, cut-and-paste layout chaos, high-contrast Xerox artifacts, DIY publishing, margin annotations, staple-bound spine.
```css
--bg: #F8F8F8; --text: #111111;
--copy-grain: url('/xerox-noise.svg') multiply;
--font: "Courier", monospace; --contrast: 150%;
--layout: paste-up;
```

---

## Selection Guidelines

**For redesign variants, rotate through categories:**
- Don't pick 5 from the same category
- Match aesthetic to client industry/audience
- Consider competitor differentiation
- Test light AND dark modes for each

**Category by project type:**

| Project Type | Best Categories |
|--------------|-----------------|
| SaaS/Tech | Tech & SaaS, Material & Flat, Spatial 3D |
| E-commerce Luxury | Luxury & High-End, Maximalist, Editorial |
| Restaurant/Food | Small Business Vernacular, Retro, Cottagecore |
| Portfolio/Agency | Creative & Agency, Experimental, Spatial 3D |
| Local Business | Small Business Vernacular, Retro, Analog & Zine |
| Finance | Tech & SaaS, Material & Flat, Editorial |
| Healthcare | Neumorphism, Biophilic, Material & Flat |
| Entertainment | Synthwave, Cyberpunk, Y2K Revival, Kawaii |
| Wellness/Fitness | Neumorphism, Biophilic, Corporate Memphis |
| Education | Dark Academia, Material & Flat, Cultural |
| Gaming | Cyberpunk, Synthwave, Kawaii, Isometric |
| Food & Beverage | Small Business Vernacular, Cottagecore, Biophilic |
| Fashion | Luxury, Maximalist, Macro Typography |
| Non-Profit | Biophilic, Corporate Memphis, Editorial |
| Music/Events | Analog & Zine, Synthwave, Macro Typography |
| Real Estate | Glassmorphism, Luxury, Neumorphism |

**Never default to:**
- Minimal Editorial + Bold Playful + Mountain Modern + Warm Community + Tech Forward

These 5 are banned as a set. Pick from the full 225.
