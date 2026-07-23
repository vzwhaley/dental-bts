# Dental Billing and Training Solutions

dentalbts.com — hosted on Cloudways ("Moon Whale Media" server `159.203.67.204`), deployed from this repo.

| | |
|---|---|
| Cloudways app id | `uvqfjyxfze` |
| Staging URL | https://phpstack-1647922-6572215.cloudwaysapps.com |
| Production | https://dentalbts.com (after DNS cutover + SSL) |
| Deploy | `./deploy.sh` (rsync → Cloudways; must be on `main`, committed + pushed) |

## Status
**Scaffold only — the website is not built yet.** When a framework is added (Symfony/Laravel/etc.):
set the Cloudways **Web Root** accordingly (e.g. `public_html/public`) and uncomment the
composer/cache section in `deploy.sh`.

## Go-live (Cloudways panel — see the fleet SESSION_HANDOFF)
1. **Domain Management** → add `dentalbts.com` + `www.dentalbts.com`, set `dentalbts.com` primary.
2. **SSL Certificate** → Let's Encrypt (email: info@moonwhale.media).
3. Point DNS `@` + `www` → `159.203.67.204` at GoDaddy.
4. Every form gets **Cloudflare Turnstile** (standing rule).
