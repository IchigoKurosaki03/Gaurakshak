---
name: GauRakshak Design System
colors:
  surface: '#f2fcef'
  surface-dim: '#d3ddd0'
  surface-bright: '#f2fcef'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#ecf7ea'
  surface-container: '#e6f1e4'
  surface-container-high: '#e1ebde'
  surface-container-highest: '#dbe5d9'
  on-surface: '#151e16'
  on-surface-variant: '#404941'
  inverse-surface: '#29332a'
  inverse-on-surface: '#e9f4e7'
  outline: '#717971'
  outline-variant: '#c0c9bf'
  surface-tint: '#306945'
  primary: '#034525'
  on-primary: '#ffffff'
  primary-container: '#235d3a'
  on-primary-container: '#97d4a8'
  inverse-primary: '#98d4a8'
  secondary: '#56615b'
  on-secondary: '#ffffff'
  secondary-container: '#dae5dd'
  on-secondary-container: '#5c6761'
  tertiary: '#3d3b35'
  on-tertiary: '#ffffff'
  tertiary-container: '#54524b'
  on-tertiary-container: '#cac5bd'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#b3f1c3'
  primary-fixed-dim: '#98d4a8'
  on-primary-fixed: '#00210e'
  on-primary-fixed-variant: '#15512f'
  secondary-fixed: '#dae5dd'
  secondary-fixed-dim: '#bec9c2'
  on-secondary-fixed: '#141e19'
  on-secondary-fixed-variant: '#3f4943'
  tertiary-fixed: '#e7e2d9'
  tertiary-fixed-dim: '#cac6be'
  on-tertiary-fixed: '#1d1c16'
  on-tertiary-fixed-variant: '#494740'
  background: '#f2fcef'
  on-background: '#151e16'
  surface-variant: '#dbe5d9'
  brand-forest-dark: '#1A4D2E'
  surface-cream: '#F9F8F3'
  status-healthy: '#2E7D32'
  status-healthy-surface: '#EAF5EA'
  status-monitor: '#E67E22'
  status-monitor-surface: '#FEF5E7'
  status-atrisk: '#D9534F'
  status-atrisk-surface: '#FDF2F2'
  connectivity-online: '#2E7D32'
  connectivity-syncing: '#2980B9'
  connectivity-offline: '#7F8C8D'
typography:
  display:
    fontFamily: Manrope
    fontSize: 36px
    fontWeight: '800'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Manrope
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Manrope
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
  headline-sm:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  metric-numeral:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 38px
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 22px
  body-sm:
    fontFamily: Hanken Grotesk
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: Hanken Grotesk
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Hanken Grotesk
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Hanken Grotesk
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  space-xxs: 0.25rem
  space-xs: 0.5rem
  space-sm: 0.75rem
  space-md: 1rem
  space-lg: 1.25rem
  space-xl: 1.5rem
  space-2xl: 2rem
  space-3xl: 3rem
  touch-target-min: 3rem
  touch-target-comfortable: 3.375rem
  page-margin-mobile: 1rem
  card-padding: 1.25rem
  grid-gutter: 1rem
---

## Brand & Style

### Personality & Mission
The design system powers an intuitive, farmer-first cattle health and milk monitoring experience. Its personality is warm, trustworthy, agricultural, simple, modern, human, and deeply practical. It completely eschews clinical or cold IoT laboratory dashboards in favor of an approachable digital farm assistant that feels dependable under bright outdoor sunlight.

### Target Audience & Core Interaction Rule
Built specifically for dairy farmers, field operators, and agricultural managers operating in variable farm lighting conditions, often using single-handed gestures or wearing work gloves. The foundational ethos is: *"Scan the cow. Let the system do the work. Show the farmer what matters."* 

Every flow emphasizes minimal typing, clear status indications with dual icon-and-text cues, large tactile buttons, and non-alarmist early-warning terminology that recommends veterinary checks rather than claiming definitive diagnosis.

### Design Movement & Tactile Language
The system adopts an **Elevated Tactile Agri-Tech** aesthetic:
- **Rich Organic Foundations:** Deep forest foliage greens grounded by unbleached, soothing milk-white and cream container tones.
- **Physical Clarity:** High contrast typography, generous 52px+ touch targets, and tactile rounded surfaces (16px base radius) paired with crisp hairline borders for structural definition.
- **Daylight Legibility:** Deep slate body typography set against warm tinted neutrals ensures total visibility without optical glare in outdoor daylight.

