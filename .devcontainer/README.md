# Dev Container for Delivery

This devcontainer config prepares an environment for developing the Delivery apps (Node.js API and multiple Flutter apps).

What this provides:

- Node.js 18 (via devcontainer feature)
- Flutter SDK (stable channel) installed at `/usr/local/flutter`
- Java (OpenJDK 17) and common tooling (git, curl, unzip)
- Post-create script that installs API npm deps and runs `flutter pub get` for Flutter apps

Quick start (Codespaces / Dev Container):

1. Open this repository in GitHub Codespaces or VS Code Remote - Containers.
2. The devcontainer will build automatically. After build completes the `postCreateCommand` runs.
3. Ports forwarded: 3000 (main API), 3001 (mock API).

Manual steps inside the container (if needed):

```bash
# Install API deps
cd /workspaces/delivery/api
npm install

# Start mock API (optional)
npm run mock

# Run flutter app
cd /workspaces/delivery/delivery_manager_flutter
flutter pub get
flutter run
```

If the container build fails for Flutter, rerun `flutter doctor` to see missing dependencies.
