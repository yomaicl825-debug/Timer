# CloudBase deployment

Create a CloudBase environment in the Tencent console, enable email/password authentication, and create document collections `timer_records`, `timer_operations`, `timer_locks`, and `sync_cursors`. Apply `rules/private-rules.json` to all four collections so clients cannot bypass the cloud function. Apply `rules/function-rules.json` to require authentication for `timer-command`. The cloud function uses administrator privileges and verifies the authenticated UID on every command.

Deploy `functions/timer-command` as a Node.js event function. Build the client with `--dart-define=CLOUDBASE_ENV=<environment-id>` and, if necessary, `--dart-define=CLOUDBASE_REGION=<region>`. The environment ID is public configuration; never put a CloudBase administrator key in the client or repository.

A live security and concurrent-claim test requires an environment and two test accounts. It has not been run without an environment ID.

