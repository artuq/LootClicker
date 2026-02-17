const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const imagePath = process.argv[2] || './icons_grid.png';
const outputDir = './assets/icons';

// Ensure output directory exists
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

// Icon definitions: [name, x, y, width, height]
const icons = [
  ['bandages_ai.png', 0, 0, 512, 512],
  ['venom_ai.png', 512, 0, 512, 512],
  ['gold_coin_ai.png', 0, 512, 512, 512],
  ['relic_shards_ai.png', 512, 512, 512, 512]
];

async function extractIcons() {
  try {
    console.log(`Reading image from: ${imagePath}`);
    
    if (!fs.existsSync(imagePath)) {
      console.error(`Error: Image file not found at ${imagePath}`);
      console.log('Usage: node extract_icons.js <path-to-image>');
      process.exit(1);
    }

    console.log('Extracting icons...');
    
    // Extract each icon
    for (const [name, x, y, width, height] of icons) {
      const outputPath = path.join(outputDir, name);
      await sharp(imagePath)
        .extract({ left: x, top: y, width, height })
        .png()
        .toFile(outputPath);
      console.log(`✓ Created: ${outputPath}`);
    }

    console.log('\n✓ All icons extracted successfully!');
    console.log('Next step: Update GameBattleManager.gd to use the new PNG files');
  } catch (error) {
    console.error('Error extracting icons:', error);
    process.exit(1);
  }
}

extractIcons();
