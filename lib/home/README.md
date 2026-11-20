# Mishkat Home Page — Independent Module

This folder contains the first independently developed section for Mishkat.

## File
- `mishkat_home_page.dart`: reusable Flutter home page widget.

## Fixed visual contract
- Match the user's approved glossy glassmorphism reference: deep navy base, ivory/champagne-gold text and edges, restrained purple/olive reflections, iPhone-like spacing.
- RTL throughout.
- Prayer times are six separate cards in a 3-column RTL grid: Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha. An optional seventh Qiyam card may be supplied last.
- Each prayer card shows its actual calculated time. Only the next prayer card receives a countdown.
- Daily content appears once only: one Ayah, one Hadith, one Du'a card.
- Quick shortcuts appear once only: Quran, Adhkar, Tasbeeh, More. Qibla is reached through More, not repeated as a home shortcut.
- No duplicated prayer-time summary or repeated section links.
- Keep the existing header controls (theme, notifications, settings) callback-driven.
- Bottom navigation is owned by the host shell, not duplicated in this module.
- Daily content and prayer values must be injected from verified data/services; never hardcode placeholder religious text or fabricated times.

## Host integration
The host supplies formatted dates, location, prayer entries, and three verified daily content items. The host also supplies navigation/theme callbacks. This keeps this module independent and straightforward to merge with the other separately developed sections.