## Colors

### Color Hierarchy & System Roles
The color strategy balances grounding agricultural greens with creamy neutral substrates and clear, unambiguous status alerts:

- **Primary (`#235D3A`) & Brand Forest Dark (`#1A4D2E`):** Represents vitality, pasture stability, and dependable stewardship. Used for primary CTAs ("Start Milking", "Confirm"), active state indicators, primary app bars, and high-emphasis brand elements.
- **Secondary (`#E8F3EB`):** A soft, muted mint container fill that recedes comfortably, utilized for sub-headers, highlighted data chips, and passive card backgrounds.
- **Tertiary (`#F4EFE6`) & Surface Cream (`#F9F8F3`):** Replaces harsh stark whites with warm dairy cream and unbleached calico undertones to prevent outdoor eye strain and deliver a welcoming, physical feel.
- **Neutral Dark (`#1C251D`):** Deep warm charcoal slate delivering AAA-compliant legibility across text hierarchies. Avoids pure harsh `#000000`.

### Health & Warning Triad (Strictly Non-Clinical Early Warnings)
Status must always pair designated hues with descriptive icons and legible text—never relying on color alone:
- **Healthy (`#2E7D32`, Surface: `#EAF5EA`):** Deep pasture green indicating normal milk yield, stable vitals, and normal recovery.
- **Monitor (`#E67E22`, Surface: `#FEF5E7`):** Warm amber signaling emerging variances or caution (e.g., slight yield decrease over 48 hours).
- **At Risk (`#D9534F`, Surface: `#FDF2F2`):** Soft terracotta crimson indicating urgent prompt for physical cow inspection or veterinary follow-up.

### Hardware & Connectivity Signals
- **Online (`#2E7D32`):** Sensor stream synchronized.
- **Syncing (`#2980B9`):** Cached local farm records uploading to the central cloud.
- **Offline / Sync Pending (`#7F8C8D`):** Full local offline functionality operational without panic.

## Typography

### Font Pairing Strategy
- **Headlines & Metrics (Manrope):** Geometric, sturdy, and authoritative. Manrope’s clear numerals provide instant reading for vital stats (e.g., `8.7 L`, `COW-024`) from arm's length in field conditions.
- **Body & Controls (Hanken Grotesk):** Clean, neo-grotesque sans-serif offering tall x-height and open apertures. Retains distinct character definition even on low-cost Android displays under high sunlight glare.

### Visual Hierarchy & Field Readability
1. **Cow Name First:** The farmer-assigned cow name ("Gauri") is treated with `headline-lg` or `headline-md`, anchoring emotional identification, while the ear tag/hardware tag (`COW-024`) is rendered in subordinate `label-md` or `body-sm`.
2. **Actionable Alerts Over Sensor Noise:** Alerts prioritize conversational summaries over raw metrics. Headlines state the reality clearly, supported by concise body text detailing recommended action.
3. **Numerals:** All milk yield metrics and counts use `metric-numeral` with tabular numbers enabled to prevent card jitter during live updates.

## Layout & Spacing

### Layout Philosophy
This design system uses a fluid single-column mobile-first layout (scaling smoothly up to centered sheet constraints on tablets). It strictly enforces a 4px/8px base spatial grid. 

Because milk sheds and field environments require swift interactions with wet or dusty hands, all touchable interactive areas maintain an absolute minimum height of 48px (`touch-target-min`), expanding to 54px (`touch-target-comfortable`) for primary operational buttons like "Start Milking".

### Breakpoints & Adaptive Strategy
- **Mobile (< 600px):** 1-column fluid stacking. Sticky bottom navigation with 5 primary destinations (`Home`, `Cows`, `Milk`, `Alerts`, `More`). Page gutter is fixed at `16px` (`space-md`), and cards span full safe width.
- **Tablet / Rugged Field Handheld (600px - 1024px):** 2-column balanced grid with `16px` gutters. Cow lists sit side-by-side with the active cow profile or milking session preview. Maximum layout width caps at `720px` for optimal single-thumb reachability.

## Elevation & Depth

### Atmospheric Farm Tonal Elevation
In bright sunlight, blurred drop shadows wash out and lose functional utility. The design system uses **Tonal Layering with Crisp Hairline Outlines** rather than dramatic shadow blur:

