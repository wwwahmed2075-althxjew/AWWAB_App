# AWWAB offline religious-content references

This register records the primary references for the starter content currently embedded in the app. Hadith numbering may vary between editions; the Arabic text and grading should be checked against a verified edition before a public release.

## Quran
- Al-Baqarah 2:152, 2:186, 2:201
- Ar-Ra'd 13:28
- Al-Ankabut 29:45
- Al-Hijr 15:9
- Al-Isra 17:9, 17:82
- Al-Muzzammil 73:4
- Ta-Ha 20:114
- Al-Ahzab 33:41
- Fatir 35:29
- Adh-Dhariyat 51:17
- As-Sajdah 32:16

## Hadith
- Sahih al-Bukhari 5027 — learning and teaching the Quran.
- Sahih al-Bukhari 6407 — the example of remembering Allah.
- Sahih al-Bukhari 6464 and Sahih Muslim 783 — consistency in deeds.
- Sahih Muslim 720 — the two rak'ahs of Duha suffice for the charity due from the joints.
- Sahih al-Bukhari 1981 and Sahih Muslim 721 — the Prophet's advice to Abu Hurairah, including two rak'ahs of Duha.
- Sahih Muslim 798 — the proficient Quran reciter and the one who recites with difficulty.
- Sahih Muslim 804 — Quran intercession on the Day of Resurrection.
- Sahih Muslim 1163 — the best prayer after obligatory prayers is night prayer.
- Sahih al-Bukhari 1145 and Sahih Muslim 758 — the last third of the night.
- Sahih Muslim 2676 — the virtue of those who remember Allah often.
- Sahih al-Bukhari 6406 and Sahih Muslim 2694 — the two phrases beloved to the Most Merciful.
- Sahih al-Bukhari 6405 and Sahih Muslim 2691 — the virtue of saying Subhan Allah wa bihamdihi one hundred times.
- Sahih Muslim 2137 — the four phrases most beloved to Allah.
- Jami' at-Tirmidhi 3375 — keeping the tongue moist with remembrance of Allah.
- Sahih Muslim 2699 — seeking knowledge.
- Sahih Muslim 2700 — gatherings of remembrance.
- Sahih Muslim 2721 — supplication asking for guidance, piety, chastity, and sufficiency.
- Sahih Muslim 2720 — supplication asking for well-being in religion, worldly life, and the Hereafter.
- Sahih al-Bukhari 6369 — seeking refuge from worry, grief, incapacity, and laziness.
- Jami' at-Tirmidhi 2140 — supplication asking Allah to keep the heart firm.
- Sunan Abi Dawud 5074 and Jami' at-Tirmidhi 3512 — asking for pardon and well-being.
- Sahih Muslim 2723 — morning/evening remembrance.
- Sahih al-Bukhari 6306 — Sayyid al-Istighfar.
- Sahih al-Bukhari 6312 — supplication on waking.
- Jami' at-Tirmidhi 3401 — wording reported when waking; verify grading against the chosen edition before release.
- Sahih al-Bukhari 6324 — supplication when going to sleep.
- Sunan Abi Dawud 5068 and Jami' at-Tirmidhi 3391 — morning/evening supplication beginning “Allahumma bika asbahna”.
- Sunan Abi Dawud 5072 and Jami' at-Tirmidhi 3389 — saying “Raditu billahi rabban...” morning and evening.
- Sahih al-Bukhari 6318 and Sahih Muslim 2727 — tasbih before sleep.
- Sahih al-Bukhari 6320 — supplication when lying down.
- Sahih al-Bukhari 2311 — Ayat al-Kursi before sleep.
- Sahih al-Bukhari 5009 — the last two verses of Al-Baqarah at night.
- Sahih al-Bukhari 5017 — reciting the three Quls before sleep.
- Sahih Muslim 591 — istighfar and the supplication after prayer.
- Sahih Muslim 597 — tasbih after prayer.
- Sunan Abi Dawud 1522 — asking Allah for help in remembering Him and worshipping Him well.
- Sunan Abi Dawud 5082 and Jami' at-Tirmidhi 3575 — the three Quls in the morning and evening.
- Sunan Abi Dawud 5088 and Jami' at-Tirmidhi 3388 — the supplication beginning "Bismillah alladhi la yadurru".
- Jami' at-Tirmidhi 2910 — reward for reciting each letter of the Quran; graded Hasan Sahih by at-Tirmidhi.

## Editorial notes
- The adhkar currently included are a starter collection, not a complete corpus. Keep the on-screen note that wording, repetition counts and takhrij require a final review.
- The 99-name list is a commonly circulated enumeration. Scholars differ over the exact enumeration; the meanings are concise explanations.
- The Madinah Mushaf V4 page set is separately verified using the SHA-1 manifest in `assets/mushaf/madinah_hafs_v4_manifest.json`.


The app's offline reminder scheduler uses the device timezone and refreshes prayer-based Ayat al-Kursi alerts from the cached device coordinates. Adhan audio files are not bundled in the APK; the user downloads a selected recording on request, and the app verifies its file digest before saving it for offline playback.


