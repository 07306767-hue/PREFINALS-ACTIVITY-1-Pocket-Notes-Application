# Pocket Notes

A Flutter app for managing books with SQLite storage and a saved light/dark
theme preference.

## Project structure

```text
lib/
  app/                         App entry widget and application configuration
  core/theme/                  Shared visual theme
  features/notes/
    data/repositories/         Notes storage implementation and contract
    domain/models/              Note model
    presentation/
      screens/                  Notes page
      widgets/                  Reusable note UI
  main.dart                     Application entry point
test/
  features/notes/               Notes page widget tests
```

Flutter's generated `android/`, `ios/`, `web/`, `windows/`, `linux/`, and
`macos/` directories contain the platform runners.

## SQLite on web

The web SQLite implementation needs its WASM and worker files. After fetching
packages in a fresh checkout, generate them with:

```sh
dart run sqflite_common_ffi_web:setup
```

Then run the app using the same browser and port when you want to keep using
the same browser database.

## Run and test

```sh
flutter pub get
flutter run
flutter test
```
