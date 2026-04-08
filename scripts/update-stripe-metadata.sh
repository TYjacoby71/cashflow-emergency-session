#!/usr/bin/env bash
# update-stripe-metadata.sh
# Run this once to fill out Stripe product metadata for all 4 live products.
# Requires: STRIPE_SECRET_KEY env var or edit the STRIPE_KEY line below.
#
# Usage:
#   export STRIPE_SECRET_KEY="sk_live_..."
#   bash scripts/update-stripe-metadata.sh

set -e

STRIPE_KEY="${STRIPE_SECRET_KEY:-}"
if [ -z "$STRIPE_KEY" ]; then
  echo "ERROR: Set STRIPE_SECRET_KEY env var first."
  exit 1
fi

BASE="https://api.stripe.com/v1/products"
AUTH="${STRIPE_KEY}:"

echo "==> Updating ReadyClaw Installer (prod_UIKkurWthvezFc)..."
curl -s -X POST "${BASE}/prod_UIKkurWthvezFc" --user "${AUTH}" \
  -d "name=ReadyClaw Installer" \
  -d "description=A fully configured AI command unit—persona, skills, and checklists—packaged for one-click setup. Download once, deploy on any computer. No terminal commands, no configuration required." \
  -d "url=https://readyclaw.nodenetwork.ai" \
  | grep -o '"id":"[^"]*"'

echo "==> Updating Emergency Cashflow Command Session (prod_UIKklqwYo5wfYe)..."
curl -s -X POST "${BASE}/prod_UIKklqwYo5wfYe" --user "${AUTH}" \
  -d "name=Emergency Cashflow Command Session" \
  -d "description=A live 90-minute war-room for founders who need executable revenue plays now—not another strategy deck. We map the shortest path to cash, build the scripts live, and leave you with a hard 72-hour execution calendar. Includes T+24h follow-up." \
  -d "url=https://cashflow.so/emergency-session" \
  | grep -o '"id":"[^"]*"'

echo "==> Updating Automation Audit (prod_UIKkOBPRm2UDGW)..."
curl -s -X POST "${BASE}/prod_UIKkOBPRm2UDGW" --user "${AUTH}" \
  -d "name=Automation Audit" \
  -d "description=A complete audit of your business operations to identify automation opportunities, revenue leaks, and execution bottlenecks. Delivered as a prioritized action plan with implementation scope and ROI estimates." \
  -d "url=https://cashflow.so/automation-audit" \
  | grep -o '"id":"[^"]*"'

echo "==> Updating Integration Wizard Bundle (prod_UIKkKgjyvyPgnm)..."
curl -s -X POST "${BASE}/prod_UIKkKgjyvyPgnm" --user "${AUTH}" \
  -d "name=Integration Wizard – Starter Download" \
  -d "description=The Integration Wizard starter bundle: install guides, persona templates, and configuration checklists to connect your tools and automate your workflow. One-time download, no subscription." \
  -d "url=https://integrationwizard.nodenetwork.ai" \
  | grep -o '"id":"[^"]*"'

echo ""
echo "Done. Verify in Stripe dashboard: https://dashboard.stripe.com/products"
