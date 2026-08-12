/*
 * Renders the default Open Graph card (1200x630) from the ManaOps brand marks.
 * Run with: npm run og
 */
import sharp from 'sharp';

const comet = (tx, ty, scale) => `
<g transform="translate(${tx}, ${ty}) scale(${scale})">
  <path d="M41.5,96.5 C69,85.5 102,58 110.8,25 L106.4,16.2 C91,41.5 63.5,69 44.8,80 Z" fill="#5C1512" opacity="0.6"/>
  <path d="M38.2,91 C60.2,82.2 85.5,60.2 96.5,33.8 L93.2,27.2 C80,47 58,69 42.6,76.7 Z" fill="#A5301F" opacity="0.75"/>
  <path d="M33.8,88.8 C49.2,82.2 66.8,66.8 77.8,49.2 L73.4,44.8 C62.4,60.2 47,74.5 36,82.2 Z" fill="#E2722E" opacity="0.85"/>
  <circle cx="102" cy="12" r="2.5" fill="#C24A22" opacity="0.4"/>
  <circle cx="108" cy="20" r="2" fill="#A5301F" opacity="0.3"/>
  <circle cx="34" cy="89" r="24" fill="#F5C542" opacity="0.35"/>
  <circle cx="34" cy="89" r="16" fill="#F7DDA0" opacity="0.7"/>
  <circle cx="34" cy="89" r="10" fill="#FFF4D6" opacity="0.95"/>
  <circle cx="34" cy="89" r="5" fill="#FFFDF5"/>
</g>`;

const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="630" viewBox="0 0 1200 630">
  <defs>
    <radialGradient id="warm" cx="0.5" cy="0.5" r="0.5">
      <stop offset="0%" stop-color="#E2722E" stop-opacity="0.20"/>
      <stop offset="100%" stop-color="#E2722E" stop-opacity="0"/>
    </radialGradient>
    <radialGradient id="cool" cx="0.5" cy="0.5" r="0.5">
      <stop offset="0%" stop-color="#123B4F" stop-opacity="0.55"/>
      <stop offset="100%" stop-color="#123B4F" stop-opacity="0"/>
    </radialGradient>
  </defs>

  <rect width="1200" height="630" fill="#0A1710"/>
  <ellipse cx="1020" cy="60" rx="620" ry="440" fill="url(#warm)"/>
  <ellipse cx="120" cy="220" rx="560" ry="420" fill="url(#cool)"/>

  <!-- Mark, right side -->
  <g transform="translate(700, 120) scale(1.25)">
    <g transform="translate(80, 216)">
      <polygon points="38,6 122,6 144,38 104,64 56,64 16,38" fill="#142E24"/>
      <ellipse cx="56" cy="32" rx="6" ry="9" fill="#3FA08F"/>
      <ellipse cx="80" cy="44" rx="6" ry="9" fill="#3FA08F"/>
      <ellipse cx="104" cy="32" rx="6" ry="9" fill="#3FA08F"/>
    </g>
    <g transform="translate(90, 20)">
      <polygon points="70,22 112,78 112,206 28,206 28,78" fill="none" stroke="#123B4F" stroke-width="18" opacity="0.35"/>
      <polygon points="70,30 106,80 106,200 34,200 34,80" fill="none" stroke="#2E8B9E" stroke-width="3" opacity="0.8" stroke-dasharray="55 12 28 10 16 8" stroke-linejoin="round"/>
      <polygon points="70,38 100,84 100,192 40,192 40,84" fill="#0A1710" stroke="#F0EAD8" stroke-width="3" stroke-linejoin="round"/>
    </g>
    ${comet(132.4, 130.4, 0.46)}
  </g>

  <!-- Wordmark, left side -->
  <text x="90" y="345" font-family="Georgia, 'Times New Roman', serif" font-weight="700"
        font-size="96" letter-spacing="2" fill="#F0EAD8">ManaOps</text>
</svg>`;

const out = process.argv[2] ?? 'src/assets/og-default.png';
await sharp(Buffer.from(svg)).png().toFile(out);
console.log('wrote', out);
