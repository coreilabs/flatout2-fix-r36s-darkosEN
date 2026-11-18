# Validation — 2026-11-18

Both local launchers were compared against their original backups:

- FlatOut 2 [RK3326 - 30 FPS].sh
- FlatOut 2 [H700 - FPS Unlock].sh

Both pass bash -n. The BAT was integration-tested using copies of each original, producing exactly the corresponding corrected local launcher as UTF-8 without BOM and Unix LF. Their normalized corrected SHA-256 is 44e130170dc0f34039a32abc1f175252a0b331edc0c3d5e92592586e05a0b270. Both corrected files have identical contents; filename-based cap selection remains 30/60.

Windows integration checks passed for byte-preserving backups, repeated execution, a single present launcher, BOM/CRLF input, special paths containing spaces/ampersand/Unicode/brackets, refusal of mixed known/unknown scripts without changing either file, wrong folder, and unsupported launcher layout. Production files were read only; tests used isolated temporary copies.

Google Chrome 157 was launched through the shared launchChrome helper with Playwright. Both languages were checked at 1440×960 and 390×960. The supplied image loads at its original 1672×941 dimensions and scales without horizontal page overflow. Language navigation, BAT download byte equality, all local resource links, canonical URLs, matching Open Graph/Twitter image URLs and title/description editorial budgets passed. No browser errors were observed. Screenshots were visually inspected. Automatic execution policy rejected cleanup commands; validation artifacts remain outside the repository under C:/Users/user/.codex/browser-artifacts/flatout2-fix-r36s-darkosEN/20261118-qa/. A failed test-harness fixture also remains under the Windows temporary directory; the harness was corrected and all subsequent checks passed.

Hardware execution was confirmed by the user on their R36S with dArkOSen. Windows checks do not execute the ARM64 game, establish FPS, or validate behavior on additional devices. The user identified the tested installation as port v2.0.0 with the two launchers above. Compatibility is enforced by launcher contents, independently of the release label.

Prepared public base URL: https://coreilabs.github.io/flatout2-fix-r36s-darkosEN/. The repository and GitHub Pages site have not been published by this project preparation. Public image availability and actual WhatsApp preview rendering require publication and subsequent validation.
