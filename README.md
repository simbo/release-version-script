Release Version Script
======================

A simple yet convenient bash script to create a semantic version tag and push it
to the git remote.

When calling for either a `major`, `minor` or `patch` update the script will
find the latest version in your git tags, create a respective new version, set
it as the tag for the current commit and push it to the remote.

If your project contains a `package.json` it will be automatically updated to
the new version.

It should work with Mac, Linux and Windows (with WSL).

## Usage

Run this command in your project's root directory to install the release script:

```sh
curl -o- https://raw.githubusercontent.com/simbo/release-version-script/latest/install.sh | bash
```

Afterward, you can run the `./release.sh` command at any time to create and push
a new tag with semantic versioning:

```sh
./release.sh UPDATE
```

Allowed values for `UPDATE` are `major`, `minor` or `patch`.

## License and Author

[MIT &copy; Simon Lepel](http://simbo.mit-license.org/)
