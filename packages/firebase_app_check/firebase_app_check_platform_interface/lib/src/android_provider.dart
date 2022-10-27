// An enum representing the different types of Android App Attest providers.
enum AndroidProvider {
  // The debug provider
  debug,
  // The safety net provider (deprecated)
  @Deprecated(
    'Safety Net provider is deprecated and will be removed in a future release. Play Integrity is the recommended provider.',
  )
  safetyNet,
  // The play integrity provider (Firebase recommended)
  playIntegrity
}
