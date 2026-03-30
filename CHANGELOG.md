## 0.4.0

- **Breaking:** CPI postback uses `POST /api/postback/cpi` with JSON body (`utm_source`, `utm_medium`, `key`). `BloopzPostback.sendCpi` now requires a `key` argument (provide at runtime; do not hardcode).
- README: document the POST API, curl example, and supplying the key (e.g. `String.fromEnvironment`).
- Add MIT `LICENSE`.
- pubspec: add `repository` metadata for pub.dev.
- pubspec: bump minimum Flutter SDK to `>=1.20.0` (required by pub.dev for plugins that don’t ship an `ios/` folder).

## 0.0.1

- Add Android Install Referrer listener (stream + one-shot getter).
- Add utilities to parse `utm_source` / `utm_medium` from the referrer.
- Add CPI postback helper for `GET /api/postback/cpi`.
