const fs = require("fs");
const eta = require("eta");
const pg = require("pg");
const { execFileSync: sh } = require("child_process");

const query = fs.readFileSync("./query.sql").toString();
const template = fs.readFileSync("./template.eta").toString();

const args = process.argv.slice(2);

async function getSchema() {
  const { Client } = pg;
  const client = new Client(args[0]);
  await client.connect();

  const res = await client.query(query);
  await client.end();

  return res.rows.map((result) => ({
    ...result,
    // postgres sometimes returns [null] for some reason
    foreign_relations: result.foreign_relations.filter(
      (relation) => !!relation
    ),
  }));
}

async function main() {
  const schema = await getSchema();
  const output = eta.render(template, { schema });
  fs.writeFileSync("output.d2", output);
  sh("d2", ["output.d2", "out.svg"]);
}

main();
