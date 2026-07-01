# CLAUDE.md — AgriExpert Project

## CRITICAL: Working Style Rules

1. **Do EXACTLY what the user asks.** No creative reinterpretation. No extras. No "improvements."
2. **When given a screenshot/mockup — match it pixel-for-pixel.** Same spacing, icons, colors, counts.
3. **Never add things not requested.** No extra icons, no extra styling, no bonus features.
4. **One change per request.** Don't touch unrelated code.
5. **If unsure — ask.** Do not guess or assume.
6. **Get it right the first time.** Re-read the instruction before coding. Verify the output matches.

## Project: AgriExpert
- Flutter + Supabase (project: arbefcgjjnzudafrjzrs)
- Expert ID: 327f42c8-7dfc-4a02-a4b1-4a065a1df418
- App name: "Agri Expert"
- Primary color: #2E7D32 (green)

## FRONTEND IS LOCKED — DO NOT CHANGE unless user explicitly asks
All UI/design work is complete. Only touch backend logic from here on.

## Key Design Decisions (DO NOT CHANGE)
- Stars: outline only (star_border), show only the count given
- Stat cards: grey boxes, text only, NO icons
- Profile avatar: no green border ring
- Bottom nav: custom with bar1-bar5 assets, green top indicator, no labels
- Type cast stars from Supabase: (r['stars'] as num?)?.toInt() ?? 0
