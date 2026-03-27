# STYLE.md — Suomen Palikkaharrastajat ry Design System

Agent/developer reference for the brand CSS. Read this before authoring or modifying any consumer project's CSS.

---

## 1. `@theme` block (canonical tokens)

Copy this verbatim into any consumer project's main CSS file (after `@import "tailwindcss"`):

```css
@theme {
  /* ── Brand core ─────────────────────────────────────── */
  --color-brand:              #05131D;
  --color-brand-yellow:       #FAC80A;
  --color-brand-red:          #C91A09;

  /* ── Nougat palette ─────────────────────────────────── */
  --color-brand-nougat-light: #F6D7B3;
  --color-brand-nougat:       #D09168;
  --color-brand-nougat-dark:  #AD6140;

  /* ── Semantic text ──────────────────────────────────── */
  --color-text-primary: #05131D;
  --color-text-on-dark: #FFFFFF;
  --color-text-muted:   #6B7280;
  --color-text-subtle:  #9CA3AF;

  /* ── Semantic backgrounds ───────────────────────────── */
  --color-bg-page:   #FFFFFF;
  --color-bg-dark:   #05131D;
  --color-bg-subtle: #F9FAFB;
  --color-bg-accent: #FAC80A;

  /* ── Semantic borders ───────────────────────────────── */
  --color-border-default: #E5E7EB;
  --color-border-brand:   #05131D;

  /* ── Typography ─────────────────────────────────────── */
  --font-sans: "Outfit", system-ui, sans-serif;

  /* ── Motion ─────────────────────────────────────────── */
  --duration-fast: 150ms;
  --duration-base: 300ms;
  --duration-slow: 500ms;
  --ease-standard:   cubic-bezier(0.4, 0.0, 0.2, 1.0);
  --ease-decelerate: cubic-bezier(0.0, 0.0, 0.2, 1.0);
  --ease-accelerate: cubic-bezier(0.4, 0.0, 1.0, 1.0);
}
```

---

## 2. `@utility type-*` blocks (typography scale)

```css
@utility type-display     { font-size: 3rem;    font-weight: 700; line-height: 1.1;  letter-spacing: -0.02em; }
@utility type-h1          { font-size: 1.875rem; font-weight: 700; line-height: 1.2;  letter-spacing: -0.01em; }
@utility type-h2          { font-size: 1.5rem;   font-weight: 700; line-height: 1.3;  }
@utility type-h3          { font-size: 1.25rem;  font-weight: 600; line-height: 1.35; }
@utility type-h4          { font-size: 1.125rem; font-weight: 600; line-height: 1.4;  }
@utility type-body        { font-size: 1rem;     font-weight: 400; line-height: 1.6;  }
@utility type-body-small  { font-size: 0.875rem; font-weight: 500; line-height: 1.5;  }
@utility type-caption     { font-size: 0.875rem; font-weight: 400; line-height: 1.4;  letter-spacing: 0.02em; }
@utility type-mono        { font-size: 0.875rem; font-weight: 400; line-height: 1.6;  font-family: ui-monospace, monospace; }
@utility type-overline    { font-size: 0.75rem;  font-weight: 600; line-height: 1.4;  text-transform: uppercase; letter-spacing: 0.08em; }
```

Usage: apply the class name directly, e.g. `class="type-h2"`. Do **not** use raw Tailwind like `text-2xl font-bold`.

---

## 3. Required `@layer base` rules

```css
@layer base {
  body {
    font-family: var(--font-sans);
  }
}
```

---

## 4. Required `@font-face` block

**Local variant** (for projects that host the font):
```css
@font-face {
  font-family: "Outfit";
  src: url("fonts/Outfit-VariableFont_wght.ttf") format("truetype");
  font-weight: 100 900;
  font-style: normal;
  font-display: swap;
}
```

**CDN variant** (for projects that load from the logo site):
```css
@font-face {
  font-family: "Outfit";
  src: url("https://logo.palikkaharrastajat.fi/fonts/Outfit-VariableFont_wght.ttf") format("truetype");
  font-weight: 100 900;
  font-style: normal;
  font-display: swap;
}
```

Add `<link rel="preconnect" href="https://logo.palikkaharrastajat.fi">` to `<head>` when using the CDN variant.

---

