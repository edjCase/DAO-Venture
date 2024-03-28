const fs = require('fs');
const path = require('path');

const srcDir = 'src/backend';
const outputFile = 'combined-mo-files.txt';
const moFiles = [];

function traverseDir(dir) {
  fs.readdirSync(dir).forEach(file => {
    const filePath = path.join(dir, file);
    if (fs.statSync(filePath).isDirectory()) {
      traverseDir(filePath);
    } else if (path.extname(filePath) === '.mo') {
      moFiles.push(filePath);
    }
  });
}

try {
  traverseDir(srcDir);

  const combinedContent = moFiles
    .map(file => `File: ${file}\n${fs.readFileSync(file, 'utf-8')}\n\n`)
    .join('');

  fs.writeFileSync(outputFile, combinedContent);

  console.log(`Successfully combined ${moFiles.length} .mo files into ${outputFile}.`);
} catch (error) {
  console.error('An error occurred while combining the .mo files:', error);
}