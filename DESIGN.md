---
name: Campus Escape
colors:
  surface: '#0B1220'
  surface-dim: '#070E1C'
  surface-bright: '#2A3850'
  surface-container-lowest: '#070E1C'
  surface-container-low: '#0F1829'
  surface-container: '#131C2E'
  surface-container-high: '#1B2740'
  surface-container-highest: '#232E45'
  on-surface: '#F1F5F9'
  on-surface-variant: '#C3CCDB'
  inverse-surface: '#F1F5F9'
  inverse-on-surface: '#0B1220'
  outline: '#2A3850'
  outline-variant: '#1B2740'
  surface-tint: '#F5A524'
  primary: '#F5A524'
  on-primary: '#0B1220'
  primary-container: '#D98E19'
  on-primary-container: '#0B1220'
  inverse-primary: '#835400'
  secondary: '#2DD4BF'
  on-secondary: '#0B1220'
  secondary-container: '#113A36'
  on-secondary-container: '#5EEAD4'
  tertiary: '#A78BFA'
  on-tertiary: '#0B1220'
  tertiary-container: '#2A2145'
  on-tertiary-container: '#D8CAFF'
  error: '#FDA4AF'
  on-error: '#0B1220'
  error-container: '#3A1D22'
  on-error-container: '#FDA4AF'
  primary-fixed: '#FFDDB5'
  primary-fixed-dim: '#F5A524'
  on-primary-fixed: '#2A1800'
  on-primary-fixed-variant: '#643F00'
  secondary-fixed: '#62FAE3'
  secondary-fixed-dim: '#2DD4BF'
  on-secondary-fixed: '#00201C'
  on-secondary-fixed-variant: '#005047'
  tertiary-fixed: '#E8DDFF'
  tertiary-fixed-dim: '#A78BFA'
  on-tertiary-fixed: '#21005E'
  on-tertiary-fixed-variant: '#4F319C'
  background: '#0B1220'
  on-background: '#F1F5F9'
  surface-variant: '#1B2740'
typography:
  display-timer:
    fontFamily: Space Grotesk
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
  headline-sm:
    fontFamily: Space Grotesk
    fontSize: 18px
    fontWeight: '700'
    lineHeight: 24px
  number-sm:
    fontFamily: Space Grotesk
    fontSize: 14px
    fontWeight: '700'
    lineHeight: 16px
  body-lg:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  body-md:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  body-sm:
    fontFamily: Manrope
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-section:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.12em
  label-btn:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '700'
    lineHeight: 20px
  label-badge:
    fontFamily: Manrope
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.04em
  label-nav:
    fontFamily: Manrope
    fontSize: 10px
    fontWeight: '700'
    lineHeight: 12px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 0.875rem
  xl: 1rem
  2xl: 1.125rem
  full: 9999px
spacing:
  gutter: 0.625rem
  margin: 1.5rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

Campus Escape is an in-app escape-room game for high-school visitors (15–18) exploring the School of Computer Science. The UI is **Technical Flat / Terminal Brutalism**: a dark navy canvas, razor-sharp color zoning, one warm accent for action, one cool accent for progress, crisp 1px outlines, and monoline Lucide icons. No skeuomorphism, no gradients, no glow, no raster photography, no emoji.

Voice and tone: casual, direct, energetic Bahasa Indonesia ("Mulai Misi", "Pintu Terbuka", "Cek Jawaban"). Emotional target: curiosity, urgency, logical accomplishment, technical empowerment without intimidation.

## Colors

Dark mode only. The token map above follows Material naming so Stitch and Flutter `ColorScheme` can consume it directly; the mapping that matters for implementation:

- **primary `#F5A524` (amber)** is the only "press here" color: primary buttons, active room border, "Lanjut" badge, active nav item, active slot/selection outline. Text and icons on amber are always `on-primary #0B1220`. Pressed state uses `primary-container #D98E19`.
- **secondary `#2DD4BF` (teal)** is progress and verification: progress bars, timer, completed-room check, solved-puzzle banner (`secondary-container #113A36` with text `#5EEAD4`), the teal "Pintu terbuka — lanjut" button.
- **tertiary `#A78BFA` (violet)** is reserved for Bonus Room 9 (AI & ML).
- **error `#FDA4AF`** for wrong-answer banners (`error-container #3A1D22`), critical timer (< 5 min), and destructive actions.
- **Surfaces**: canvas `surface #0B1220`; resting cards `surface-container #131C2E` with border `outline #2A3850`; active/raised cards `surface-container-high #1B2740`; bottom nav and locked bonus cards `surface-container-low #0F1829`. Borders are always cool navy, never warm or beige.

### Extended tokens (not in the Material map, use by hex)

