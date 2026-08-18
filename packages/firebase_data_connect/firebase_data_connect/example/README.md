# Firebase Data Connect Example

This example showcases Firebase Auth and Data Connect.

## Getting Started

1. Sign up for early access [here](https://firebase.google.com/products/data-connect) and receive an invitation.

    Note: This is not required for public preview.
2. Upgrade your Firebase project billing to the Blaze plan, you will not be charged for the duration of gated preview.
3. Initialize DataConnect in the [Firebase Console](https://console.firebase.google.com/u/0/).
4. Install postgres using the documentation provided [here](https://firebase.google.com/docs/data-connect/quickstart#optional_install_postgresql_locally).
5. Update `firebase-tools` with `npm install -g firebase-tools`.
6. Initialize your Firebase project in the `dataconnect` folder with `firebase init` and select DataConnect. Do not overwrite the dataconnect files when prompted.
7. Install the VSCode extension from [here](https://firebasestorage.googleapis.com/v0/b/firemat-preview-drop/o/vsix%2Ffirebase-vscode-latest.vsix?alt=media).
8. Run the mutation in `dataconnect/connector/movie_insert.gql`
9. Run `flutter run`

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
