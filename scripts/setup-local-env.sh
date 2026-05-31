#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ ! -f ".env.example" ]; then
  echo "Missing .env.example in $ROOT_DIR" >&2
  exit 1
fi

if [ -f ".env" ]; then
  echo ".env already exists, keeping current local file."
else
  cp .env.example .env
  echo "Created .env from .env.example."
fi

if [ -f "vendor/autoload.php" ]; then
  php artisan key:generate --force
  echo "Generated APP_KEY in .env."
else
  echo "vendor/autoload.php not found, skip key generation for now."
  echo "Next: run composer install --no-interaction --prefer-dist"
  echo "Then: php artisan key:generate"
fi

echo
echo "Next steps:"
echo "1. Edit .env database settings if needed."
echo "2. Create PostgreSQL database/user."
echo "3. Run: php artisan migrate --force && php artisan db:seed --force && php artisan storage:link"
echo "4. Run: php artisan serve --host=127.0.0.1 --port=8080"
