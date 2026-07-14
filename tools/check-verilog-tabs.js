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

function findTrailingWhitespaceLines(content) {
    const lines = content.split(/\r?\n/);
    const hits = [];

    for (let i = 0; i < lines.length; i += 1) {
        if (/[ \t]+$/.test(lines[i])) {
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

    const tabOffenders = [];
    const trailingWhitespaceOffenders = [];

    for (const file of stagedFiles) {
        let content;

        try {
            content = readStagedFile(file);
        } catch (error) {
            console.error(`[tabs-check] Unable to read staged content for ${file}.`);
            console.error(error.message);
            process.exit(1);
        }

        const tabLines = findTabLines(content);
        if (tabLines.length > 0) {
            tabOffenders.push({ file, hitLines: tabLines });
        }

        const trailingWhitespaceLines = findTrailingWhitespaceLines(content);
        if (trailingWhitespaceLines.length > 0) {
            trailingWhitespaceOffenders.push({ file, hitLines: trailingWhitespaceLines });
        }
    }

    if (tabOffenders.length === 0 && trailingWhitespaceOffenders.length === 0) {
        process.exit(0);
    }

    console.error("\nCommit blocked: style violations found in staged Verilog files.\n");

    if (tabOffenders.length > 0) {
        console.error("Tab characters found:");
        for (const offender of tabOffenders) {
            const lines = offender.hitLines.join(", ");
            console.error(`- ${offender.file} (lines: ${lines})`);
        }
        console.error("");
    }

    if (trailingWhitespaceOffenders.length > 0) {
        console.error("Trailing whitespace found:");
        for (const offender of trailingWhitespaceOffenders) {
            const lines = offender.hitLines.join(", ");
            console.error(`- ${offender.file} (lines: ${lines})`);
        }
        console.error("");
    }

    console.error("Use spaces (4), remove trailing whitespace, and re-stage files.\n");
    process.exit(1);
}

main();
