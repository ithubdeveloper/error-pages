#!/usr/bin/env bash
# Installer for error-pages: Debian/Ubuntu/RHEL family, nginx and Apache.
# Usage: sudo ./install.sh [--nginx|--apache|--all] [--dir /var/www/error-pages] [--uninstall]
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST=/var/www/error-pages
TARGET=auto
UNINSTALL=0

while [ $# -gt 0 ]; do
  case "$1" in
    --nginx) TARGET=nginx ;;
    --apache) TARGET=apache ;;
    --all) TARGET=all ;;
    --dir) DEST="$2"; shift ;;
    --uninstall) UNINSTALL=1 ;;
    -h|--help) sed -n '2,3p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

[ "$(id -u)" -eq 0 ] || { echo "Run as root (use sudo)." >&2; exit 1; }

has_nginx()  { command -v nginx >/dev/null 2>&1; }
has_apache() { command -v apache2ctl >/dev/null 2>&1 || command -v apachectl >/dev/null 2>&1 || command -v httpd >/dev/null 2>&1; }

if [ "$TARGET" = auto ]; then
  t=""
  has_nginx && t="nginx"
  has_apache && t="${t:+$t }apache"
  [ -n "$t" ] || { echo "Neither nginx nor Apache found; installing files only."; t="files"; }
  TARGET="$t"
elif [ "$TARGET" = all ]; then
  TARGET="nginx apache"
fi

NGINX_SNIPPET=/etc/nginx/snippets/error-pages.conf
if [ -d /etc/apache2/conf-available ]; then
  APACHE_CONF=/etc/apache2/conf-available/error-pages.conf; APACHE_DEBIAN=1
else
  APACHE_CONF=/etc/httpd/conf.d/error-pages.conf; APACHE_DEBIAN=0
fi
APACHE_SVC=apache2; [ "$APACHE_DEBIAN" = 1 ] || APACHE_SVC=httpd

reload() { systemctl reload "$1" 2>/dev/null || service "$1" reload 2>/dev/null || echo "Reload $1 manually."; }

# Fall back to the default path in the generated configs when --dir is used.
render() { sed "s#/var/www/error-pages#$DEST#g" "$1"; }

if [ "$UNINSTALL" = 1 ]; then
  rm -f "$NGINX_SNIPPET"
  if [ -f "$APACHE_CONF" ]; then
    [ "$APACHE_DEBIAN" = 1 ] && a2disconf error-pages >/dev/null 2>&1 || true
    rm -f "$APACHE_CONF"
    reload "$APACHE_SVC"
  fi
  rm -rf "$DEST"
  echo "Removed. Delete the include line from your nginx server blocks if you added it."
  exit 0
fi

install -d -m 755 "$DEST"
install -m 644 "$SRC"/[0-9][0-9][0-9].html "$SRC/maintenance.html" "$DEST/"
echo "Pages installed to $DEST"

for t in $TARGET; do
  case "$t" in
    nginx)
      install -d "$(dirname "$NGINX_SNIPPET")"
      render "$SRC/conf/nginx-error-pages.conf" > "$NGINX_SNIPPET"
      if nginx -t >/dev/null 2>&1; then
        echo "nginx: snippet written to $NGINX_SNIPPET"
        echo "       Add 'include $NGINX_SNIPPET;' inside each server {} block, then: nginx -t && systemctl reload nginx"
      fi
      ;;
    apache)
      install -d "$(dirname "$APACHE_CONF")"
      render "$SRC/conf/apache-error-pages.conf" > "$APACHE_CONF"
      [ "$APACHE_DEBIAN" = 1 ] && a2enconf error-pages >/dev/null
      CT=apachectl; command -v apachectl >/dev/null 2>&1 || CT=apache2ctl
      if $CT configtest >/dev/null 2>&1; then
        reload "$APACHE_SVC"; echo "apache: enabled via $APACHE_CONF"
      else
        echo "apache: config test failed, run '$CT configtest'" >&2; exit 1
      fi
      ;;
  esac
done
