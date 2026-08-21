# Frames — Design System & Brand Guidelines
**Version:** 1.0.0  
**Target Ecosystem:** macOS 13+ (Ventura, Sonoma, Sequoia) & Web  
**Primary Brand Identity:** Electric Blue (`#0302FF`) → Midnight Abyss (`#000031`) with `Sen` Typography

---

## 1. Brand Essence & Visual Language

Frames is precision-engineered, ultra-lightweight, and clutter-free. The visual identity draws directly from the **App Icon**:
- **Viewfinder Geometry:** Precision rounded framing brackets, clean minimalist strokes, balanced optical weight.
- **Deep Atmospheric Space:** Deep midnight navy `#000031` backgrounds with subtle, focused electric blue `#0302FF` radiance and glows.
- **Apple HIG + Bespoke Edge:** Blends native macOS materials (`.ultraThinMaterial`, `NSVisualEffectView`, SF Symbols) with a distinctive, high-end electric blue brand signature.

```
       ┌──────────────────────────────────────────────┐
       │  App Icon Palette:                           │
       │  #000031 (Midnight) ───► #0302FF (Electric)  │
       │  Accent: #3D3BFF  │ Text: #F8FAFC            │
       └──────────────────────────────────────────────┘
```

---

## 2. Color Tokens

### Primary Brand Palette
| Token | Hex | Role | Usage |
|---|---|---|---|
| `brand-midnight` | `#000031` | Brand Base / Darkest Point | App icon top gradient, deep dark page backgrounds, dark modal base. |
| `brand-electric` | `#0302FF` | Brand Primary | App icon bottom gradient, primary CTA buttons, active states, key glows. |
| `brand-glow` | `#3D3BFF` | Brand Accent / Highlight | Button hover highlights, focus rings, subtle radial backdrop glows. |
| `brand-tint-10` | `rgba(3, 2, 255, 0.10)` | Brand Tint / Wash | Active tab backgrounds, selected hotkey cell, hover card wash. |
| `brand-tint-20` | `rgba(3, 2, 255, 0.20)` | Brand Border Accent | Highlighted card borders, active input focus glow. |

### Neutrals (Dark Mode First / Native macOS Dark)
| Token | Hex / RGBA | Role | Usage |
|---|---|---|---|
| `surface-canvas` | `#080811` | Background Canvas | Website page background, behind native transparent materials. |
| `surface-card` | `rgba(18, 18, 30, 0.75)` | Card Surface | Floating corner preview cards, settings window panels, feature cards. |
| `surface-card-hover` | `rgba(28, 28, 48, 0.85)` | Card Hover Surface | Hovered preview card, hovered settings row. |
| `surface-overlay` | `rgba(8, 8, 20, 0.85)` | Overlay / Modal | Expanded modal backdrop, marquee guide overlay. |
| `border-subtle` | `rgba(255, 255, 255, 0.08)` | Default Border | Card 1px borders, dividers, tab bar borders. |
| `border-hover` | `rgba(255, 255, 255, 0.18)` | Hover Border | Card hover state, button secondary hover. |
| `border-accent` | `rgba(3, 2, 255, 0.40)` | Focus / Brand Border | Active hotkey recording, selected tab highlight. |

### Text & Icon Hierarchy
| Token | Hex / RGBA | Contrast Ratio | Usage |
|---|---|---|---|
| `text-primary` | `#F8FAFC` | High (16:1+) | Headings, primary button labels, active card text. |
| `text-secondary` | `#94A3B8` | Medium (7:1+) | Body text, descriptions, inactive tab labels, subtitles. |
| `text-tertiary` | `#64748B` | Low (4.5:1+) | Keyboard shortcut hints, metadata, footer notes, timestamps. |
| `text-brand` | `#5B5AFF` | Accent | Brand highlights, feature chips, active links. |

### Semantic & Feedback States
| State | Color | Background Tint | Usage |
|---|---|---|---|
| **Success** | `#10B981` (Emerald) | `rgba(16, 185, 129, 0.12)` | "Saved to Desktop" toast, clipboard copied confirmation. |
| **Warning** | `#F59E0B` (Amber) | `rgba(245, 158, 11, 0.12)` | 5-slot stack capacity warning, conflict alert. |
| **Error / Destructive** | `#EF4444` (Rose) | `rgba(239, 68, 68, 0.12)` | Delete/Cancel action, permission denied badge. |
| **Timer / Progress** | `#0302FF` ➔ `#10B981` | `rgba(255, 255, 255, 0.06)` | 60s countdown progress ring on corner preview card. |

---

## 3. Typography (`Sen`)

The brand font across Web and Desktop overlays is **Sen** (Google Fonts / Geometric Sans). For native macOS system text where native SF is preferred, Sen is used for brand headers, titles, and branding accents.

### Type Scale
| Level | Font Size | Line Height | Weight | Tracking | Usage |
|---|---|---|---|---|---|
| **Display (Web)** | `48px` - `56px` | `1.1` | Bold (`700`) | `-0.02em` | Hero main headline |
| **H1** | `32px` - `36px` | `1.2` | Bold (`700`) | `-0.015em` | Section headers, major modal titles |
| **H2** | `24px` - `28px` | `1.25` | SemiBold (`600`) | `-0.01em` | Feature card titles, Settings section headers |
| **H3** | `18px` - `20px` | `1.3` | SemiBold (`600`) | `0em` | Card titles, modal subheads, tab labels |
| **Body Large** | `16px` | `1.5` | Regular (`400`) / Medium (`500`) | `0em` | Hero lead paragraph, feature intros |
| **Body Default** | `14px` | `1.45` | Regular (`400`) | `0em` | Default UI text, settings rows, descriptions |
| **Caption / Small** | `12px` | `1.4` | Medium (`500`) | `+0.01em` | Badges, shortcut key caps, timers, metadata |
| **Micro** | `10px` - `11px` | `1.3` | SemiBold (`600`) | `+0.03em` | Status indicators, uppercase pill tags |

