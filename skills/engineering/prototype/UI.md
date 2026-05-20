# UI Prototype (Laravel)

Generate **several radically different UI variations** on a single route, switchable from a floating bottom bar. The user flips between variants in the browser, picks one (or steals bits from each), then throws the rest away.

If the question is about logic/state rather than appearance — wrong branch. Use [LOGIC.md](LOGIC.md).

Read `docs/agents/laravel-stack.md` for the project's UI layer (Blade, Livewire, Inertia, Filament).

## When this is the right shape

- "What should this settings page look like?"
- "Try three layouts for the dashboard before we commit."
- Any time the user would otherwise pick between vague mental mockups.

## Two sub-shapes — strongly prefer sub-shape A

A UI prototype is easier to judge **inside the real app** — real nav, real auth, real data density. Default to sub-shape A whenever there's a plausible existing page. Use sub-shape B only when nothing sensible exists to host variants.

### Sub-shape A — adjustment to an existing page (preferred)

The route already exists. Variants render on the **same route**, gated by `?variant=` (or `request('variant')`). Keep existing middleware, authorization, and data loading — only the presentation subtree swaps.

If the feature doesn't have its own page yet but belongs inside one (new card on settings, new step in a wizard) — still sub-shape A. Embed variants in the host page.

### Sub-shape B — a new page (last resort)

Only when the surface has no existing home (new top-level area, standalone flow).

Add a throwaway route in `routes/web.php` (or the project's route file convention). Name it obviously: `/prototype/checkout-flow`, `PrototypeCheckoutController`, etc. Same `?variant=` pattern.

Before sub-shape B, sanity-check: can this live inside an existing page?

## Process

### 1. State the question and pick N

Default to **3 variants**. Cap at 5.

One-line plan in a comment or `NOTES.md`:

> "Three variants of `/settings`, switchable via `?variant=`, using Livewire."

### 2. Generate radically different variants

Each variant must differ in **layout, hierarchy, and primary affordance** — not just colour. Hold to the project's stack:

| UI layer | Variant implementation |
|----------|------------------------|
| **Blade** | Separate `@include` partials or dedicated Blade views per variant |
| **Livewire** | Separate components `VariantA`, `VariantB`, … mounted from parent |
| **Inertia** | Separate page components; parent passes shared props |
| **Filament** | Custom page with tab-like variant switcher (rare for prototypes) |

Use existing design tokens (Tailwind config, Flux, Filament theme) — don't invent a parallel design system.

### 3. Wire them together

**Blade example:**

```blade
@php $variant = request('variant', 'A'); @endphp

@if ($variant === 'A')
    @include('prototype.settings.variant-a', ['settings' => $settings])
@elseif ($variant === 'B')
    @include('prototype.settings.variant-b', ['settings' => $settings])
@else
    @include('prototype.settings.variant-c', ['settings' => $settings])
@endif

@include('prototype._switcher', ['variants' => ['A', 'B', 'C'], 'current' => $variant])
```

**Livewire example:**

```php
// Parent passes $settings; child components are self-contained layouts
@livewire('prototype.settings.variant-' . strtolower($variant), ['settings' => $settings])
```

Keep data loading **above** the variant switch — variants only change presentation.

### 4. Build the floating switcher

Fixed bar bottom-centre:

- **Left arrow** — previous variant (wrap)
- **Label** — e.g. `B — Sidebar layout`
- **Right arrow** — next variant (wrap)

Behaviour:

- Updates `?variant=` via `history.replaceState` or a plain link — reload-stable and shareable
- Keyboard `←` / `→` when focus is not in an input
- Visually distinct from the page (pill, shadow)
- **Hidden outside local/dev** — gate with `app()->environment('local')` or `config('app.debug')` so prototypes never ship to production

Put the switcher in `resources/views/prototype/_switcher.blade.php` or a shared Livewire component.

### 5. Hand it over

Give the URL and variant keys. Feedback is usually **"header from B, sidebar from C"** — that's the real design.

### 6. Capture the answer and clean up

Record which variant won and why. Delete losers and the switcher. For sub-shape B, promote the winner to a real route.

## Anti-patterns

- Variants that differ only in colour or copy
- Shared layout partial that forces the same structure on every variant
- Wiring variants to real mutations — read-only or stubbed actions are fine
- Promoting prototype markup directly — rewrite with tests when folding in
