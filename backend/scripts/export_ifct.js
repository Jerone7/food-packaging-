const fs = require('fs');
const path = require('path');
const ifct2017 = require('@nodef/ifct2017');

async function exportIfct() {
  console.log("Loading IFCT 2017 compositions and descriptions...");
  await ifct2017.loadDescriptions();
  await ifct2017.loadCompositions();
  await ifct2017.loadGroups();

  const compositions = ifct2017.compositions();
  const descriptions = ifct2017.descriptions();
  const groups = ifct2017.groups();

  const records = [];

  for (const [code, desc] of Object.entries(descriptions)) {
    const comp = compositions[code] || {};
    const grp = groups[desc.group] || {};

    records.push({
      code: code,
      name: desc.name || '',
      sc_name: desc.scName || '',
      group_name: grp.name || desc.group || '',
      energy_kcal: comp.enerc || null,
      protein_g: comp.protcnt || null,
      fat_g: comp.fatce || null,
      carbohydrate_g: comp.choavldf || comp.chocdf || null,
      fiber_g: comp.fibtg || null,
      water_g: comp.water || null,
      ash_g: comp.ash || null,
    });
  }

  const outDir = path.join(__dirname, '..', 'data');
  if (!fs.existsSync(outDir)) {
    fs.mkdirSync(outDir, { recursive: true });
  }

  const outPath = path.join(outDir, 'ifct2017_compositions.json');
  fs.writeFileSync(outPath, JSON.stringify(records, null, 2));
  console.log(`Successfully exported ${records.length} IFCT 2017 records to ${outPath}`);
}

exportIfct().catch(err => {
  console.error("Error exporting IFCT data:", err);
  process.exit(1);
});
