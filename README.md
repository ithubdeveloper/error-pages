# Custom Error Pages

Reusable static error pages for web servers.

## Included Pages

Each page explains what happened, what visitors can do, and what site owners should check.

- [400.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/400.html) - 400 Bad Request
- [401.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/401.html) - 401 Unauthorized
- [403.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/403.html) - 403 Forbidden
- [404.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/404.html) - 404 Not Found
- [405.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/405.html) - 405 Method Not Allowed
- [408.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/408.html) - 408 Request Timeout
- [410.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/410.html) - 410 Gone
- [413.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/413.html) - 413 Payload Too Large
- [414.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/414.html) - 414 URI Too Long
- [415.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/415.html) - 415 Unsupported Media Type
- [429.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/429.html) - 429 Too Many Requests
- [431.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/431.html) - 431 Request Header Fields Too Large
- [451.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/451.html) - 451 Unavailable For Legal Reasons
- [500.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/500.html) - 500 Internal Server Error
- [501.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/501.html) - 501 Not Implemented
- [502.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/502.html) - 502 Bad Gateway
- [503.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/503.html) - 503 Service Unavailable
- [504.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/504.html) - 504 Gateway Timeout
- [505.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/505.html) - 505 HTTP Version Not Supported
- [507.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/507.html) - 507 Insufficient Storage
- [maintenance.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/maintenance.html) - 503 Temporary Maintenance
- [instructions.html](https://htmlpreview.github.io/?https://github.com/ithubdeveloper/error-pages/blob/improve-error-pages/instructions.html)

## Install

Works with nginx and Apache (2.2/2.4) on Debian, Ubuntu, RHEL, Rocky, Alma and Fedora.

### Script (auto-detects nginx / Apache)

```bash
git clone https://github.com/ithubdeveloper/error-pages.git
cd error-pages
sudo ./install.sh            # or --nginx / --apache / --all, --dir PATH
sudo ./install.sh --uninstall
```

Apache is enabled automatically (`a2enconf` on Debian/Ubuntu, `conf.d` on RHEL). For nginx the snippet `/etc/nginx/snippets/error-pages.conf` is installed; add `include /etc/nginx/snippets/error-pages.conf;` inside each `server {}` block.

### Debian / Ubuntu package

```bash
tools/build-deb.sh 1.0.0
sudo apt install ./error-pages_1.0.0_all.deb
```

## Customising

Pages are generated from `src/page.html.tpl` and the texts in `src/pages.json`. Edit them and run `python3 tools/build.py`.

## Quick Start (manual)

1. Easy way (clone directly on the server):

```bash
cd /tmp
git clone https://github.com/ithubdeveloper/error-pages.git
sudo mkdir -p /var/www/error-pages
sudo cp /tmp/error-pages/*.html /var/www/error-pages/
sudo chown -R root:root /var/www/error-pages
sudo chmod 644 /var/www/error-pages/*.html
```

2. Or copy files manually to your server:

```bash
sudo mkdir -p /var/www/error-pages
sudo cp *.html /var/www/error-pages/
sudo chown -R root:root /var/www/error-pages
sudo chmod 644 /var/www/error-pages/*.html
```

3. Configure your web server using the examples below.

4. Reload server config and test with curl.

## Nginx Example

Create a snippet file:

```nginx
# /etc/nginx/snippets/error-pages.conf
# full list: conf/nginx-error-pages.conf (400-507)
error_page 404 /error-pages/404.html;

location ^~ /error-pages/ {
    alias /var/www/error-pages/;
    internal;
}
```

Then include it inside your server block:

```nginx
server {
    listen 80;
    server_name example.com;

    root /var/www/html;

    include /etc/nginx/snippets/error-pages.conf;

    # Optional maintenance toggle
    # if (-f /var/www/error-pages/maintenance.flag) {
    #     return 503;
    # }
    # error_page 503 /error-pages/maintenance.html;
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

    # full list: conf/apache-error-pages.conf
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
