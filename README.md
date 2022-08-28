release version script
======================

A simple yet convenient bash script to create a semantic version tag and push it
to the git remote.

When calling for either a `major`, `minor` or `patch` update the script will
find the latest version in your git tags, create a respective new version, set
it as the tag for the current commit and push it to the remote.

It should work with Mac, Linux and Windows (with WSL).

## Usage

You can integrate `release-version.sh` into your project or use it via curl:

```sh
curl -so- https://raw.githubusercontent.com/simbo/release-version-script/latest/release-version.sh | bash -s <UPDATE>
```

The parameter `UPDATE` is required and should be either `major`, `minor` or `patch`.

### In any kind of Project

You can either copy `release-version.sh` into your project or use these commands
to create a script that calls the latest version of the release script via curl:

```sh
echo -e '#!/bin/bash\ncurl -so- https://raw.githubusercontent.com/simbo/release-version-script/latest/release-version.sh | bash -s $1' > release.sh
chmod +x release.sh
```

…and call it like this:

```sh
release.sh <UPDATE>
```

### In node.js Projects

When your project contains a `package.json` it will be automatically updated to
the new version when using the release script.

You can use the release script via curl directly in your `package.json` scripts:

```json
  "scripts": {
    "release": "curl -so- https://raw.githubusercontent.com/simbo/release-version-script/latest/release-version.sh | bash -s"
  },
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