- **Level 0 (App Canvas):** Background rendered in `surface-cream` (`#F9F8F3`). Flat, non-reflective.
- **Level 1 (Default Card):** Background `#FFFFFF` or `muted-mint` (`#E8F3EB`), bordered by a subtle 1px stroke of `rgba(28, 37, 29, 0.08)`. Supported by an ultra-soft ground shadow: `0px 2px 4px rgba(28, 37, 29, 0.04)`.
- **Level 2 (Interactive Cards & Active Sessions):** Background `#FFFFFF` with 1.5px border tint matching the card's context (e.g., Primary `#235D3A` or Warning `#E67E22`). Elevation: `0px 4px 12px rgba(28, 37, 29, 0.08)`.
- **Level 3 (Modals, Action Sheets & Sticky Scan Bars):** Floating surfaces elevated with `0px 8px 24px rgba(28, 37, 29, 0.12)`, topped with a 3px pill grab-handle.

## Shapes

### Shape Language & Curvature Strategy
The interface communicates approachability, organic warmth, and ergonomic ease via roundedness tier `2`:
- **Cards & Data Modules:** `16px` radius (`rounded-lg`) ensuring a soft, inviting boundary that protects screen content from feeling mechanical.
- **Primary Touch CTAs & Inputs:** `16px` to match card ergonomics, retaining solid structural form.
- **Status Badges, Chips & Progress Indicators:** Fully pill-shaped (`9999px`) to immediately denote them as metadata tags rather than tap targets.
- **Cow Avatar / Photo Enclosures:** Rounded squircle with `16px` radius or circular `9999px` clip with a 2px inner border to neatly frame camera captures.

## Components

### Buttons
- **Primary Button ("Start Milking", "Verify"):** Min height 54px. Full-width or inline-expanded. Solid `#235D3A` background, pure white bold text (`label-lg`), 16px corner radius. On press, scales down slightly (0.98x) with a deep `#1A4D2E` feedback overlay.
- **Secondary / Action Button ("Check Cow", "View Details"):** 48px height. Background `#E8F3EB`, text `#1A4D2E`, zero shadow, 1px border `rgba(35, 93, 58, 0.15)`.
- **Destructive / Caution Button:** Background `#FDF2F2`, text `#D9534F`, 1px border `rgba(217, 83, 79, 0.2)`.

### Cards & Herd Tile Containers
- **Cow Profile Card:** Top row highlights the cow's photo (56x56px rounded squircle) alongside "Gauri" (`headline-md`) with subtext "Tag: COW-024 • Gir Cross". The right side nests a dual Icon+Label status pill (e.g., "● Monitor"). Bottom section provides 2 clean data cells: Today's Milk (`8.7 L`) and Trend (`↓ Decreasing`).
- **Alert Card:** Distinctive left border strip (4px width) colored according to severity (`#E67E22` or `#D9534F`). Headline summarizes the condition simply ("Gauri needs attention"). Body prescribes the farm action ("Mastitis risk has increased over 2 days. Check udder inflammation."). Bottom contains a primary direct action button ("Check Cow").

### Status & Risk Badges
- Strictly combines a distinct vector glyph with uppercase text.
- **Healthy:** `#EAF5EA` background, `#2E7D32` text, Checkmark icon.
- **Monitor:** `#FEF5E7` background, `#E67E22` text, Triangle Warning icon.
- **At Risk:** `#FDF2F2` background, `#D9534F` text, Octagon Alert icon.

### Form Inputs & OTP Verification
- **Text & Number Fields:** Large 52px input containers with 16px radius, neutral cream fill (`#F4EFE6`), `#1C251D` text. Clear floating label in Hanken Grotesk.
- **OTP Module:** 4 to 6 discrete large boxed digits (56x56px), auto-focusing next cell with high-contrast active green border.

### Connectivity & Sync Header Bar
- A persistent, compact horizontal pill pinned near the top or header area:
  - **Synced:** Green dot + "All records updated".
  - **Syncing:** Animated blue dual-arrow + "Syncing 2 sessions...".
  - **Offline:** Grey cloud icon + "Offline • Saved on device".

### Timeline & Milking Session States
- **Cow Timeline:** Vertical line in `rgba(28, 37, 29, 0.12)` connected by 12px status nodes. Each entry highlights Date, Milk Volume (`8.7 L`), Event Type (Vaccination, Calving, Milk drop), and note.
- **Milking Active Session Banner:** Clean live state card showing pulsing green dot ("Sensor connected"), cow name verified, and large button ("Finish Session").