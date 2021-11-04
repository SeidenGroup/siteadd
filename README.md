siteadd makes adding PHP-based websites to Apache simple.

* **Quick**: One command does the work.
* **Easy**: All you need for a working PHP-based site is the name and port.
* **Flexible**: Use a custom PHP configuration per-site.

Additional tools are provided for easy management of sites.
siteadd is open source software developed by Seiden Group.

## Notes on licensing

siteadd is licensed under an open source license (GPLv3), but this only affects
the code tagged with it. **Templates can be freely derived and shared**,
without worrying about if the open source license applies to your own template
or application. Our intent with this structure is to make sure siteadd can be
improved by the community, while allowing ISVs and consultants to not worry
about their domain-specific/proprietary knowledge.

## Usage

### addsite

The following flags are taken:

* `-n`: The name of the site to use. Must follow IBM i traditional object name
  rules. For example: `-n seidenphp`
* `-p`: The port to use for the web server. This must be a number from 0-65535,
  and unique (no other applications, including web servers, using it). You can
  use the `netstat` CL command to see what ports are used on your system. For
  example: `-p 8080`.
* `-f`: if the port requested is already being listened on, use it anyways
  instead of stopping. Useful for if you'll change the required settings after
  or if the configuration file is just for show.
* `-I`: If the site should have its own PHP configuration. This lets you have
  a different set of INI files. The PHP INI is derived from a template, which
  will fill in site-specific variables, and merge the system extension INI
  directory with the template extension INI directory. Now the default.
* `-i`: If the site should use the global PHP configuration. This will disable
  some useful features like setting the time zone in the configuration enabled
  by template transforms done by site-specific configuration.
* `-P`: Overrides the detected version of PHP.
* `-c`: The path to the chroot to use as a prefix. Note that this does *not*
  actually chroot, but uses the PHP binaries from within the chroot. Must use
  with `-I` to work properly, and you almost certainly want `-P` with that.
* `-C`: If the htdocs directory should be populated with the contents of
  another site. The other site must exist.
* `-Y`: If the web server should start automatically. Default.
* `-N`: If the web server should *not* start automatically.`
* `-T`: Override the default template directory. If a path isn't specified
  (this is done through including a directory separator), then siteadd will
  treat the name as a subdirectory of `/QOpenSys/pkgs/share/siteadd`.

For example, to make a site with its own PHP configuration:

```shell
addsite -p 8080 -n testsite -I
```

To make the site use the template for legacy database extensions:`

```shell
addsite -p 8080 -n testsite -I -T template-legacy-db
```

### rmsite

The only argument taken is the name of the site. It will end the HTTP server,
unregister the site from the known list of sites, and remove the directory.

### transform-php-config

This transforms an existing PHP configuration in place. Its purpose is so you
can apply a template's configuration onto the global PHP configuration.

The following flags are taken.

* `-d`: Optional. The directory to use for the PHP configuration containing
  files like `php.ini`. By default, `/QOpenSys/etc/php`.
* `-P`: Overrides the detected version of PHP.
* `-T`: Override the default template directory. If a path isn't specified
  (this is done through including a directory separator), then siteadd will
  treat the name as a subdirectory of `/QOpenSys/pkgs/share/siteadd`.

### toggle-db

This script toggles between classic and ODBC database extensions for a PHP
extension configuration directory (by default, the system one).

The following flags are taken:

* `-d`: Optional. The directory to use instead.
* `-t`: Mandatory. The extension archetype. Use "classic" or "odbc" here.

### toggle-autostart

Displays or sets if an Apache web server should start on IPL. Only displays
by default.

The following flags are taken:

* `-n`: Mandatory. The site's name.
* `-Y`: Optional. The site should start on IPL.
* `-N`: Optional. The site shouldn't start on IPL.

### qtimzon2iana

Internal program used by siteadd for converting IBM i `*TIMZON` objects to
their IANA zoneinfo names, but generally useful.

Takes IBM i time zone names as arguments and writes the IANA names back.
If no names are given, then use the system value `QTIMZON`.
Use `*ALL` to write out all names.

## Template structure

The `-T` flag is used to override what templates are used for substitutions.
The templates are m4 files with certain variables given. Consult the templates
and script for the variables to use for a custom template.

* `preflight.sh`: Optional. If run, a non-zero return code will fail.
* `template-httpd.m4`: Filled in as `SITEDIR/conf/httpd.conf`
* `template-fastcgi.m4`: Filled in as `SITEDIR/fastcgi.conf` (zend enabler)
* `htdocs`: Filled in as `SITEDIR/htdocs` (copies)
  * `htdocs-template` has a list of files without the `.m4` extension to apply
    an m4 transform to.
* `phpconf-$VERSION`: Filled in as `SITEDIR/phpconf`
  * `php.ini.m4` is filled in as `php.ini`. The system `conf.d` directory is
    copied to `phpconf/conf.d` and the template files (if any) are copied over.
    By copying the system `conf.d` directory, it doesn't need to be aware of
    any new extensions.
