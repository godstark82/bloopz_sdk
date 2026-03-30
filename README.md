## Bloopz SDK (Flutter)

Capture the **Google Play Install Referrer** parameters from a Bloopz creator link (e.g. `utm_source=bloopz` + `utm_medium=CAMPAIGN_APPLICATION_ID`) and (optionally) send the **CPI postback** to Bloopz.

## Features

- **Install Referrer listener (Android)**: stream + one-shot getter.
- **UTM parsing utilities**: `utm_source`, `utm_medium`, and a convenience `isBloopz` check.
- **Postback helper**: build/send `GET https://www.bloopz.com/api/postback/cpi?...`.

## Getting started

Add dependency:

```yaml
dependencies:
  bloopz_sdk: ^0.0.1
```

## Usage

Listen for referrer params at startup:

```dart
import 'package:bloopz_sdk/bloopz_sdk.dart';

void main() {
  BloopzReferrer.referrals().listen((ref) async {
    if (!ref.isBloopz) return;

    final utmMedium = ref.utmMedium!;

    // Prefer doing this on YOUR server so params aren’t exposed to clients.
    // This client helper is provided for convenience.
    await BloopzPostback.sendCpi(utmMedium: utmMedium);
  });
}
```

Or fetch once (Android only):

```dart
final ref = await BloopzReferrer.getInstallReferrer();
if (ref?.isBloopz ?? false) {
  await BloopzPostback.sendCpi(utmMedium: ref!.utmMedium!);
}
```

## Postback API (Bloopz)

Endpoint:

- `GET https://www.bloopz.com/api/postback/cpi`

Query parameters:

- `utm_source` (**required**): must be `bloopz`
- `utm_medium` (**required**): campaign application ID

Example:

- `https://www.bloopz.com/api/postback/cpi?utm_source=bloopz&utm_medium=CAMPAIGN_APPLICATION_ID`

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
