# For firebase package development only

The contents of this directory are solely for use from within the `test` and
`example` directories. You should **never** reference the contents of this
directory from any other package or application.

## Use

Copy `config.json.sample` to `config.json` within this directory.
It must be populated with values from a Firebase application that you configure.
See https://firebase.google.com/docs/web/setup for details.

You'll notice that `config.json` is ignored in `.gitignore`. This is intentional
to ensure private Firebase configuration data is not committed to the public
repository. Be careful when sending pull requests to ensure your data is not
included.
