siteadd makes adding PHP-based websites to Apache simple.

* **Quick**: One command does the work.
* **Easy**: All you need for a working PHP-based site is the name and port.
* **Flexible**: Use a custom PHP configuration per-site.

siteadd is developed by Seiden Group.

## Usage

### addsite

The following flags are taken:

* `-n`: The name of the site to use. Must follow IBM i traditional object name
  rules. For example: `-n seidenphp`
* `-p`: The port to use for the web server. This must be a number from 0-65535,
  and unique (no other applications, including web servers, using it). You can
  use the `netstat` CL command to see what ports are used on your system. For
  example: `-p 8080`.
* `-I`: If the site should have its own PHP configuration. This lets you have
  a different set of INI files. The PHP INI is derived from a template, which
  will fill in site-specific variables, and merge the system extension INI
  directory with the template extension INI directory.
* `-P`: Overrides the detected version of PHP.
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