| Token | Hex | Usage |
|---|---|---|
| `text-muted` | `#9AA8BF` | Captions, section labels, metadata |
| `text-disabled` | `#6B7A94` | Locked room text, empty-slot placeholder, inactive nav |
| `warning` / `warning-surface` | `#FBBF24` / `#2A2235` | "Slot masih kosong" banner |
| `bonus-cyber` | `#F97316` | Bonus Room 10 (Cyber Security) accent |

### Room accents (10 disciplines)

Used **only** for (1) the 3px top stripe on the room card and (2) the stroke tint of the room icon and the active drag/selection outline inside that room. Never as a button fill, card background, or UI chrome.

| # | Room | Accent |
|---|---|---|
| 1 | Algoritma & Logika | `#60A5FA` |
| 2 | UI/UX Design | `#F472B6` |
| 3 | Data Science | `#38BDF8` |
| 4 | Game Development | `#E879F9` |
| 5 | Mobile App Development | `#A3E635` |
| 6 | Jaringan Komputer | `#FB7185` |
| 7 | Software Engineering | `#818CF8` |
| 8 | Database Systems | `#FACC15` |
| 9 | AI & Machine Learning (bonus) | `#A78BFA` |
| 10 | Cyber Security (bonus) | `#F97316` |

## Typography

Space Grotesk 700 for headlines, room numbers, step trackers, passcodes and clocks; Manrope 400/500/700 for briefings, button copy, hints and navigation. Timers and counters use tabular figures so digits never jitter. Section headers always use `label-section` in `text-muted`, uppercase.

## Layout & Spacing

Target viewport 390×844, single-handed use with primary actions in the lower thumb zone. Horizontal canvas padding is a strict 24px. Vertical rhythm: 8–10px between cards in a grid, 14–20px between stacked sections. Bottom navigation is a pinned solid `#0F1829` bar, 68px plus safe area, with five items: **Home, Peta, Galeri, Peringkat, Profil**. It appears only on those five hub screens; room screens never show it. Critical actions ("Cek Jawaban", "Buka Brankas") dock to the bottom with 16px padding above the safe area.

## Elevation & Depth

No drop shadows, ambient shadows or blur. Depth is flat surface layering plus 1px borders: canvas `#0B1220` → resting card `#131C2E` + `#2A3850` border → raised card `#1B2740` + `#F5A524` or `#2DD4BF` border depending on focus type. Modals are solid `#131C2E` with a 1.5px `#2A3850` border over an 80% `#0B1220` scrim.

## Shapes

Room and content cards 14–16px radius (top accent stripe inherits the top radius). Primary and secondary buttons 16px. Icon buttons 44×44 with 12–14px radius. Pills, chips and progress tracks fully rounded. Inputs 50–52px tall, 12–14px radius. Passcode cells 48×56, 10px radius.

## Components

- **Primary Button**: 54px, `#F5A524`, radius 16, `label-btn` in `#0B1220`, full width. Pressed `#D98E19`. Success variant `#2DD4BF` after a puzzle is solved.
- **Secondary Button**: 48px, background `#131C2E`, border 1px `#2A3850`, radius 14, text `#F1F5F9` 14/600. (Ghost/transparent variant allowed on dark hero sections only.)
- **Icon Button**: 44×44, `#131C2E`, border `#2A3850`, radius 14, 20–24px stroke icon.
- **Room Card**: `#131C2E`, border `#2A3850`, radius 14, padding 12, min height 96 in a 2-column grid; 3px top stripe in the room accent; status badge top-right (pill, 11px uppercase). States: Selesai (border `#1F5F58`, teal check, "Selesai · mm:ss"), Aktif (`#1B2740`, border `#F5A524`, amber "Lanjut" badge), Terbuka (default border, "Terbuka"), Terkunci (lock icon, text `#6B7A94`, opacity 0.6).
- **Puzzle Slot**: 48px, radius 14. Empty: dashed `#2A3850` on `#0F1829`, placeholder "Taruh tahapan di sini". Filled: border `#F5A524` on `#1B2740`, numbered chip in amber, clear (x) control.
- **Drag Chip**: 44px pill, `#131C2E`, border `#2A3850`, grip icon + label; while dragging, border in the room accent.
- **Status Banner**: radius 12, 13/600; success `#113A36`/`#5EEAD4`, warning `#2A2235`/`#FBBF24`, error `#3A1D22`/`#FDA4AF`.
- **Passcode Input**: 4–6 cells 48×56, `#131C2E`, border 1.5px `#2A3850`, radius 10; focused cell border `#F5A524`, no glow.
- **Progress & Timer**: 6–8px rail `#1B2740` filled solid `#2DD4BF`; segmented variant (10 segments) on Home. Clock in `display-timer` or `number-sm`, teal; flips to `#FDA4AF` under 5 minutes.
- **Icons**: Lucide stroke icons, 2px stroke, 20–24px. No illustrated stickers or multi-tone assets.
