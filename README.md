# Flappy Bird (Flutter)

This repository contains a Flutter remake of Flappy Bird. This README covers how to build the app, prepare a release bundle, and how to handle large media (video) assets safely in the repository.

## Highlights
- Flame-based Flappy Bird game
- Google Mobile Ads integration
- Persistent high-score saved with Hive
- Release-ready Gradle signing support (see `android/key.properties.template`)

## Quick Start (development)
1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Get dependencies:

```powershell
flutter pub get
```

3. Run on an emulator or device:

```powershell
flutter run
```

## Building a Release App Bundle (AAB)
This project includes Gradle wiring to load `android/key.properties` for signing. `android/key.properties.template` shows the required keys.

1. Create a secure keystore (or use an existing one). The project contains an optional script for Windows at `android/scripts/generate_keystore.ps1` which will create `android/key.jks` and a local `android/key.properties`. Keep those files secret.

2. Verify `android/key.properties` exists and contains:

```text
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=<your-key-alias>
storeFile=key.jks
```

3. Build the AAB:

```powershell
flutter build appbundle --release
```

The resulting AAB will be at `build/app/outputs/bundle/release/app-release.aab`.

### Security notes
- Do NOT commit `android/key.properties` or `android/key.jks` to your repository.
- `android/.gitignore` already excludes `key.properties` and `*.jks`.
- Back up your keystore securely — losing it will prevent updating your app on Google Play (unless you follow Play App Signing migration).

## Ads (AdMob)
AdMob is already integrated. Use test ad unit IDs during development. The app places the AdMob application id in `AndroidManifest.xml` and the banner ad is created in the game.

## High score
High scores are persisted using Hive. Hive is initialized at app start (`HighScoreService.initialize()` in `main.dart`).

## Including video files (recommended approach)
If you want to include demo videos (screen recordings, trailers), please follow these recommendations to keep the repo usable and lightweight.

### Recommended: Host videos externally (preferred)
- Upload demo videos to YouTube, Vimeo, or a CDN and link/embed them in the README. This keeps the repo small and fast to clone.

Embed example (YouTube):

```markdown
[![Demo Video](https://img.youtube.com/vi/<VIDEO_ID>/0.jpg)](https://www.youtube.com/watch?v=<VIDEO_ID>)
```

### If you must store videos in the repo (use Git LFS)
Git is not ideal for large binary blobs. If you decide to store videos in the repository, use Git LFS to avoid making clones huge.

Install Git LFS (Windows PowerShell example):

```powershell
# Install Git LFS (if not installed) - run as admin if necessary
# Using Chocolatey (if you have it):
# choco install git-lfs
# Or download from https://git-lfs.github.com/ and run installer

# Initialize Git LFS in this repo
git lfs install
```

Track common video extensions with Git LFS (run once):

```powershell
git lfs track "*.mp4"
git lfs track "*.mov"
git lfs track "*.webm"
git add .gitattributes
git commit -m "track video files with git lfs"
```

This repository includes a `.gitattributes` file that already marks common video extensions for LFS. Make sure you have Git LFS installed before adding large files.

### Embedding stored videos in README
If you store small demo videos in the repo (recommended only for short clips) you can reference them like:

```markdown
<video src="./assets/videos/demo.mp4" controls width="640"></video>
```

Note: GitHub will not autoplay videos in README, but will display them in supported contexts. Large videos will still bloat clones — prefer external hosting.

## Contributing
- Please open issues for bugs or feature requests.
- If you add media, follow the Git LFS steps above.

## Troubleshooting
- If Gradle fails to find signing keys, ensure `android/key.properties` exists and `storeFile` path is correct (relative to `android/`).
- If ads fail to load in development, ensure you use test ad unit IDs.

## License
This project is provided as-is. Replace this section with your preferred license.
