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
  with `-I` to work properly. The PHP version of the chroot will be detected,
  so use `-P` to override.
* `-C`: If the htdocs directory should be populated with the contents of
  another site. The other site must exist.
* `-Y`: If the web server should start automatically. Default.
* `-N`: If the web server should *not* start automatically.`
* `-T`: Override the default template directory. If a path isn't specified
  (this is done through including a directory separator), then siteadd will
  treat the name as a subdirectory of `/QOpenSys/pkgs/share/siteadd`.
* `-A`: Override the default bind address. Must be a valid IPv4/IPv6 address,
  or a wildcard (default) to bind to all.

#### Examples

For example, to make a site with its own PHP configuration:

```shell
addsite -p 8080 -n testsite
```

To make a new site, using the global PHP configuration, and using a template
of `my-template` installed in the system template directory:

```shell
addsite -p 8081 -n testsite2 -i -T my-template
```

To make a new site, copying the contents of `htdocs` from the `oldsite` site:

```shell
addsite -p 8082 -n testsite3 -C oldsite
```

To make a new site, using a chroot, and making it always autostart:

```shell
addsite -p 8083 -n testsite4 -c /QOpenSys/chroots/php81 -Y
```

To make a new site, using a chroot, and forcibly setting a specific version of
PHP to use for templates, and making it not autostart:

```shell
addsite -p 8084 -n testsite5 -c /QOpenSys/chroots/php81 -P 8.1 -N
```

### rmsite

Takes the name of the site, and optionally the `-r` flag.

Regardless, It will end the HTTP server, unregister the site from the known
list of sites, and (optionally) remove the directory.

#### Examples

To delete a site, but not delete any files in `/www`:

```shell
rmsite badsite
```

To delete a site and delete all its files (**destructive**):

```shell
rmsite -f badsite
```

### dspsite

The only argument taken is the name of the site. It will display file and
directory locations for the web server.

#### Examples

```shell
dspsite rpmserver
```

Outputs:

```
Physical file: /QSYS.LIB/QUSRSYS.LIB/QATMHINSTC.FILE/rpmserver.MBR
-apache -d /www/rpmserver -f conf/httpd.conf

Site directory (logs, htdocs, conf): /www/rpmserver
Log file (global): /QOpenSys/var/log/php_error.log
PHP config dir (i.e. php.ini) (global): /QOpenSys/etc/php
```

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

#### Examples

To use the template `my-template in `/QOpenSys/pkgs/share/siteadd`, on the
global PHP configuration:

```shell
transform-php-config -T my-template
```

To use the template `my-template` in the current working directory, on a
site-specific configuration:

```shell
transform-php-config -T ./my-template -d /www/mysite/phpconf
```

### toggle-db

This script toggles between classic and ODBC database extensions for a PHP
extension configuration directory (by default, the system one).

This used to be important in the Before Times of when database extensions were
mutually exclusive. Now, that both can be used in parallel, it's no longer
needed. We provide it still, as a way to make sure old sites can be easily
switched to use both.

The following flags are taken:

* `-d`: Optional. The directory to use instead.
* `-t`: Mandatory. The extension archetype. Use "classic", "odbc", or "both"
  here.

#### Examples

To make sure both classic and ODBC database extensions are used globally (this
is default in current CP+, but not in old):

```shell
toggle-db -t both
```

To enable both kinds of extensions for a specific site:

```shell
toggle-db -t both -d /www/sitename/phpconf/conf.d
```

### toggle-autostart

Displays or sets if an Apache web server should start on IPL. Only displays
by default.

The following flags are taken:

* `-n`: Mandatory. The site's name.
* `-Y`: Optional. The site should start on IPL.
* `-N`: Optional. The site shouldn't start on IPL.

#### Examples

To enable a site to start on IPL:

### generate-resolv

Generates an AIX `resolv.conf`. Intended for programs that do DNS queries
themselves or via libresolv, as they don't pick up the IBM i configuration.
This saves you the effort of porting over your settings.

#### Examples

Take the current configuration and put it in `/etc/resolv.conf`:

```shell
$ generate-resolv > /etc/resolv.conf
```

Note that programs depending on reading the resolver configuration will look
for it at that location. It's tempting to put it in `/QOpenSys/etc`, but that
won't work.

### qtimzon2iana

Internal program used by siteadd for converting IBM i `*TIMZON` objects to
their IANA zoneinfo names, but generally useful.

Takes IBM i time zone names as arguments and writes the IANA names back.
If no names are given, then use the system value `QTIMZON`.
Use `*ALL` to write out all names.

#### Examples

Show the current IBM i time zone in IANA form:

```
$ qtimzon2iana
America/New_York
```

Show a time zone object with IANA name:

```
$ qtimzon2iana QN0400AST
Atlantic/Bermuda
```

### update-ini-for-nortl

Automatically updates the INI files to omit references to extensions that are
now built into the PHP binary rather than loaded as extensions, as of August
12th, 2024.

It takes a list of site names to update.

This is not needed for the "global" PHP config (`/QOpenSys/etc/php/conf.d`),
as RPM will automatically adjust it if you haven't manually edited the files.

#### Examples

Run for sites `seidenphp` and `newsite`:

```
$ update-ini-for-nortl seidenphp newsite
```

### update-ini-for-8.5

Automatically updates the INI files to omit references to opcache, which is
now built into the main PHP executable as of 8.5. Otherwise, you'll get a
(harmless) warning that it can't load opcache.

It takes a list of site names to update.

This is not needed for the "global" PHP config (`/QOpenSys/etc/php/conf.d`),
as RPM will automatically adjust it if you haven't manually edited the files.

#### Examples

Run for sites `seidenphp` and `newsite`:

```
$ update-ini-for-8.5 seidenphp newsite
```

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