---

## 4. Spacing & Radius System

### Spacing Scale (8pt Grid Standard)
```
  2px (2xs) │ 4px (xs) │ 8px (sm) │ 12px (md) │ 16px (lg) │ 24px (xl) │ 32px (2xl) │ 48px (3xl) │ 64px (4xl)
```

### Corner Radius Tokens
| Token | Value | Applied To |
|---|---|---|
| `radius-sm` | `6px` | Keyboard shortcut keycaps, micro badges, tooltips. |
| `radius-md` | `10px` | Secondary buttons, text inputs, segmented tab items. |
| `radius-lg` | `14px` | Primary CTA buttons, settings panel inner cards. |
| `radius-xl` | `20px` | Floating corner preview cards, settings window shell, feature cards. |
| `radius-2xl` | `28px` | Hero modal containers, app icon squircle geometry. |
| `radius-pill` | `9999px` | Notification chips, status pills, floating action pills. |

---

## 5. UI Component Specifications

### 5.1 Primary Button (Electric Glow)
- **Background:** Linear gradient: `linear-gradient(135deg, #0302FF 0%, #000031 100%)`
- **Border:** `1px solid rgba(255, 255, 255, 0.20)`
- **Shadow:** `0 4px 16px rgba(3, 2, 255, 0.35), 0 1px 2px rgba(0, 0, 0, 0.4)`
- **Hover:** Brightens to `#3D3BFF` glow, subtle scale `1.02`, shadow expands `0 6px 24px rgba(3, 2, 255, 0.50)`.
- **Active:** Scale `0.98`, shadow dims.
- **Typography:** Sen SemiBold 14px/16px, `#FFFFFF`.

### 5.2 Secondary / Glass Button
- **Background:** `rgba(255, 255, 255, 0.05)` with `backdrop-filter: blur(12px)`.
- **Border:** `1px solid rgba(255, 255, 255, 0.10)`.
- **Hover:** Background `rgba(255, 255, 255, 0.10)`, border `rgba(255, 255, 255, 0.22)`.
- **Active:** Background `rgba(255, 255, 255, 0.04)`.

### 5.3 Floating Screenshot Preview Card (Corner Stack)
- **Container:** `280px` (or scaled preview) with `20px` radius.
- **Material:** Ultra-thin glass backdrop (`rgba(10, 10, 24, 0.82)` + `backdrop-filter: blur(20px)`).
- **Border:** `1px solid rgba(255, 255, 255, 0.12)`.
- **Corner Accent:** Subtle rounded viewfinder brackets reflecting the App Icon.
- **Actions Bar:**
  - `Copy` (Primary, clipboard icon + "Copy").
  - `Save` (Secondary, arrow down icon + "Save").
  - `Dismiss (X)` (Subtle close icon on top right hover).
- **Timer Arc:** 60-second circular stroke or progress bar in `#0302FF` fading to `#10B981`.

### 5.4 Segmented Tabs (Settings Window & Web)
- **Track:** `rgba(255, 255, 255, 0.04)`, `8px` padding/radius.
- **Active Tab:** `rgba(3, 2, 255, 0.25)` fill with `1px solid rgba(3, 2, 255, 0.45)` + `#FFFFFF` text.
- **Inactive Tab:** Transparent fill + `#94A3B8` text, hover `#CBD5E1`.

### 5.5 Settings Window ("About This Mac" standard size ~ 520 x 400 pt)
- **3 Tab Navigation:**
  1. `Hotkeys`: Sleek key recording pills (`⌥ 1`, `⌥ 2`, `⌥ 3`) with instant recording state.
  2. `General`: Launch at login toggle, auto-save destination (`~/Desktop`), sound toggles.
  3. `Support`: Direct GitHub link, star widget, version info, developer feedback.
- **Consistency:** All 3 tabs share the same 14px card padding, 1px subtle borders, and Sen typography.

---

## 6. Do's & Don'ts

### Do:
- **Do** use the `#0302FF` → `#000031` gradient as an intentional focal point (Hero buttons, active indicators, App Icon framing, subtle radial glows).
- **Do** maintain generous padding (minimum 16px inside cards, 24px-32px between sections).
- **Do** keep cards semi-translucent with backdrop blur for that unmistakable native macOS / high-end software feel.
- **Do** use crisp SF Symbols or clean 1.5px stroke vector icons matching the App Icon's weight.

### Don't:
- **Don't** flood entire screen backgrounds with solid bright `#0302FF` (causes eye fatigue; use deep midnight `#000031` / `#080811` as canvas, with electric blue for lights and gradients).
- **Don't** use generic sharp corners (all elements must use the rounded radius tokens `10px`–`20px` matching the App Icon).
- **Don't** mix multiple conflicting fonts (stick exclusively to `Sen` for brand/web, supplemented by native San Francisco for low-level OS menus where mandatory).
- **Don't** add clutter or unnecessary badges (keep the UI as lean and fast as the tool itself).
