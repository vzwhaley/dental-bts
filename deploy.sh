#!/usr/bin/env bash
#
# Production deploy for dentalbts.com (Cloudways, "Moon Whale Media" server).
# SCAFFOLD deploy — rsyncs the repo to the app webroot (public_html). When a
# framework is added, set the Cloudways Web Root (e.g. public_html/public) and
# uncomment the composer/cache section below.
#
# Usage: ./deploy.sh   (must be on main, committed + pushed)
#
set -euo pipefail

SSH_HOST="cloudways"
REMOTE_ROOT="/home/master/applications/uvqfjyxfze/public_html"
REMOTE_PHP="php8.4"
REMOTE_COMPOSER="/usr/local/bin/composer"
DEPLOY_BRANCH="${DEPLOY_BRANCH:-main}"
STAGING_URL="phpstack-1647922-6572215.cloudwaysapps.com"

say(){ printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
die(){ printf '\n\033[1;31mDEPLOY ABORTED: %s\033[0m\n' "$*" >&2; exit 1; }

reset_opcache(){
  say "Resetting OPcache"
  ssh "$SSH_HOST" "printf '%s' '<?php if(function_exists(\"opcache_reset\"))opcache_reset();' > '$REMOTE_ROOT/_ocreset.php'"
  curl -sk -m 15 "https://$STAGING_URL/_ocreset.php" >/dev/null 2>&1 || true
  ssh "$SSH_HOST" "rm -f '$REMOTE_ROOT/_ocreset.php'"
}

say "Verifying git state"
branch="$(git rev-parse --abbrev-ref HEAD)"
[ "$branch" = "$DEPLOY_BRANCH" ] || die "on branch '$branch', expected '$DEPLOY_BRANCH'"
[ -z "$(git status --porcelain)" ] || die "uncommitted changes — commit & push first"
git fetch -q origin "$DEPLOY_BRANCH"
[ "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$DEPLOY_BRANCH")" ] || die "local != origin/$DEPLOY_BRANCH — push first"
echo "$DEPLOY_BRANCH @ $(git rev-parse --short HEAD) — clean and pushed"

say "Rsyncing to $SSH_HOST:$REMOTE_ROOT"
rsync -az --omit-dir-times --no-perms --no-owner --no-group --human-readable --delete \
  --exclude '.git' --exclude '.github' --exclude '.idea' --exclude 'node_modules' \
  --exclude 'vendor' --exclude '/var/' --exclude '.env' --exclude '.env.local' \
  --exclude '.env.*.local' --exclude '.DS_Store' --exclude 'deploy.sh' --exclude 'README.md' \
  ./ "$SSH_HOST:$REMOTE_ROOT/"

say "Normalizing permissions (best-effort; app-user may own the dir)"
ssh "$SSH_HOST" "chmod -R a+rX '$REMOTE_ROOT' 2>/dev/null || true"

# --- Framework build steps: uncomment when a PHP framework is added ---
# say "Remote composer install + prod cache"
# ssh "$SSH_HOST" "cd '$REMOTE_ROOT' && APP_ENV=prod \"$REMOTE_PHP\" \"$REMOTE_COMPOSER\" install --no-dev --optimize-autoloader --no-interaction --no-progress"
# ssh "$SSH_HOST" "cd '$REMOTE_ROOT' && \"$REMOTE_PHP\" bin/console cache:clear --env=prod --no-debug && \"$REMOTE_PHP\" bin/console cache:warmup --env=prod --no-debug"

reset_opcache
say "Deploy complete — $DEPLOY_BRANCH @ $(git rev-parse --short HEAD)"
