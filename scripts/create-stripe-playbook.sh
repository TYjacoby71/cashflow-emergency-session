#!/usr/bin/env bash
# create-stripe-playbook.sh
# Creates the $47 Emergency Cashflow Playbook product in Stripe and outputs
# the payment link URL to wire into index.html (data-checkout-url).
#
# Usage:
#   export STRIPE_SECRET_KEY="sk_live_..."
#   bash scripts/create-stripe-playbook.sh
#
# After running: copy the buy.stripe.com URL printed at the end and replace
# PLACEHOLDER_CASHFLOW_PLAYBOOK_47 in src/index.html with it.

set -e

STRIPE_KEY="${STRIPE_SECRET_KEY:-}"
if [ -z "$STRIPE_KEY" ]; then
  echo "ERROR: Set STRIPE_SECRET_KEY env var first."
  exit 1
fi

AUTH="${STRIPE_KEY}:"

echo "==> Creating product: Emergency Cashflow Playbook..."
PRODUCT=$(curl -s -X POST "https://api.stripe.com/v1/products" --user "${AUTH}" \
  -d "name=Emergency Cashflow Playbook" \
  -d "description=5 executable cash plays, proven outreach scripts, and a 72-hour action map. Instant PDF delivery. Refund if you don't find 3 executable plays." \
  -d "url=https://cashflow.so/emergency-session" \
  -d "metadata[tier]=digital_pdf" \
  -d "metadata[delivery]=instant_email")
PRODUCT_ID=$(echo "$PRODUCT" | grep -o '"id":"prod_[^"]*"' | head -1 | cut -d'"' -f4)
echo "   Product ID: $PRODUCT_ID"

echo "==> Creating price: $47 one-time..."
PRICE=$(curl -s -X POST "https://api.stripe.com/v1/prices" --user "${AUTH}" \
  -d "product=${PRODUCT_ID}" \
  -d "unit_amount=4700" \
  -d "currency=usd")
PRICE_ID=$(echo "$PRICE" | grep -o '"id":"price_[^"]*"' | head -1 | cut -d'"' -f4)
echo "   Price ID: $PRICE_ID"

echo "==> Creating payment link..."
LINK=$(curl -s -X POST "https://api.stripe.com/v1/payment_links" --user "${AUTH}" \
  -d "line_items[0][price]=${PRICE_ID}" \
  -d "line_items[0][quantity]=1" \
  -d "after_completion[type]=redirect" \
  -d "after_completion[redirect][url]=https://cashflow.so/emergency-session?payment=success")
LINK_URL=$(echo "$LINK" | grep -o '"url":"[^"]*"' | head -1 | cut -d'"' -f4)
echo ""
echo "================================================================"
echo "Payment link: $LINK_URL"
echo "================================================================"
echo ""
echo "Next step: update src/index.html"
echo "  Replace:  PLACEHOLDER_CASHFLOW_PLAYBOOK_47"
echo "  With:     $LINK_URL"
echo ""
echo "Also update netlify/functions/stripe-webhook.js:"
echo "  Set STRIPE_PLAYBOOK_PRICE_ID=$PRICE_ID in Netlify env vars"
echo "  This triggers the PDF delivery webhook on payment."
echo ""
echo "Done. Verify: https://dashboard.stripe.com/products"
