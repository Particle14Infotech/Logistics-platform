# Deploying to the VPS

This is the first real deploy — `infra/nginx/nginx.conf` is a template
that's never been applied to a live server, and there's no CI/CD step
anywhere in `.github/workflows/` (those only run tests). Everything below
is manual, run by hand on the VPS over SSH.

Five domains need to resolve to the VPS's IP before starting: `raahmitr.com`,
`www.raahmitr.com`, `api.raahmitr.com`, `admin.raahmitr.com`,
`enterprise.raahmitr.com`.

## 1. Backend

```bash
git clone <repo-url> /opt/raahmitr   # or git pull if already cloned
cd /opt/raahmitr/backend
cp .env.example .env
```

Fill in `.env` for real. At minimum: `MONGO_URI` (Atlas), `JWT_ACCESS_SECRET`/
`JWT_REFRESH_SECRET` (real random secrets, not the `change_this_*`
placeholders), `RAZORPAY_KEY_ID`/`SECRET`/`WEBHOOK_SECRET`,
`FIREBASE_PROJECT_ID`/`CLIENT_EMAIL`/`PRIVATE_KEY`, `PORT=5000` (must match
`docker-compose.yml`'s port mapping — the dev default of `5050` doesn't).

Set `CLIENT_ORIGIN`/`ADMIN_ORIGIN`/`ENTERPRISE_ORIGIN` to
`https://admin.raahmitr.com` and `https://enterprise.raahmitr.com` (the
public website makes zero backend calls, so it doesn't need to be in this
CORS allowlist at all).

New in this deploy: `SENDGRID_API_KEY` + `EMAIL_FROM` are now actually used
(email/OTP verification, `backend/src/services/email.service.js`) — leaving
them blank doesn't break anything, it just logs the OTP to the server
console instead of emailing it, same graceful-degradation pattern as an
unconfigured Firebase/Maps/Razorpay.

```bash
cd /opt/raahmitr
docker compose -f infra/docker/docker-compose.yml up --build -d
curl -sf http://127.0.0.1:5000/health   # should return {"status":"ok",...}
```

## 2. Frontends

```bash
cd /opt/raahmitr/web-portal-admin && npm install && npm run build
cd /opt/raahmitr/web-portal-enterprise && npm install && npm run build

sudo mkdir -p /var/www/raahmitr
sudo cp -r /opt/raahmitr/website /var/www/raahmitr/website
sudo cp -r /opt/raahmitr/web-portal-admin/dist /var/www/raahmitr/web-portal-admin-dist
sudo cp -r /opt/raahmitr/web-portal-enterprise/dist /var/www/raahmitr/web-portal-enterprise-dist
```

(`website/` has no build step — it's copied as-is, `index.html` + `assets/`.)

## 3. nginx

```bash
sudo cp /opt/raahmitr/infra/nginx/nginx.conf /etc/nginx/sites-available/raahmitr.conf
sudo ln -s /etc/nginx/sites-available/raahmitr.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
sudo certbot --nginx -d raahmitr.com -d www.raahmitr.com -d api.raahmitr.com -d admin.raahmitr.com -d enterprise.raahmitr.com
```

Let certbot rewrite the config for HTTPS — don't hand-write the SSL
directives (see the comment at the top of `nginx.conf` for why).

## 4. Smoke test

- `https://raahmitr.com` loads the public site; hero chips show their text
  (there was a real z-index bug here during development — if the badges on
  the hero illustration are blank, it's back).
- `https://admin.raahmitr.com` loads the Admin portal's own login screen.
- `https://enterprise.raahmitr.com` loads the Enterprise portal's own login.
- `https://api.raahmitr.com/health` returns `{"status":"ok"}`.
- Log into Admin, open Pricing, try saving a negative base fare or a 0
  surge multiplier — should be rejected (this is one of the critical fixes
  from `git log`, worth confirming it actually made it to prod).
- Try `POST /api/v1/payment/refund` as a non-admin — should 403.

## Known open items

- `website/`'s app-download section is built (real Play Store links to
  `raahmitr.customer`/`raahmitr.driver`) but deliberately `hidden` and
  unlinked — the store listings aren't public yet. Remove the `hidden`
  attribute in `website/index.html` and re-link it from nav/footer once
  they are.
- Redis is in `.env.example` (`REDIS_URL`) but never referenced anywhere in
  `backend/src/` — no Redis container in `docker-compose.yml`, and none
  needed for this deploy.
