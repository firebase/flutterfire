# Note on folder structure

`lib/auth` contains separate files for different OAuth providers.

The reason for this structure is that each file transitively depends on the underlying `*_sign_in` package.

We don't force users to install all available `*_sign_in` packages, neither we bundling those together with the library, so whenever users import `<Provider>SignInButton` to their app code – they will see a "Missing plugin" exception with a name of the plugin that should be installed
