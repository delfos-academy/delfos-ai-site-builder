#!/usr/bin/env node
// @ts-check
/**
 * Capture visual reference for the design system.
 *
 * Usage:
 *   node scripts/capture-reference.mjs --url https://linear.app --slug linear
 *   node scripts/capture-reference.mjs --url https://x.com --slug x --selectors "header,main"
 *   node scripts/capture-reference.mjs --url https://y.com --slug y --timeout 90000
 *
 * Output: docs/references/<slug>/{full.png, full-mobile.png, above-fold.png, page.html, styles.css, fonts.json, meta.json}
 *
 * Requires: playwright (`pnpm add -D playwright` and `pnpm dlx playwright install chromium`).
 */

import { chromium } from 'playwright';
import { mkdir, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { parseArgs } from 'node:util';

const { values } = parseArgs({
  options: {
    url: { type: 'string' },
    slug: { type: 'string' },
    selectors: { type: 'string' },
    timeout: { type: 'string', default: '60000' },
    out: { type: 'string', default: 'docs/references' },
  },
});

if (!values.url || !values.slug) {
  console.error('Usage: --url <url> --slug <slug> [--selectors "h,m,f"] [--timeout 60000]');
  process.exit(1);
}

const outDir = join(values.out, values.slug);
const timeout = Number(values.timeout);

await mkdir(outDir, { recursive: true });

const browser = await chromium.launch();
const ctx = await browser.newContext({
  viewport: { width: 1440, height: 900 },
  userAgent:
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
});
const page = await ctx.newPage();

console.log(`→ Navegando para ${values.url}`);
await page.goto(values.url, { waitUntil: 'networkidle', timeout });

// Aguarda fonts terminarem de carregar (evita screenshot com fallback)
await page.evaluate(() => document.fonts.ready);
await page.waitForTimeout(500);

console.log('→ Above-fold (1440×900)');
await page.screenshot({ path: join(outDir, 'above-fold.png'), fullPage: false });

console.log('→ Full-page desktop');
await page.screenshot({ path: join(outDir, 'full.png'), fullPage: true });

console.log('→ HTML renderizado');
const html = await page.content();
await writeFile(join(outDir, 'page.html'), html, 'utf8');

console.log('→ Computed styles (regras críticas)');
const computedCss = await page.evaluate(() => {
  /** @type {string[]} */
  const selectors = [
    'body',
    'h1',
    'h2',
    'h3',
    'p',
    'a',
    'button',
    'input',
    '[role="button"]',
    'nav',
    'header',
    'footer',
    'main',
    'section',
  ];
  /** @type {Record<string, Record<string, string>>} */
  const out = {};
  for (const sel of selectors) {
    const el = document.querySelector(sel);
    if (!el) continue;
    const cs = getComputedStyle(/** @type {Element} */ (el));
    out[sel] = {
      color: cs.color,
      backgroundColor: cs.backgroundColor,
      fontFamily: cs.fontFamily,
      fontSize: cs.fontSize,
      fontWeight: cs.fontWeight,
      letterSpacing: cs.letterSpacing,
      lineHeight: cs.lineHeight,
      borderRadius: cs.borderRadius,
      padding: cs.padding,
      backgroundImage: cs.backgroundImage,
    };
  }
  return out;
});
await writeFile(
  join(outDir, 'styles.css'),
  Object.entries(computedCss)
    .map(([sel, props]) => `${sel} {\n${Object.entries(props).map(([k, v]) => `  ${k}: ${v};`).join('\n')}\n}`)
    .join('\n\n'),
  'utf8',
);

console.log('→ Fonts detectadas');
const fonts = await page.evaluate(() => {
  const families = new Set();
  document.querySelectorAll('*').forEach((el) => {
    const f = getComputedStyle(el).fontFamily;
    if (f) families.add(f);
  });
  return [...families];
});
await writeFile(join(outDir, 'fonts.json'), JSON.stringify(fonts, null, 2), 'utf8');

if (values.selectors) {
  await mkdir(join(outDir, 'sections'), { recursive: true });
  const list = values.selectors.split(',').map((s) => s.trim()).filter(Boolean);
  for (const [i, sel] of list.entries()) {
    const el = await page.$(sel);
    if (!el) {
      console.warn(`  skip seletor "${sel}" (não encontrado)`);
      continue;
    }
    const name = sel.replace(/[^a-z0-9]+/gi, '-').slice(0, 40);
    const path = join(outDir, 'sections', `${String(i).padStart(2, '0')}-${name}.png`);
    await el.screenshot({ path });
    console.log(`  → section ${path}`);
  }
}

console.log('→ Mobile full-page (375×812)');
await page.setViewportSize({ width: 375, height: 812 });
await page.waitForTimeout(300);
await page.screenshot({ path: join(outDir, 'full-mobile.png'), fullPage: true });

await writeFile(
  join(outDir, 'meta.json'),
  JSON.stringify(
    {
      url: values.url,
      slug: values.slug,
      capturedAt: new Date().toISOString(),
      viewport: { desktop: '1440x900', mobile: '375x812' },
      title: await page.title(),
    },
    null,
    2,
  ),
  'utf8',
);

await browser.close();
console.log(`✓ Pronto: ${outDir}/`);
