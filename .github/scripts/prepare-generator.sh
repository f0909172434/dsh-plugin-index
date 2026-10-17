#!/usr/bin/env bash
# Make the official plugin-market-generator runnable outside the deepseek-harness pnpm workspace.
# Usage: prepare-generator.sh <deepseek-harness sparse checkout>
# The two workspace utilities are not built here, so their exports point at src/index.ts (run through tsx),
# and the workspace: dependencies become file: links.
set -euo pipefail
root=$(cd "$1" && pwd)
gen=$root/apps/plugin-market-generator

# Without this, npm finds the root workspaces manifest and tries to install the whole monorepo.
rm -f "$root/package.json"

rewrite() { jq "$2" "$1" > "$1.tmp" && mv "$1.tmp" "$1"; }

for util in plugin-market-index package-manifest; do
  rewrite "$root/packages/util/$util/package.json" '
    .exports["."] = "./src/index.ts"
    | del(.peerDependencies, .devDependencies)
    | if .dependencies["@deepseek-ai/dsh-package-manifest"]
      then .dependencies["@deepseek-ai/dsh-package-manifest"] = "file:../package-manifest" else . end'
done
rewrite "$gen/package.json" '
  .dependencies["@deepseek-ai/dsh-plugin-market-index"] = "file:../../packages/util/plugin-market-index"
  | .devDependencies["@deepseek-ai/dsh-package-manifest"] = "file:../../packages/util/package-manifest"'

# npm links file: directories without installing their own dependencies (semver), so install those in place.
(cd "$root/packages/util/plugin-market-index" && npm install --no-audit --no-fund --loglevel=error)
(cd "$gen" && npm install --no-audit --no-fund --loglevel=error)
cp "$(dirname "$0")/validate-index.ts" "$gen/validate-index.ts"
