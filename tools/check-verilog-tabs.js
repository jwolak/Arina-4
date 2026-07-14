#!/usr/bin/env node

const { execSync } = require("child_process");
const path = require("path");

const VERILOG_EXTS = new Set([".v", ".sv", ".vh", ".svh"]);

function getStagedFiles() {
    const output = execSync("git diff --cached --name-only --diff-filter=ACMR", {
        encoding: "utf8",
    });

    return output
        .split(/\r?\n/)
        .map((line) => line.trim())
        .filter(Boolean)
        .filter((file) => VERILOG_EXTS.has(path.extname(file).toLowerCase()));
}

function readStagedFile(filePath) {
    // Read content from the index to validate exactly what is being committed.
    return execSync(`git show :${filePath}`, { encoding: "utf8" });
}

function findTabLines(content) {
    const lines = content.split(/\r?\n/);
    const hits = [];

    for (let i = 0; i < lines.length; i += 1) {
        if (lines[i].includes("\t")) {
            hits.push(i + 1);
        }
    }

    return hits;
}

function main() {
    let stagedFiles = [];

    try {
        stagedFiles = getStagedFiles();
    } catch (error) {
        console.error("[tabs-check] Unable to read staged files.");
        console.error(error.message);
        process.exit(1);
    }

    if (stagedFiles.length === 0) {
        process.exit(0);
    }

    const offenders = [];

    for (const file of stagedFiles) {
        let content;

        try {
            content = readStagedFile(file);
        } catch (error) {
            console.error(`[tabs-check] Unable to read staged content for ${file}.`);
            console.error(error.message);
            process.exit(1);
        }

        const hitLines = findTabLines(content);
        if (hitLines.length > 0) {
            offenders.push({ file, hitLines });
        }
    }

    if (offenders.length === 0) {
        process.exit(0);
    }

    console.error("\nCommit blocked: tab characters found in staged Verilog files.\n");
    for (const offender of offenders) {
        const lines = offender.hitLines.join(", ");
        console.error(`- ${offender.file} (lines: ${lines})`);
    }

    console.error("\nUse spaces (4) instead of tabs and re-stage files.\n");
    process.exit(1);
}

main();
