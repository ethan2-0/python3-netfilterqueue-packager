# Usage Instructions

Clone the repo, and run the build script.

~~~bash
./build.sh
~~~
================================================================================
That will create a Debian package and place it in the root of the repository. If
you want to build another package (possibly with different a configuration),
simply run

~~~bash
git clean
~~~

and then re-run the build script.

# Configuration

The configuration is located in `build.conf`. It's bash, so you can do anything
you would normally do in bash. There are three config options.

`archive_sha256`: A sha256 hash of the archive to be downloaded. This is checked
on every single download.

`archive_url`: The URL of the tarfile that contains the Python package to create
a Debian package of.

`package_version`: The version of the Debian package to create. This is used in
`DEBIAN/control` and the filename of the final package.
