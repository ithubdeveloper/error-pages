# Custom Error Pages

Reusable static error pages for web servers.

## Included Pages

- 403.html
- 404.html
- 429.html
- 500.html
- 502.html
- 503.html
- 504.html
- maintenance.html
- instructions.html

## Quick Start

1. Copy files to your server:

```bash
sudo mkdir -p /var/www/error-pages
sudo cp *.html /var/www/error-pages/
sudo chown -R root:root /var/www/error-pages
sudo chmod 644 /var/www/error-pages/*.html
```

2. Configure your web server using the examples below.

3. Reload server config and test with curl.

## Nginx Example

```nginx
server {
    listen 80;
    server_name example.com;

    root /var/www/html;

    error_page 403 /error-pages/403.html;
    error_page 404 /error-pages/404.html;
    error_page 429 /error-pages/429.html;
    error_page 500 /error-pages/500.html;
    error_page 502 /error-pages/502.html;
    error_page 503 /error-pages/503.html;
    error_page 504 /error-pages/504.html;

    # Optional maintenance toggle
    # if (-f /var/www/error-pages/maintenance.flag) {
    #     return 503;
    # }
    # error_page 503 /error-pages/maintenance.html;

    location /error-pages/ {
        alias /var/www/error-pages/;
        internal;
    }
}
```

Reload Nginx:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

## Apache Example

```apache
<VirtualHost *:80>
    ServerName example.com
    DocumentRoot /var/www/html

    Alias /error-pages/ "/var/www/error-pages/"
    <Directory "/var/www/error-pages">
        Options -Indexes
        AllowOverride None
        Require all granted
    </Directory>

    ErrorDocument 403 /error-pages/403.html
    ErrorDocument 404 /error-pages/404.html
    ErrorDocument 429 /error-pages/429.html
    ErrorDocument 500 /error-pages/500.html
    ErrorDocument 502 /error-pages/502.html
    ErrorDocument 503 /error-pages/503.html
    ErrorDocument 504 /error-pages/504.html

    # Optional maintenance page
    # ErrorDocument 503 /error-pages/maintenance.html
</VirtualHost>
```

Reload Apache:

```bash
sudo apachectl configtest
sudo systemctl reload apache2
```

## Validation

```bash
curl -I http://example.com/non-existing-page
curl -s http://example.com/non-existing-page | head
```

## Notes

- instructions.html contains a full setup guide in page format.
- On Nginx, keep /error-pages/ internal to avoid direct public browsing.
- On Apache, keep directory listing disabled with Options -Indexes.
