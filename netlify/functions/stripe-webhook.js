/**
 * stripe-webhook.js — Netlify Function
 *
 * Handles Stripe `checkout.session.completed` events.
 * On successful payment, delivers the digital product to the customer by email.
 *
 * Environment variables required (set in Netlify dashboard > Site settings > Environment):
 *   STRIPE_SECRET_KEY       — sk_live_... (Stripe secret key)
 *   STRIPE_WEBHOOK_SECRET   — whsec_... (from Stripe dashboard > Webhooks)
 *   POSTMARK_API_TOKEN      — (postmark-token-rotated)
 *   DOWNLOAD_URL            — The URL of the digital product PDF/ZIP to deliver
 *                             (set after CMO finalizes the digital product — NOD-132)
 *
 * Stripe webhook setup:
 *   1. Go to https://dashboard.stripe.com/webhooks
 *   2. Add endpoint: https://<your-netlify-site>.netlify.app/.netlify/functions/stripe-webhook
 *   3. Select event: checkout.session.completed
 *   4. Copy the signing secret → STRIPE_WEBHOOK_SECRET
 */

const stripe = require('stripe');
const postmark = require('postmark');

async function sendDeliveryEmail({ to, customerName, downloadUrl }) {
  const client = new postmark.ServerClient(process.env.POSTMARK_API_TOKEN);
  await client.sendEmail({
    From: 'AI Rev Playbook <hello@nodenetwork.ai>',
    To: to,
    Subject: 'Your AI Revenue Playbook is ready',
    HtmlBody: `
      <p>Hi ${customerName},</p>
      <p>Your purchase is confirmed. Access your playbook here:</p>
      <p><a href="${downloadUrl}">${downloadUrl}</a></p>
      <p>This link is active for 72 hours. Reply to this email if you have any issues.</p>
      <p>— The NodNetwork team</p>
    `,
    TextBody: `Hi ${customerName},\n\nYour purchase is confirmed. Access your playbook here:\n${downloadUrl}\n\nThis link is active for 72 hours. Reply to this email if you have any issues.\n\n— The NodNetwork team`,
    MessageStream: 'outbound',
  });
}

exports.handler = async (event) => {
  if (event.httpMethod !== 'POST') {
    return { statusCode: 405, body: 'Method Not Allowed' };
  }

  const stripeClient = stripe(process.env.STRIPE_SECRET_KEY);
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

  let stripeEvent;
  try {
    stripeEvent = stripeClient.webhooks.constructEvent(
      event.body,
      event.headers['stripe-signature'],
      webhookSecret
    );
  } catch (err) {
    console.error('Webhook signature verification failed:', err.message);
    return { statusCode: 400, body: `Webhook Error: ${err.message}` };
  }

  if (stripeEvent.type === 'checkout.session.completed') {
    const session = stripeEvent.data.object;
    const customerEmail = session.customer_details?.email;
    const customerName = session.customer_details?.name || 'there';
    const downloadUrl = process.env.DOWNLOAD_URL;

    if (!customerEmail) {
      console.error('No customer email in session:', session.id);
      return { statusCode: 200, body: 'OK (no email)' };
    }

    if (!downloadUrl) {
      // TODO: remove this guard once DOWNLOAD_URL is set (NOD-132 — CMO finalizing product)
      console.warn('DOWNLOAD_URL not set. Delivery skipped for session:', session.id);
      return { statusCode: 200, body: 'OK (delivery pending product URL)' };
    }

    try {
      await sendDeliveryEmail({ to: customerEmail, customerName, downloadUrl });
      console.log('Delivery email sent to:', customerEmail);
    } catch (err) {
      console.error('Failed to send delivery email:', err);
      // Return 200 so Stripe doesn't retry — log and investigate separately
    }
  }

  return { statusCode: 200, body: 'OK' };
};
