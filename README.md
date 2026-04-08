# Emergency Session Site

Static landing site for the Emergency Cashflow Command Session.

## Structure
- `src/index.html` - main landing page
- `src/styles.css` - site styling
- `src/hold-slot/index.html` - hosted manual invoice / standby intake fallback

## Local smoke test
From this folder, serve `src/` with any static HTTP server.

### PowerShell
```powershell
cd C:\Users\jacob\.openclaw\workspace\sites\emergency-session\src
python -m http.server 4174
```

Then open:
- `http://127.0.0.1:4174/`
- `http://127.0.0.1:4174/hold-slot/`

## Production link behavior
The landing page reads three body-level attributes:
- `data-checkout-url`
- `data-calendly-url`
- `data-invoice-url`

Current hardening behavior:
- If `data-checkout-url` still contains `PLACEHOLDER`, the Stripe iframe is suppressed and the CTA routes to the hold-slot fallback.
- If `data-calendly-url` is missing or placeholder, scheduling CTAs also route to the hold-slot fallback.
- `data-invoice-url` is set to `./hold-slot/` so the fallback survives public hosting.

## Hosting plan
### Netlify (fastest)
- Publish directory: `src`
- Forms: enabled (`src/hold-slot/index.html` already includes Netlify form attributes)
- Optional custom domain: point the chosen cashflow subdomain at the Netlify site

### Vercel
- Framework preset: Other
- Root directory: `sites/emergency-session`
- Output directory: `src`
- Note: Vercel will host the static pages, but the hold-slot form needs an alternate form backend because Netlify form capture is not available there.

## Blocking production inputs
- Live Stripe checkout URL for the Emergency Session SKU
- Final production Calendly event URL (workspace has conflicting references)
- Hosting account/domain decision if publishing tonight