## Adhan audio
- `Adhan.ogg` by Aishatu98, Wikimedia Commons, dedicated under Creative Commons CC0 1.0 Universal. File page: https://commons.wikimedia.org/wiki/File:Adhan.ogg. Original recording is approximately 42 seconds; the app downloads it on request, verifies SHA-1 `b86432f1581e11f898de1dc3402af0d541af110e`, and stores it for offline playback. This recording is not attributed to a named sheikh or muezzin.

- `Beautiful_adhan.ogg` by Adam-synagda, Wikimedia Commons, CC0 1.0 Universal Public Domain Dedication. File page: https://commons.wikimedia.org/wiki/File:Beautiful_adhan.ogg. Original Ogg Vorbis recording is approximately 154 seconds; SHA-1 `a1fa4fd942401922c5c3301816384aae86956522`. The uploader name is credited as the file author, not asserted to be the caller's identity.

- `33937_ejaz215_call-to-prayer-from-the-prophet-s-mo.ogg` — recorded at Al-Masjid an-Nabawi, Madinah; source/author credited on Wikimedia Commons as ejaz215 (original Freesound source). Licensed CC BY 3.0. Attribution required: credit ejaz215, link the source file page and CC BY 3.0 licence, and note any changes. Original length 3:07; SHA-1 `4aa432b9e44804e7d72af4429bd743aa5fa9e3a4`. Source: https://commons.wikimedia.org/wiki/File:33937_ejaz215_call-to-prayer-from-the-prophet-s-mo.ogg


- `The Adhan – Muslim Call to Prayer – Aaqib Azeez` — original recording by the copyright holder Atcovi, Wikimedia Commons, CC BY-SA 4.0. Source: https://commons.wikimedia.org/wiki/File:The_Adhan_-_Muslim_Call_to_Prayer_-_Aaqib_Azeez.mp3. The app downloads the full edited Ogg preview distributed by the Taqwa project at commit `29fba6b08c9af3b6aac264b58095afff1799d786`; it was trimmed and loudness-normalised by that project. The adapted audio remains under CC BY-SA 4.0. Credit Atcovi, link the source and licence, and identify the audio as adapted.

- `Adhan, Great Mosque of Mecca – Jan 21, 2013` — recording by Seyfula Islam, Wikimedia Commons, CC BY 3.0. Source: https://commons.wikimedia.org/wiki/File:Adhan,_Great_Mosque_of_Mecca_-_Jan_21,_2013.webm. The app downloads an Ogg audio-only edit distributed by the Taqwa project at commit `29fba6b08c9af3b6aac264b58095afff1799d786`; the edit removes the lead-in and normalises the audio. Credit Seyfula Islam, link the source and CC BY 3.0 licence, and indicate the edit.

- `Eid al-Fitr Fajr azan at Malmö Mosque – 19 August 2012` — recording published by Islamic Center Malmö; the source description names muezzin Besim Azemi. Wikimedia Commons confirms CC BY 3.0. Source: https://commons.wikimedia.org/wiki/File:Eid_al-Fitr_Fajr_azan_at_Malm%C3%B6_Mosque_-_19_August_2012.webm. The app downloads an Ogg edit distributed by the Taqwa project at commit `29fba6b08c9af3b6aac264b58095afff1799d786`; the edit removes the two Fajr-specific phrases so it can be used as a general adhan, and removes the post-adhan salawat. Credit Islamic Center Malmö and Besim Azemi, link the source and CC BY 3.0 licence, and identify the edits.

- Audio edit distribution source for the three preceding entries: MohamedAbulgasem/Taqwa, `assets/audio/README.md`, pinned commit `29fba6b08c9af3b6aac264b58095afff1799d786`: https://github.com/MohamedAbulgasem/Taqwa/blob/29fba6b08c9af3b6aac264b58095afff1799d786/assets/audio/README.md. Taqwa documents the source rights, processing and applicable share-alike terms. Its source code licence does not replace the separate audio licences.


- `Call to prayer by Sabah Fakhry` — recording attributed by Wikimedia Commons to Sabah Fakhri (صباح فخري), dated 1985. The Commons file page marks the recording Public Domain Mark 1.0 and states it is free of known copyright restrictions; it also includes a public-domain status tag for the country of origin. Source: https://commons.wikimedia.org/wiki/File:Call_to_prayer_by_Sabah_Fakhry.mp3. Original MP3 is used unchanged. SHA-1: `a76718d98e7495a930ce9c024d94dba98f490a1f`.


- `Azan.ogg` — original adhan recording by Andrewler, Wikimedia Commons, CC BY-SA 4.0. Source: https://commons.wikimedia.org/wiki/File:Azan.ogg. The original Ogg Vorbis file is used unchanged. Credit Andrewler, link the source and licence. SHA-1: `ada13592b01c12b0128af40035ed7a803e08b563`. If this recording is adapted, the adaptation must be shared under CC BY-SA 4.0 or a compatible licence.