## 5. Required reduced-motion rule

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
  .logo-animated {
    display: none;
  }
}
```

---

## 6. Semantic token reference

| Token | Tailwind v4 utility | When to use |
|-------|---------------------|-------------|
| `--color-brand` (#05131D) | `bg-brand` / `text-brand` / `border-brand` | Primary brand colour; use for brand-coloured elements |
| `--color-brand-yellow` (#FAC80A) | `bg-brand-yellow` / `text-brand-yellow` | Accent highlights, CTA backgrounds |
| `--color-brand-red` (#C91A09) | `bg-brand-red` / `text-brand-red` | Error states, destructive actions, required indicators |
| `--color-brand-nougat-light` (#F6D7B3) | `bg-brand-nougat-light` | Light skin tone, minifigure illustrations |
| `--color-brand-nougat` (#D09168) | `bg-brand-nougat` | Mid skin tone, nougat elements |
| `--color-brand-nougat-dark` (#AD6140) | `bg-brand-nougat-dark` | Dark skin tone, contrast nougat |
| `--color-text-primary` (#05131D) | `text-text-primary` | Primary body text on white/light backgrounds |
| `--color-text-on-dark` (#FFFFFF) | `text-text-on-dark` | Text on dark or brand-coloured backgrounds |
| `--color-text-muted` (#6B7280) | `text-text-muted` | Secondary labels, captions, helper text |
| `--color-text-subtle` (#9CA3AF) | `text-text-subtle` | De-emphasised metadata; large text only |
| `--color-bg-page` (#FFFFFF) | `bg-bg-page` | Default page/document background |
| `--color-bg-dark` (#05131D) | `bg-bg-dark` | Dark section backgrounds; pair with `text-text-on-dark` |
| `--color-bg-subtle` (#F9FAFB) | `bg-bg-subtle` | Light card and section backgrounds |
| `--color-bg-accent` (#FAC80A) | `bg-bg-accent` | Brand accent CTA; pair with `text-text-primary` |
| `--color-border-default` (#E5E7EB) | `border-border-default` | Standard card/section divider borders |
| `--color-border-brand` (#05131D) | `border-border-brand` | Brand borders, left-accent rules, focus rings |

---

## 7. Tailwind v4 naming convention

Tailwind v4 auto-generates utility classes from `--color-*` custom properties inside `@theme`:

- `--color-foo-bar` → `bg-foo-bar`, `text-foo-bar`, `border-foo-bar`, `ring-foo-bar`, etc.

So `--color-text-primary` gives you `text-text-primary`, `--color-bg-dark` gives you `bg-bg-dark`, etc. The double-word (`text-text-*`, `bg-bg-*`) is intentional — the first word is the CSS property prefix, the second is the token name.

Similarly, `--font-sans` → `font-sans`, `--duration-base` → `duration-base`, etc.

---

## 8. Component classes

### `pageWrapper`

Apply to the top-level container on every page:
```html
<div class="max-w-5xl mx-auto px-4">…</div>
```

### `card-hover`

Animates a card upward on hover, respecting reduced-motion:
```css
@media (prefers-reduced-motion: no-preference) {
  .card-hover:hover {
    transform: translateY(-2px);
    transition: transform var(--duration-base) var(--ease-standard);
  }
}
```
Add `class="card-hover"` to any card that should lift on hover.

### `timeline-nav`

Custom thin scrollbar for horizontally scrolling timeline bars:
```html
<div class="timeline-nav overflow-x-auto">…</div>
```

### `logo-animated`

Apply to the animated logo variant element. `brand.css` hides it when the user prefers reduced motion:
```html
<img class="logo-animated" src="/logo-animated.gif" alt="">
```

---

## 9. Toolbar design patterns

### Dark toolbar with square logo (reference implementation: `./planet`)

The recommended toolbar for all projects uses the brand dark background with white text/links:

```html
<nav class="bg-bg-dark text-text-on-dark">
  <div class="max-w-5xl mx-auto px-4 flex items-center gap-4 h-14">
    <img src="/logo-square.png" alt="SPH" class="h-8 w-8">
    <a href="/" class="type-h4 text-text-on-dark hover:text-brand-yellow">Etusivu</a>
    <!-- nav links … -->
  </div>
</nav>
```

Key properties:
- Background: `bg-bg-dark` (`#05131D`)
- Logo: square variant, height `h-8` / `h-10`
- Links: `text-text-on-dark`, hover `text-brand-yellow`
- Height: `h-14` (56 px)
