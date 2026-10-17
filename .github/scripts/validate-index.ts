/**
 * Validate a market index with the official parser.
 * Usage: tsx validate-index.ts <index.json> <index URL>
 * Prints the plugin count; throws (non-zero exit) when the index does not parse.
 */
import { readFileSync } from 'node:fs'
import { parseMarketIndex } from '@deepseek-ai/dsh-plugin-market-index'

const [file, url] = process.argv.slice(2)
if (!file || !url) throw new Error('usage: validate-index.ts <index.json> <index URL>')
const index = parseMarketIndex(JSON.parse(readFileSync(file, 'utf8')), url)
console.log(index.plugins.length)
