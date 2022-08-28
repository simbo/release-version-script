release version script
======================

A simple yet convenient bash script to create a semantic version tag and push it
to a git remote.

When calling for either a `major`, `minor` or `patch` update the script will
find the latest version in your git tags, create a respective new version, set
it as the tag for the current commit and push it to the remote.

## Usage

You can integrate the script into your project or use it via curl:

```sh
curl -s https://raw.githubusercontent.com/simbo/release-version-script/latest/release-version.sh | bash -s <UPDATE>
```

The parameter `UPDATE` is required and should be either `major`, `minor` or `patch`.

### In node.js Projects

When your project contains a `package.json` it will be automatically updated to
the new version.

You can use the script directly in your `package.json` scripts:

```json
{
  ...
  "scripts": {
    "release": "curl -s https://raw.githubusercontent.com/simbo/release-version-script/latest/release-version.sh | bash -s"
  },
  ...
}
```

…and call it with `npm`:

```sh
npm run release -- <UPDATE>
```

…or call it with `yarn`:

```sh
yarn release <UPDATE>
```

## License and Author

[MIT &copy; Simon Lepel](http://simbo.mit-license.org/)
