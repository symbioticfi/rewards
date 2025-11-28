import { defineConfig } from "@wagmi/cli";
import { readFileSync, readdirSync } from "node:fs";
import { basename, dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, "..", "..");
const ABIS_DIR = join(ROOT, "abis");
const OUTPUT_FILE = join(ROOT, "bindings/ts-viem/generated.ts");

const collectContracts = () => {
  const contracts = [];
  const stack = [ABIS_DIR];
  const seen = new Set<string>();

  while (stack.length) {
    const current = stack.pop()!;
    for (const dirent of readdirSync(current, { withFileTypes: true })) {
      const fullPath = join(current, dirent.name);
      if (dirent.isDirectory()) {
        stack.push(fullPath);
        continue;
      }

      if (!dirent.isFile()) continue;
      if (!dirent.name.endsWith(".abi.json")) continue;

      let abi;
      try {
        abi = JSON.parse(readFileSync(fullPath, "utf8"));
      } catch {
        continue;
      }

      const name = basename(dirent.name, ".abi.json");
      if (seen.has(name)) {
        throw new Error(`Duplicate ABI contract name detected: ${name}`);
      }
      seen.add(name);
      contracts.push({ name, abi });
    }
  }

  contracts.sort((a, b) => a.name.localeCompare(b.name));
  return contracts;
};

export default defineConfig({
  out: OUTPUT_FILE,
  contracts: collectContracts(),
});
