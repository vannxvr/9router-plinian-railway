# 9Router Plinian — Railway

Railway deployment wrapper for [9Router Plinian](https://github.com/vannxvr/9router-plinian). The Docker build clones the Plinian source (\`master\`) and builds its Next.js standalone application; it does not use the older \`decolua/9router\` image.

## Deploy

1. Create a Railway project from this GitHub repository.
2. Add a persistent volume mounted at \`/app/data\`.
3. Set the variables below before the first deploy.
4. Generate a Railway public domain and set \`BASE_URL\` and \`NEXT_PUBLIC_BASE_URL\` to that HTTPS URL.
5. Deploy and wait for the \`/api/health\` healthcheck to pass.

## Required variables

| Variable | Value |
|---|---|
| \`PORT\` | \`20128\` |
| \`HOSTNAME\` | \`0.0.0.0\` |
| \`NODE_ENV\` | \`production\` |
| \`DATA_DIR\` | \`/app/data\` |
| \`INITIAL_PASSWORD\` | A strong initial dashboard password |
| \`JWT_SECRET\` | A long, random secret |
| \`API_KEY_SECRET\` | A separate long, random secret |
| \`MACHINE_ID_SALT\` | A separate long, random secret |
| \`AUTH_COOKIE_SECURE\` | \`true\` |
| \`BASE_URL\` | Your Railway HTTPS public URL |
| \`NEXT_PUBLIC_BASE_URL\` | Same Railway HTTPS public URL |

Generate separate random values for all four secrets/passwords. Do not reuse the same value, commit them to Git, or share them publicly. Keep the persistent volume attached: it stores the SQLite database and application data.

## Build configuration

- Dockerfile: \`Dockerfile\`
- Internal port: \`20128\`
- Healthcheck: \`/api/health\`
- Persistent data path: \`/app/data\`
- Source repository: [vannxvr/9router-plinian](https://github.com/vannxvr/9router-plinian), branch \`master\`

To build from another source branch, change the Docker build argument \`PLINIAN_REF\`.

## Notes

- The Railway service must expose port \`20128\`; Railway will provide HTTPS on its public domain.
- Do not remove \`INITIAL_PASSWORD\` after setup unless the upstream application explicitly documents a safe replacement.
- Back up the Railway volume regularly. A container redeploy is not a substitute for a database backup.
