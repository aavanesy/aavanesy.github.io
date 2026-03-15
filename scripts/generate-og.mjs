/**
 * Generate OG image using Playwright
 * Renders an HTML template at 1200x630 and saves as PNG
 */

import { chromium } from 'playwright';
import { writeFileSync, readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, '..');

// Read the headshot as base64
const headshotPath = join(ROOT, 'public', 'head_shot.png');
const headshotBase64 = readFileSync(headshotPath).toString('base64');

// Read the dark concept as base64
const darkConceptPath = join(ROOT, 'public', 'dark_concept.png');
const darkConceptBase64 = readFileSync(darkConceptPath).toString('base64');

const html = `<!DOCTYPE html>
<html>
<head>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Plus+Jakarta+Sans:wght@400;500;600&display=swap');

    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      width: 1200px;
      height: 630px;
      overflow: hidden;
      background-color: #171410;
      background-image: url('data:image/png;base64,${darkConceptBase64}');
      background-size: cover;
      background-position: center;
      font-family: 'Plus Jakarta Sans', sans-serif;
      display: flex;
      align-items: center;
      padding: 0 80px;
    }

    .container {
      display: flex;
      align-items: center;
      gap: 64px;
      width: 100%;
    }

    .portrait-wrapper {
      flex-shrink: 0;
      position: relative;
    }

    .portrait-frame {
      position: absolute;
      inset: -8px;
      border: 1px solid rgba(184, 150, 62, 0.25);
    }

    .portrait {
      width: 220px;
      height: 220px;
      object-fit: cover;
      filter: grayscale(20%);
    }

    .content {
      flex: 1;
    }

    .label {
      color: #B8963E;
      font-size: 11px;
      letter-spacing: 0.3em;
      text-transform: uppercase;
      margin-bottom: 20px;
      font-weight: 600;
    }

    .name {
      font-family: 'Playfair Display', Georgia, serif;
      font-size: 64px;
      font-weight: 700;
      color: #F8F4ED;
      line-height: 0.95;
      margin-bottom: 24px;
      letter-spacing: -0.02em;
    }

    .divider {
      width: 48px;
      height: 1px;
      background: #B8963E;
      margin-bottom: 24px;
    }

    .tagline {
      color: #8A7D6B;
      font-size: 16px;
      letter-spacing: 0.05em;
    }

    .url {
      position: absolute;
      bottom: 40px;
      right: 80px;
      color: #4A4038;
      font-size: 13px;
      letter-spacing: 0.1em;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="portrait-wrapper">
      <div class="portrait-frame"></div>
      <img class="portrait" src="data:image/png;base64,${headshotBase64}" alt="" />
    </div>
    <div class="content">
      <div class="label">Quantitative Finance & Data Science</div>
      <div class="name">Arkadi<br>Avanesyan</div>
      <div class="divider"></div>
      <div class="tagline">Courses · Corporate Training · Quant R</div>
    </div>
  </div>
  <div class="url">aavanesy.github.io</div>
</body>
</html>`;

async function main() {
  const browser = await chromium.launch();
  const page = await browser.newPage({
    viewport: { width: 1200, height: 630 },
    deviceScaleFactor: 2,
  });

  await page.setContent(html, { waitUntil: 'networkidle' });
  await page.waitForTimeout(1000); // let fonts load

  const screenshot = await page.screenshot({ type: 'png' });

  const ogPath = join(ROOT, 'public', 'og-image.png');
  writeFileSync(ogPath, screenshot);
  console.log(`✓ OG image saved to ${ogPath}`);

  // Also save as og.png
  const ogPath2 = join(ROOT, 'public', 'og.png');
  writeFileSync(ogPath2, screenshot);
  console.log(`✓ OG image saved to ${ogPath2}`);

  await browser.close();
}

main().catch(console.error);
