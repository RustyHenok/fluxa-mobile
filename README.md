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

If your backend checkout lives somewhere else, override the source path:

```bash
BACKEND_OPENAPI_PATH=/path/to/fluxa-backend/openapi/fluxa-openapi.json ./scripts/sync_openapi.sh
```

## Planned Stack

- `Flutter`
- generated Dart models/client from the synced OpenAPI file

## Next Implementation Step

After the contract is synced, scaffold the app and wire generated client usage around:

- auth and tenant switching
- task list/detail flows
- export job polling
- dashboard summary
