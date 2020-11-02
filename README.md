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
* `-I`: If the site should have its own PHP configuration. This is used if you
  want to use a different set of extensions, for example. The new PHP config
  will be under the site's `phpconf` folder and copied from the
  `/QOpenSys/etc/php` directory.
* `-Y`: If the web server should start automatically.`
* `-N`: If the web server should *not* start automatically.`

Some additional flags are used to override what templates are used. The
templates are m4 files with certain variables given. Consult the templates
and script for the variables to use for a custom template.

* `-h`: `httpd.conf`
* `-H`: `index.html`
* `-f`: `fastcgi.conf` (zend enabler)

### rmsite

The only argument taken is the name of the site. It will unregister the site
from the known list of sites, and remove the directory.
