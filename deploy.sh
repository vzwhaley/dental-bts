#!/usr/bin/env bash
#
# Production deploy for dentalbts.com — Laravel 13 + Vue 3 (Cloudways,
# "Moon Whale Media" server). Rsyncs the app to the Cloudways app root
# (public_html); the Cloudways **Web Root** must be set to public_html/public.
#
# Assets are built LOCALLY (npm run build → public/build) and rsynced up, so the
# server needs no Node. Composer deps are installed on the server. Secrets live
# in the server's .env (never rsynced — see README "First deploy").
#
# Usage: ./deploy.sh   (must be on main, committed + pushed)
#
set -euo pipefail

SSH_HOST="cloudways"
APP_ROOT="/home/master/applications/uvqfjyxfze/public_html"   # Laravel app root
WEB_ROOT="$APP_ROOT/public"                                    # nginx docroot (set in panel)
REMOTE_PHP="php8.4"
REMOTE_COMPOSER="/usr/local/bin/composer"
DEPLOY_BRANCH="${DEPLOY_BRANCH:-main}"
STAGING_URL="phpstack-1647922-6572215.cloudwaysapps.com"

say(){ printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
die(){ printf '\n\033[1;31mDEPLOY ABORTED: %s\033[0m\n' "$*" >&2; exit 1; }

reset_opcache(){
  say "Resetting OPcache"
  ssh "$SSH_HOST" "printf '%s' '<?php if(function_exists(\"opcache_reset\"))opcache_reset();' > '$WEB_ROOT/_ocreset.php'"
  curl -sk -m 15 "https://$STAGING_URL/_ocreset.php" >/dev/null 2>&1 || true
  ssh "$SSH_HOST" "rm -f '$WEB_ROOT/_ocreset.php'"
}

say "Verifying git state"
branch="$(git rev-parse --abbrev-ref HEAD)"
[ "$branch" = "$DEPLOY_BRANCH" ] || die "on branch '$branch', expected '$DEPLOY_BRANCH'"
[ -z "$(git status --porcelain)" ] || die "uncommitted changes — commit & push first"
git fetch -q origin "$DEPLOY_BRANCH"
[ "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$DEPLOY_BRANCH")" ] || die "local != origin/$DEPLOY_BRANCH — push first"
echo "$DEPLOY_BRANCH @ $(git rev-parse --short HEAD) — clean and pushed"

say "Building front-end assets locally (Vite)"
npm ci --no-audit --no-fund
npm run build
[ -f public/build/manifest.json ] || die "vite build produced no public/build/manifest.json"

say "Rsyncing app to $SSH_HOST:$APP_ROOT"
# --delete keeps the remote clean, but storage/ and bootstrap/cache/ are excluded
# so runtime state (logs, sessions, compiled views) survives deploys.
rsync -az --omit-dir-times --no-perms --no-owner --no-group --human-readable --delete \
  --exclude '.git' --exclude '.github' --exclude '.idea' --exclude 'node_modules' \
  --exclude 'vendor' --exclude '/storage/' --exclude '/bootstrap/cache/' \
  --exclude '.env' --exclude '.env.local' --exclude '.env.*.local' \
  --exclude '.DS_Store' --exclude 'deploy.sh' --exclude 'README.md' \
  ./ "$SSH_HOST:$APP_ROOT/"

say "Ensuring writable storage + bootstrap/cache skeleton"
ssh "$SSH_HOST" "cd '$APP_ROOT' && \
  mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views \
           storage/logs storage/app/public bootstrap/cache && \
  chmod -R ug+rwX storage bootstrap/cache 2>/dev/null || true"

say "Remote composer install (prod)"
ssh "$SSH_HOST" "cd '$APP_ROOT' && \"$REMOTE_PHP\" \"$REMOTE_COMPOSER\" install --no-dev --optimize-autoloader --no-interaction --no-progress"

if ssh "$SSH_HOST" "test -f '$APP_ROOT/.env'"; then
  say "Rebuilding Laravel caches"
  ssh "$SSH_HOST" "cd '$APP_ROOT' && \
    \"$REMOTE_PHP\" artisan config:cache && \
    \"$REMOTE_PHP\" artisan route:cache && \
    \"$REMOTE_PHP\" artisan view:cache"
else
  printf '\n\033[1;33mNOTE: no .env on server yet — skipping artisan caches.\n'
  printf 'Complete the one-time .env setup (see README), then re-run ./deploy.sh.\033[0m\n'
fi

reset_opcache
say "Deploy complete — $DEPLOY_BRANCH @ $(git rev-parse --short HEAD)"
