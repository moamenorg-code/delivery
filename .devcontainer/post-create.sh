#!/usr/bin/env bash
set -e

echo "Running devcontainer post-create script..."

# Ensure flutter is on PATH (installed in Dockerfile)
export FLUTTER_HOME=/usr/local/flutter
export PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH"

echo "Node version: $(node --version || echo 'node not found')"
echo "NPM version: $(npm --version || echo 'npm not found')"

# Install API dependencies
if [ -f /workspaces/delivery/api/package.json ]; then
  echo "Installing API npm dependencies..."
  cd /workspaces/delivery/api
  npm install || true
  cd - >/dev/null || true
fi

# Install Flutter packages for known flutter apps
for project in delivery_manager_flutter talabat_clone_flutter driver_app restaurant_app customer_app; do
  if [ -f "/workspaces/delivery/$project/pubspec.yaml" ]; then
    echo "Running flutter pub get for $project"
    cd /workspaces/delivery/$project
    flutter pub get || true
    cd - >/dev/null || true
  fi
done

echo "Running flutter precache and doctor (may take time)..."
flutter precache || true
flutter doctor || true

echo "Post-create script finished."
