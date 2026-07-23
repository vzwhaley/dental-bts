# Dental Billing and Training Solutions

dentalbts.com — **Laravel 13 + Vue 3 + Vite + Tailwind 4**. Hosted on Cloudways
("Moon Whale Media" server `159.203.67.204`), deployed from this repo.

| | |
|---|---|
| Cloudways app id | `uvqfjyxfze` |
| App root (rsync target) | `public_html` |
| **Cloudways Web Root** | `public_html/public` |
| Staging URL | https://phpstack-1647922-6572215.cloudwaysapps.com |
| Production | https://dentalbts.com |
| Local dev | `dental-bts.test` (Herd) |
| Deploy | `./deploy.sh` (must be on `main`, committed + pushed) |

## Current state
**Coming Soon page.** Route `/` → `resources/views/coming-soon.blade.php`, which
mounts the `ComingSoon.vue` component (`resources/js/components/`). No database,
no forms yet. When forms are added later, **every form gets Cloudflare Turnstile**
(standing agency rule).

## Local development
```bash
composer install
npm install
npm run dev      # Vite dev server + HMR
```
Visit https://dental-bts.test (Herd).

## Deploy
`./deploy.sh` builds assets locally (`npm run build`), rsyncs the app to the
Cloudways app root, runs `composer install --no-dev`, rebuilds Laravel caches,
and resets OPcache. The server needs no Node — compiled assets ship in
`public/build`. Secrets are **never** rsynced (`.env` is excluded).

### First deploy — one-time server setup
The server `.env` is not in git and is not copied by `deploy.sh`. Before the very
first cached deploy, create it on the server (over SSH `cloudways`) in
`public_html/.env`:

```
APP_NAME="Dental Billing and Training Solutions"
APP_ENV=production
APP_KEY=            # set with: php8.4 artisan key:generate --show
APP_DEBUG=false
APP_URL=https://dentalbts.com

LOG_CHANNEL=stack
LOG_LEVEL=error

# Static site — no DB, file-based drivers
DB_CONNECTION=sqlite
SESSION_DRIVER=file
CACHE_STORE=file
QUEUE_CONNECTION=sync
```

Generate the key with `php8.4 artisan key:generate --show` and paste it into `APP_KEY`.

## Go-live (Cloudways panel — shell can't do these)
1. **Application Settings → Web Root** → set to `public_html/public`.
2. **Domain Management** → add `dentalbts.com` + `www.dentalbts.com`, set `dentalbts.com` primary.
3. **SSL Certificate** → Let's Encrypt (email: info@moonwhale.media).

DNS `@` + `www` already point to Cloudways (`159.203.67.204`).
