---
name: Next.js image cache busting
description: When replacing images in Next.js, rename the file to bust the cache instead of fighting .next/cache
type: feedback
---

When replacing an image file in a Next.js project, the old version gets stuck in both the Next.js image optimization cache and the browser cache. Deleting `.next` and restarting the dev server doesn't reliably fix it.

**Why:** Next.js caches optimized images aggressively, and browsers cache by URL. Same filename = same URL = cached version served.

**How to apply:** When swapping an image, always use a new filename (e.g. `image-v2.webp`) instead of overwriting. This gives a fresh URL that bypasses all caching layers. Don't waste time clearing `.next` or telling the user to hard refresh.
