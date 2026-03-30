## Bloopz SDK (Flutter)

Capture the **Google Play Install Referrer** parameters from a Bloopz creator link (e.g. `utm_source=bloopz` + `utm_medium=CAMPAIGN_APPLICATION_ID`) and (optionally) send the **CPI postback** to Bloopz.

## Features

- **Install Referrer listener (Android)**: stream + one-shot getter.
- **UTM parsing utilities**: `utm_source`, `utm_medium`, and a convenience `isBloopz` check.
- **Postback helper**: send `POST https://www.bloopz.com/api/postback/cpi` with JSON body.

## Getting started

Add dependency:

```yaml
dependencies:
  bloopz_sdk: ^0.3.0
```

## Usage

Listen for referrer params at startup:

```dart
import 'package:bloopz_sdk/bloopz_sdk.dart';

void main() {
  // Don’t hardcode secrets in source. Prefer doing this on your server.
  // If you must call from client, provide the key at runtime (e.g. --dart-define)
  // and keep it out of git.
  const yourSecretKey = String.fromEnvironment('BLOOPZ_KEY');

  BloopzReferrer.referrals().listen((ref) async {
    if (!ref.isBloopz) return;

    final utmMedium = ref.utmMedium!;

    await BloopzPostback.sendCpi(utmMedium: utmMedium, key: yourSecretKey);
  });
}
```

Or fetch once (Android only):

```dart
final ref = await BloopzReferrer.getInstallReferrer();
if (ref?.isBloopz ?? false) {
  await BloopzPostback.sendCpi(utmMedium: ref!.utmMedium!, key: yourSecretKey);
}
```

## Postback API (Bloopz)

Endpoint:

- `POST https://www.bloopz.com/api/postback/cpi`

JSON body fields:

- `utm_source` (**required**): must be `bloopz`
- `utm_medium` (**required**): campaign application ID
- `key` (**required**): your secret key

Example:

```bash
curl -X POST "https://your-domain.com/api/postback/cpi" \
  -H "Content-Type: application/json" \
  -d '{
    "utm_source": "bloopz",
    "utm_medium": "CAMPAIGN_APPLICATION_ID",
    "key": "YOUR_SECRET_KEY"
  }'
```

## Platform support

- **Android**: supported (Install Referrer API)
- **iOS**: no-op (returns `null` / emits nothing)

## Development: pre-commit version bump

This repo includes a Git `pre-commit` hook template that bumps the **minor**
version in `pubspec.yaml` on every commit (`x.y.z` → `x.(y+1).0`).

- Hook template: `.githooks/pre-commit`
- Installer (Windows PowerShell): `scripts/install_githooks.ps1`

Install after `git init`:

```powershell
.\scripts\install_githooks.ps1
```
