#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const packageJsonPath = path.resolve(__dirname, "..", "package.json");

function fail(message) {
    console.error(`[version-bump] ${message}`);
    process.exit(1);
}

if (!fs.existsSync(packageJsonPath)) {
    fail("package.json not found.");
}

let pkg;
try {
    pkg = JSON.parse(fs.readFileSync(packageJsonPath, "utf8"));
} catch (error) {
    fail(`Cannot parse package.json: ${error.message}`);
}

if (typeof pkg.version !== "string") {
    fail("package.json version is missing or invalid.");
}

const match = pkg.version.match(/^(\d+)\.(\d+)\.(\d+)$/);
if (!match) {
    fail(`Version '${pkg.version}' is not in x.y.z format.`);
}

const major = Number(match[1]);
const minor = Number(match[2]);
const patch = Number(match[3]) + 1;

pkg.version = `${major}.${minor}.${patch}`;

fs.writeFileSync(packageJsonPath, `${JSON.stringify(pkg, null, 2)}\n`, "utf8");
console.log(`[version-bump] package.json version -> ${pkg.version}`);
