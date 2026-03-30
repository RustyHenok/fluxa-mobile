# fluxa-mobile

Flutter mobile client for the Fluxa task platform.

## API Contract

This repo consumes the REST contract published by `fluxa-backend`.

- source of truth in the sibling workspace: `../fluxa-backend/openapi/fluxa-openapi.json`
- local copy in this repo: `contracts/fluxa-openapi.json`

Sync the checked-in backend contract into this repo with:

```bash
./scripts/sync_openapi.sh
```

That script now also regenerates the Dart contract models in
`lib/core/models/generated/fluxa_contract_models.dart`.

If your backend checkout lives somewhere else, override the source path:

```bash
BACKEND_OPENAPI_PATH=/path/to/fluxa-backend/openapi/fluxa-openapi.json ./scripts/sync_openapi.sh
```

## Stack

- `Flutter`
- `flutter_riverpod`
- `go_router`
- `dio`
- `flutter_secure_storage`
- synced OpenAPI contract from `fluxa-backend`

## Current Mobile Scaffold

The mobile repo now includes:

- app shell + route structure
- auth bootstrap, login, register, logout, and tenant switching
- secure refresh-token persistence
- Dio-backed API client aligned with the backend REST contract
- generated Dart request and response contract models derived from the synced backend OpenAPI file
- typed task query helpers and partial-update request wrappers for the mobile client
- signed-in overview dashboard
- project list, detail, create, edit, and delete flows
- task list + task detail with audit timeline
- project-aware task create + edit flows with assignee, priority, status, due date, and project controls
- export job polling with readable result summaries and project-aware filters
- settings screen with runtime/API context

## Run Once Flutter Is Installed

```bash
flutter pub get
flutter run --dart-define=FLUXA_API_BASE_URL=http://127.0.0.1:18080
```

For Android emulators, you will usually want:

```bash
flutter run --dart-define=FLUXA_API_BASE_URL=http://10.0.2.2:18080
```

## Next Implementation Step

After the Flutter SDK is available locally, the next mobile slices are:

- device verification and UX polish
