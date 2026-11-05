#!/usr/bin/env bash
# Build error-pages_<version>_all.deb (Debian/Ubuntu). Usage: tools/build-deb.sh [version]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER="${1:-1.0.0}"
B="$(mktemp -d)"; trap 'rm -rf "$B"' EXIT
install -d "$B/DEBIAN" "$B/var/www/error-pages" "$B/etc/nginx/snippets" "$B/usr/share/error-pages"
install -m 644 "$ROOT"/[0-9][0-9][0-9].html "$ROOT/maintenance.html" "$B/var/www/error-pages/"
install -m 644 "$ROOT/conf/nginx-error-pages.conf" "$B/etc/nginx/snippets/error-pages.conf"
install -m 644 "$ROOT/conf/apache-error-pages.conf" "$B/usr/share/error-pages/apache-error-pages.conf"
cat > "$B/DEBIAN/control" <<EOF
Package: error-pages
Version: $VER
Architecture: all
Maintainer: ithubdeveloper
Section: web
Priority: optional
Suggests: nginx | apache2
Description: Static custom error pages for nginx and Apache
 Styled, explained error pages (400-507, maintenance) plus ready-made
 nginx snippet and Apache configuration.
EOF
cat > "$B/DEBIAN/postinst" <<'EOF'
#!/bin/sh
set -e
if [ -d /etc/apache2/conf-available ]; then
  install -m 644 /usr/share/error-pages/apache-error-pages.conf /etc/apache2/conf-available/error-pages.conf
  command -v a2enconf >/dev/null && a2enconf error-pages >/dev/null || true
  systemctl reload apache2 >/dev/null 2>&1 || true
fi
exit 0
EOF
cat > "$B/DEBIAN/prerm" <<'EOF'
#!/bin/sh
set -e
if [ -f /etc/apache2/conf-available/error-pages.conf ]; then
  command -v a2disconf >/dev/null && a2disconf error-pages >/dev/null || true
  rm -f /etc/apache2/conf-available/error-pages.conf
  systemctl reload apache2 >/dev/null 2>&1 || true
fi
exit 0
EOF
chmod 755 "$B/DEBIAN/postinst" "$B/DEBIAN/prerm"
dpkg-deb --build --root-owner-group "$B" "$ROOT/error-pages_${VER}_all.deb"
