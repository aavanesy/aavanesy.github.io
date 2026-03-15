/**
 * Automated Design Critique Loop
 *
 * Takes Playwright screenshots of all pages (desktop + mobile),
 * sends them to Claude Sonnet for design critique, outputs feedback.
 *
 * Usage: node scripts/design-critic.mjs
 */

import { chromium } from 'playwright';
import Anthropic from '@anthropic-ai/sdk';
import { readFileSync, writeFileSync, mkdirSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const SCREENSHOTS_DIR = join(__dirname, '..', 'screenshots');
const BASE_URL = 'http://localhost:4321';

const PAGES = [
  { path: '/', name: 'home' },
  { path: '/courses', name: 'courses' },
  { path: '/training', name: 'training' },
  { path: '/quant-r', name: 'quant-r' },
  { path: '/tutorials', name: 'tutorials' },
];

const VIEWPORTS = [
  { name: 'desktop', width: 1440, height: 900 },
  { name: 'mobile', width: 390, height: 844 },
];

async function takeScreenshots() {
  mkdirSync(SCREENSHOTS_DIR, { recursive: true });

  const browser = await chromium.launch();
  const screenshots = [];

  for (const viewport of VIEWPORTS) {
    const context = await browser.newContext({
      viewport: { width: viewport.width, height: viewport.height },
      deviceScaleFactor: 2,
    });
    const page = await context.newPage();

    for (const pg of PAGES) {
      const filename = `${pg.name}-${viewport.name}.png`;
      const filepath = join(SCREENSHOTS_DIR, filename);

      try {
        await page.goto(`${BASE_URL}${pg.path}`, { waitUntil: 'networkidle', timeout: 15000 });
        await page.waitForTimeout(500); // let fonts/images load
        await page.screenshot({ path: filepath, fullPage: true });
        screenshots.push({ page: pg.name, viewport: viewport.name, filepath, filename });
        console.log(`  ✓ ${filename}`);
      } catch (e) {
        console.log(`  ✗ ${filename}: ${e.message}`);
      }
    }
    await context.close();
  }

  await browser.close();
  return screenshots;
}

async function getCritique(screenshots) {
  const client = new Anthropic();

  // Build content array with all screenshots
  const content = [
    {
      type: 'text',
      text: `You are a demanding design critic evaluating a personal website for Arkadi Avanesyan, a world-class quantitative finance expert.

CONTEXT: This site should feel like "leather and oak, almost with a whiff of tobacco" — prestigious, warm, with mystique. Think partner's office at a top-tier finance firm. The aesthetic references old-money prestige, editorial design, and hand-crafted excellence. It uses concept art textures as backgrounds, Playfair Display serif for headings, Plus Jakarta Sans for body, gold accents (#B8963E), and a dark/green/warm parchment color scheme.

TARGET AUDIENCE: Finance professionals, corporate training clients, students interested in quant finance courses.

I'm showing you screenshots of ALL pages in both desktop (1440px) and mobile (390px) views.

Evaluate from the perspective of someone who might hire Arkadi for corporate training or take his courses. Be specific and actionable.

Focus on:
1. VISUAL HIERARCHY - Is the most important content prominent? Does the eye flow naturally?
2. TYPOGRAPHY - Are sizes, weights, spacing working? Any text too small or too large?
3. SPACING & LAYOUT - Generous whitespace? Cramped areas? Alignment issues?
4. MOBILE EXPERIENCE - Does mobile feel intentional or just squeezed desktop?
5. COLOR & CONTRAST - Readable text? Backgrounds working with text?
6. CREDIBILITY & PRESTIGE - Does this feel like a world-class expert's site?
7. SPECIFIC ISSUES - Anything broken, misaligned, or awkward?

For each issue, specify:
- Which page and viewport (desktop/mobile)
- Exactly what's wrong
- How to fix it (be specific: CSS properties, pixel values, etc.)

Rate the overall design 1-10 and list issues from most critical to least.
End with a VERDICT: PASS (8+/10) or NEEDS_WORK (below 8).`
    }
  ];

  for (const ss of screenshots) {
    const imageData = readFileSync(ss.filepath);
    const base64 = imageData.toString('base64');

    content.push({
      type: 'text',
      text: `\n--- ${ss.page.toUpperCase()} (${ss.viewport}) ---`
    });
    content.push({
      type: 'image',
      source: {
        type: 'base64',
        media_type: 'image/png',
        data: base64,
      }
    });
  }

  console.log('\n📤 Sending screenshots to Claude for critique...\n');

  const response = await client.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 4096,
    messages: [{ role: 'user', content }],
  });

  return response.content[0].text;
}

async function main() {
  console.log('📸 Taking screenshots...\n');
  const screenshots = await takeScreenshots();

  if (screenshots.length === 0) {
    console.error('No screenshots taken. Is the dev server running on port 4321?');
    process.exit(1);
  }

  const critique = await getCritique(screenshots);

  // Save critique to file
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const critiqueFile = join(SCREENSHOTS_DIR, `critique-${timestamp}.md`);
  writeFileSync(critiqueFile, critique);

  console.log('\n' + '='.repeat(80));
  console.log('DESIGN CRITIQUE');
  console.log('='.repeat(80) + '\n');
  console.log(critique);
  console.log('\n' + '='.repeat(80));
  console.log(`\nCritique saved to: ${critiqueFile}`);

  return critique;
}

main().catch(console.error);
