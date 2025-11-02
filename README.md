# math_app

A new Flutter project.

## Private ensayos

The original PDF and intermediate extraction files now live outside of the
published bundle under `private_assets/ensayos/`. This folder is ignored via
`.gitignore`, so you can keep sensitive material there without pushing it to a
public repository or build. Only the generated PNG questions in
`assets/ensayos/questions/` are included in the app.

If you need to regenerate the assets, place the source PDF inside
`private_assets/ensayos/`, run the conversion script locally, and copy the
resulting images back into `assets/ensayos/questions/`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
