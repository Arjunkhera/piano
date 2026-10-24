#!/usr/bin/env node
// The Atlas repo-shape check. Milestone M2, slice L1, design pages D1 and D4.
//
// This is the whole check, in one file. The package writes this file into a
// repo at .github/atlas/check.mjs, and a workflow there runs it on every pull
// request. Nothing else is needed. It holds the spec, the scanners, the YAML
// reader, the secret patterns and the report. It imports Node builtins only.
//
// What it reads: the checkout it is pointed at, and nothing else. It opens no
// network. It holds no token. It writes nothing back into the repo.
//
// What it reports: one state per part of the seven files. Five states: filled,
// empty, stale, not applicable, no extractor. It leads with the count of
// required parts that are not filled.
//
// It carries the version of the Atlas package it came from, so a copy in a
// repo says where it came from. It refuses a spec version it cannot read.
//
// Authority: the Atlas M2 study, design page D1 with its
// D7 amendment; the Atlas architecture review, build order B1.
import { readFileSync, readdirSync, statSync, existsSync, writeFileSync, appendFileSync } from 'node:fs';
import { join, resolve, relative, posix } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createHash } from 'node:crypto';

// node:crypto is a builtin, so the check still imports nothing but builtins.
export const sha256 = (text) => createHash('sha256').update(String(text ?? ''), 'utf8').digest('hex');

// The version of this check, as a whole number. It moves only when this file's
// own code changes, never with the Atlas package version (row F11, amendment
// A1.9). A release of Atlas that leaves the check alone leaves every repo's copy
// current, so the no-loss rule's check-file case does not fire on every release.
//
// Whether a copy is current or behind is not decided here. CI has no package
// and no network. The session verb decides it, from the release list that
// ships beside this file in the package, shape/releases.json.
export const CHECK_VERSION = 4;

// ---------------------------------------------------------------------------
// The spec. One object per version. The check reads a version it has here and
// refuses any other.
// ---------------------------------------------------------------------------

export const SPEC_1 = {
  "spec": 1,
  "title": "The files every repo carries",
  "authority": "the Atlas M2 study, design page D1 with its D7 amendment, and the lock block, slice L1.",
  "states": {
    "filled": "The part exists and matches the repo.",
    "empty": "The part is missing, or it holds nothing.",
    "stale": "The part exists but disagrees with the repo.",
    "not applicable": "This repo kind does not need the part.",
    "no extractor": "The part is generated, and no extractor exists for it yet."
  },
  "kinds": {
    "service": "A running product with a deploy target, logs and metrics.",
    "library": "Code another repo takes as a dependency. It is not deployed.",
    "schema": "Migrations and their release. It has no service and no library build.",
    "plugin": "A Claude Code plugin. It is installed, not deployed, and the merge proves it.",
    "cli": "A command-line tool people install. It is not deployed."
  },
  "files": [
    {
      "id": "entry-map",
      "number": 1,
      "title": "Entry map",
      "class": "instruction",
      "written_by": "the helper drafts; a person merges",
      "parts": [
        {
          "id": "claude-md",
          "path": "CLAUDE.md",
          "holds": "What the repo is, how to build it, the layout, the modules, and one pointer to each file below. Facts only.",
          "kind": {
            "service": "required",
            "library": "required",
            "schema": "required",
            "plugin": "required",
            "cli": "required"
          },
          "check": "markdown",
          "max_lines": 200
        },
        {
          "id": "agents-md",
          "path": "AGENTS.md",
          "holds": "Two lines that point at CLAUDE.md.",
          "kind": {
            "service": "required",
            "library": "required",
            "schema": "required",
            "plugin": "required",
            "cli": "required"
          },
          "check": "markdown",
          "max_lines": 200
        }
      ]
    },
    {
      "id": "path-rules",
      "number": 2,
      "title": "Path rules",
      "class": "instruction",
      "written_by": "the helper; a person merges",
      "parts": [
        {
          "id": "rules",
          "path": ".claude/rules",
          "glob": "*.md",
          "holds": "One constraint that holds under one path only, such as \"migrations are append-only\".",
          "kind": {
            "service": "optional",
            "library": "optional",
            "schema": "optional",
            "plugin": "optional",
            "cli": "optional"
          },
          "check": "path-rules"
        }
      ]
    },
    {
      "id": "procedures",
      "number": 3,
      "title": "Procedures",
      "class": "instruction",
      "written_by": "the helper; a person merges",
      "parts": [
        {
          "id": "run-locally",
          "procedure": "run-locally",
          "holds": "One skill that brings the stack up on the owner's machine.",
          "kind": {
            "service": "required",
            "library": "not applicable",
            "schema": "not applicable",
            "plugin": "not applicable",
            "cli": "not applicable"
          },
          "check": "procedure"
        },
        {
          "id": "test",
          "procedure": "test",
          "holds": "One skill that names the suites and runs them.",
          "kind": {
            "service": "required",
            "library": "required",
            "schema": "not applicable",
            "plugin": "required",
            "cli": "required"
          },
          "check": "procedure"
        },
        {
          "id": "deploy",
          "procedure": "deploy",
          "holds": "One skill that deploys the service.",
          "kind": {
            "service": "required",
            "library": "not applicable",
            "schema": "not applicable",
            "plugin": "not applicable",
            "cli": "not applicable"
          },
          "check": "procedure"
        },
        {
          "id": "release",
          "procedure": "release",
          "holds": "One skill that cuts a release.",
          "kind": {
            "service": "required",
            "library": "required",
            "schema": "required",
            "plugin": "required",
            "cli": "required"
          },
          "check": "procedure"
        }
      ]
    },
    {
      "id": "repo-facts",
      "number": 4,
      "title": "Repo facts",
      "class": "instruction",
      "written_by": "an agent proposes; the owner merges",
      "parts": [
        {
          "id": "root",
          "path": "atlas.yaml",
          "holds": "The spec version, the kind, the product id, the repo id, the procedure map, and one pointer per section.",
          "kind": {
            "service": "required",
            "library": "required",
            "schema": "required",
            "plugin": "required",
            "cli": "required"
          },
          "check": "facts-root",
          "keys": [
            "spec",
            "kind",
            "product",
            "repo"
          ]
        },
        {
          "id": "deploy",
          "section": "deploy",
          "default_path": "atlas/deploy.yaml",
          "holds": "One entry per environment: the platform, the target and the health endpoint.",
          "kind": {
            "service": "required",
            "library": "not applicable",
            "schema": "not applicable",
            "plugin": "not applicable",
            "cli": "not applicable"
          },
          "check": "facts-section",
          "keys": [
            "environments"
          ]
        },
        {
          "id": "observability",
          "section": "observability",
          "default_path": "atlas/observability.yaml",
          "holds": "Where the logs, the metrics, the traces and the dashboards are, per environment.",
          "kind": {
            "service": "required",
            "library": "not applicable",
            "schema": "not applicable",
            "plugin": "not applicable",
            "cli": "not applicable"
          },
          "check": "facts-section",
          "keys": [
            "environments"
          ]
        },
        {
          "id": "credentials",
          "section": "credentials",
          "default_path": "atlas/credentials.yaml",
          "holds": "Each credential by name, with the environment it belongs to. Names only, never a value.",
          "kind": {
            "service": "required",
            "library": "not applicable",
            "schema": "required",
            "plugin": "optional",
            "cli": "optional"
          },
          "check": "facts-credentials",
          "keys": [
            "credentials"
          ]
        },
        {
          "id": "dependencies",
          "section": "dependencies",
          "default_path": "atlas/dependencies.yaml",
          "holds": "The other repos this one needs, by repo id, and what it takes from each.",
          "kind": {
            "service": "required",
            "library": "optional",
            "schema": "optional",
            "plugin": "optional",
            "cli": "optional"
          },
          "check": "facts-section",
          "keys_present": [
            "repos"
          ]
        },
        {
          "id": "upkeep",
          "section": "upkeep",
          "default_path": "atlas/upkeep.yaml",
          "holds": "The budget and the kill switch for the upkeep task. Slice L4 fills it.",
          "kind": {
            "service": "optional",
            "library": "optional",
            "schema": "optional",
            "plugin": "optional",
            "cli": "optional"
          },
          "check": "facts-section",
          "keys": [
            "budget"
          ]
        }
      ]
    },
    {
      "id": "docs-index",
      "number": 5,
      "title": "Docs index",
      "class": "docs",
      "written_by": "the upkeep task; merges on its own",
      "parts": [
        {
          "id": "index",
          "path": "docs/index.md",
          "holds": "One line per file under docs/, with a status.",
          "kind": {
            "service": "required",
            "library": "required",
            "schema": "required",
            "plugin": "required",
            "cli": "required"
          },
          "check": "docs-index"
        }
      ]
    },
    {
      "id": "docs-content",
      "number": 6,
      "title": "Docs content",
      "class": "docs",
      "written_by": "the upkeep task and the talk-through; merges on its own",
      "parts": [
        {
          "id": "pages",
          "path": "docs/site",
          "glob": "*.md",
          "holds": "The pages: home, features, flows with their step lists, concepts. Each page carries the commit it was built from.",
          "kind": {
            "service": "required",
            "library": "optional",
            "schema": "optional",
            "plugin": "optional",
            "cli": "optional"
          },
          "check": "docs-pages"
        },
        {
          "id": "features",
          "path": "docs/site/features.yaml",
          "holds": "The feature list the renderer reads.",
          "kind": {
            "service": "required",
            "library": "optional",
            "schema": "optional",
            "plugin": "optional",
            "cli": "optional"
          },
          "check": "features"
        },
        {
          "id": "notes",
          "path": "docs/site/notes.md",
          "class": "instruction",
          "holds": "The standing corrections. Each note names who said it and the session. A person merges it.",
          "kind": {
            "service": "optional",
            "library": "optional",
            "schema": "optional",
            "plugin": "optional",
            "cli": "optional"
          },
          "check": "notes"
        },
        {
          "id": "api",
          "path": "docs/site/reference/api.md",
          "holds": "Every route with its method, path, principal, handler file and line.",
          "kind": {
            "service": "required",
            "library": "not applicable",
            "schema": "not applicable",
            "plugin": "not applicable",
            "cli": "not applicable"
          },
          "check": "generated",
          "extractor": "routes"
        },
        {
          "id": "database",
          "path": "docs/site/reference/database.md",
          "holds": "The tables, their fields, their types and the purpose of each field.",
          "kind": {
            "service": "required",
            "library": "not applicable",
            "schema": "required",
            "plugin": "not applicable",
            "cli": "not applicable"
          },
          "check": "generated",
          "extractor": "migrations"
        },
        {
          "id": "mcp-tools",
          "path": "docs/site/reference/mcp-tools.md",
          "holds": "Every MCP tool, its inputs, and when to use it.",
          "kind": {
            "service": "optional",
            "library": "optional",
            "schema": "optional",
            "plugin": "optional",
            "cli": "optional"
          },
          "check": "generated",
          "extractor": "mcp"
        }
      ]
    },
    {
      "id": "tooling",
      "number": 7,
      "title": "Tooling",
      "class": "instruction",
      "written_by": "the helper; a person merges",
      "parts": [
        {
          "id": "atlas-check",
          "path": ".github/workflows/atlas-check.yml",
          "holds": "The one workflow that runs .github/atlas/check.mjs, the check file in this repo.",
          "kind": {
            "service": "required",
            "library": "required",
            "schema": "required",
            "plugin": "required",
            "cli": "required"
          },
          "check": "workflow"
        },
        {
          "id": "linters",
          "holds": "The repo's own linters and formatters.",
          "kind": {
            "service": "optional",
            "library": "optional",
            "schema": "optional",
            "plugin": "optional",
            "cli": "optional"
          },
          "check": "linters",
          "candidates": [
            "eslint.config.js",
            "eslint.config.mjs",
            ".eslintrc",
            ".eslintrc.json",
            ".eslintrc.cjs",
            ".prettierrc",
            ".prettierrc.json",
            "prettier.config.js",
            "biome.json",
            "ruff.toml",
            ".ruff.toml",
            "setup.cfg",
            "tox.ini",
            ".flake8",
            "rustfmt.toml",
            ".golangci.yml",
            ".golangci.yaml",
            ".editorconfig"
          ]
        }
      ]
    }
  ],
  "extractors": {
    "routes": "Slice L3 builds it.",
    "migrations": "Slice L3 builds it.",
    "mcp": "Slice L3 builds it."
  },
  "by_reference": {
    "rule": "A file under docs/ that an instruction file points at is instruction class by reference (D7 finding R1). The check computes that set and reports each member.",
    "scanned": [
      "CLAUDE.md",
      "AGENTS.md",
      ".claude/rules/*.md",
      ".claude/skills/*/SKILL.md",
      "atlas.yaml",
      "atlas/*.yaml",
      "docs/site/notes.md"
    ]
  }
};

// Deep frozen. `loadSpec` hands every caller the same object, so one caller
// must not be able to change what the next one reads (acceptance review of
// batch 14b, finding 9).
function deepFreeze(value) {
  if (value && typeof value === 'object' && !Object.isFrozen(value)) {
    Object.freeze(value);
    for (const child of Object.values(value)) deepFreeze(child);
  }
  return value;
}
deepFreeze(SPEC_1);

// Spec 2 adds one part: the check file itself, scored inside file 7.
//
// Why a new version and not a line in spec 1. Adding a scored part changes what
// `spec: 1` means, and the spec version is the whole coupling between a
// repository's facts and this file (architecture rule 6; architect finding
// P11). The check reads both versions, so a repository stays green while it is
// still on spec 1, and it opts in by moving `atlas.yaml` to `spec: 2`.
//
// Nothing else moves. Spec 1 keeps its twenty-two parts, and spec 2 has
// twenty-three.
//
// Check version 4 adds two kinds, plugin and cli, to both specs (issue #141).
// No cell of an older kind moves, so a repo that names service, library or
// schema reads the same table as before. The kind is now a second coupling
// beside the spec version: a repo that names plugin or cli needs check 4 or
// later. Stage 2 of the target design retires these fixed tables.
const clone = (value) => JSON.parse(JSON.stringify(value));

export const SPEC_2 = (() => {
  const spec = clone(SPEC_1);
  spec.spec = 2;
  spec.authority = 'Atlas amendment A1.6, section 5, slice L2 stage one, and section 4.6.';
  const tooling = spec.files.find((file) => file.id === 'tooling');
  tooling.parts.unshift({
    id: 'check-file',
    // The literal, not the constant: this object is data, and the constant is
    // declared below it. A test keeps the two equal.
    path: '.github/atlas/check.mjs',
    holds: 'The check itself, the copy this repo runs. One file, no dependency, carrying the Atlas version and the package commit it came from.',
    kind: { service: 'required', library: 'required', schema: 'required', plugin: 'required', cli: 'required' },
    check: 'check-file',
  });
  return deepFreeze(spec);
})();

export const SPECS = Object.freeze({ 1: SPEC_1, 2: SPEC_2 });

export class SpecError extends Error {}

export function loadSpec(version) {
  // Number() turns true into 1 and "0x1" into 1, so a boolean or a hex string
  // would silently read spec 1 (acceptance review of batch 14b, finding 8).
  // Take a whole number, or a string of decimal digits, and nothing else.
  const decimal = typeof version === 'number' || (typeof version === 'string' && /^\s*\d+\s*$/.test(version));
  const wanted = decimal ? Number(version) : NaN;
  if (!Number.isInteger(wanted) || wanted < 1) throw new SpecError(`atlas.yaml names spec "${version}"; the spec version must be a whole number`);
  const spec = SPECS[wanted];
  if (!spec) throw new SpecError(`spec ${wanted} is unknown to this copy of the check, check version ${CHECK_VERSION}; it reads spec ${Object.keys(SPECS).join(', ')}. Refresh .github/atlas/check.mjs, or set spec to a version this copy reads`);
  if (spec.spec !== wanted) throw new SpecError(`the spec object for version ${wanted} names version ${spec.spec}`);
  return spec;
}

// ---------------------------------------------------------------------------
// The secret patterns. A credentials file carries names only. A value in one is
// an error, not a finding. The list is here, in this file, so it can never go
// missing and disarm the only content check (review R-6). A test keeps it equal
// to work/protected-paths.json in the Atlas package, which is the authority for the same list in the
// M1 verbs.
// ---------------------------------------------------------------------------

// Each pattern carries a canary: a string that pattern must catch. The check
// tests every pattern against its own canary on every run, and raises an error
// when one misses.
//
// Why. The guard used to count the patterns, not test them. A pull request
// could replace all five with patterns that match nothing, and `scan` saw five
// usable regular expressions and stayed green. The only content check in the
// whole check was then silent for every later run, with no sign of it
// (security persona, finding S2-5).
//
// Every canary is joined from pieces at run time. Written whole, a canary
// would look like a credential to a secret scanner, and this file is committed
// and copied into other repositories. The same rule already governs the test
// fixtures (acceptance review of batch 14b, finding 1).
const canary = (...pieces) => pieces.join('');

export const SECRET_PATTERNS = Object.freeze([
  {
    id: 'named-value',
    holds: 'A named credential field with a value after it.',
    source: '(?i)(api[_-]?key|secret|token|password|passwd|authorization)\\s*[:=]\\s*\\S{8,}',
    canary: canary('api', '_key: ', 'N', '0'.repeat(11)),
  },
  {
    id: 'json-web-token',
    holds: 'A JSON web token, three base64url parts.',
    source: '\\b(?:eyJ[A-Za-z0-9_-]{10,}\\.[A-Za-z0-9_-]{10,}\\.[A-Za-z0-9_-]{10,})\\b',
    canary: canary('ey', 'J', 'A'.repeat(12), '.', 'B'.repeat(12), '.', 'C'.repeat(12)),
  },
  {
    id: 'github-token',
    holds: 'A GitHub personal access token.',
    source: '\\b(?:gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,})\\b',
    canary: canary('gh', 'p', '_', 'A'.repeat(24)),
  },
  {
    id: 'vendor-key',
    holds: 'A model-vendor key or an AWS access key id.',
    source: '\\b(?:sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16})\\b',
    canary: canary('sk', '-', 'A'.repeat(24)),
  },
  {
    id: 'private-key',
    holds: 'The header line of a private key block.',
    source: '-----BEGIN [A-Z ]*PRIVATE KEY-----',
    canary: canary('-----', 'BEGIN ', 'RSA ', 'PRIVATE KEY', '-----'),
  },
  // The sixth. A connection string is the likely shape of a leaked credential
  // here, and none of the five above matches one (security persona, finding
  // S3-11). It needs a user and a password before the host, so an ordinary URL
  // never matches.
  {
    id: 'url-credential',
    holds: 'A credential in URL form: a scheme, then a user name and a password, then the host.',
    source: '\\b[a-z][a-z0-9+.-]*:\\/\\/[^\\s:@/]+:[^\\s:@/]+@[^\\s/]+',
    canary: canary('postgres', '://', 'demo', ':', 'pa55', 'word', '@', 'db.example/atlas'),
  },
]);

// The authority for this same list in the M1 verbs is the package's work/protected-paths.json,
// and a test keeps the two equal.
export const SECRET_PATTERN_SOURCES = Object.freeze(SECRET_PATTERNS.map((pattern) => pattern.source));

// The sources are written with a leading (?i), which JavaScript spells as a flag.
const compile = (source) => {
  const insensitive = source.startsWith('(?i)');
  return new RegExp(insensitive ? source.slice(4) : source, insensitive ? 'i' : '');
};

export function secretPatterns() {
  return SECRET_PATTERN_SOURCES.map(compile);
}

// Every pattern this file declares, tested against its own canary. Returns the
// ids that missed. An empty list means the patterns still bite.
export function canaryMisses() {
  const missed = [];
  for (const pattern of SECRET_PATTERNS) {
    let caught = false;
    try { caught = compile(pattern.source).test(pattern.canary); } catch { caught = false; }
    if (!caught) missed.push(pattern.id);
  }
  return missed;
}

// ---------------------------------------------------------------------------
// The workflow that runs this file. A person copies it into a repo today. The
// tooling helper of slice L2 writes it from here. It runs on pull_request, it
// reads the contents, it takes no secret, and it pins its one action by commit
// SHA (design review finding R11).
// ---------------------------------------------------------------------------

export const WORKFLOW_PATH = '.github/workflows/atlas-check.yml';
export const CHECK_PATH = '.github/atlas/check.mjs';

// Where the workflow puts the base tree. `walk` and `symlinks` skip every entry
// whose name starts with a dot, and every other read names an exact path, so no
// scanner ever reaches into it.
export const BASE_DIR = '.atlas-base';

export const WORKFLOW_TEMPLATE = `# The Atlas repo shape check, in this repo's own CI.
#
# It reads the seven files this repo carries, named in atlas.yaml and under
# atlas/, and reports one state per part: filled, empty, stale, not applicable,
# or no extractor. It reads this repo only. It takes no secret and opens no
# network, so it runs on a pull request with read access to the contents.
#
# The check is ${CHECK_PATH} in this repo. It needs no package and no
# install. Atlas writes both files; do not edit them by hand.
#
# It reports in the docs lane. It never fails a code merge.
#
# The second checkout is the no-loss rule's base tree. The check scores the base
# commit and the head commit side by side, and it goes red when a part the base
# already had is taken away. The base tree lands in ${BASE_DIR}, whose name
# starts with a dot, so no scanner walks into it. If that checkout fails there
# is nothing to compare, so the step may fail and the check says so and does not
# gate.
#
# Design: the Atlas architecture record, sections 5.2, 6 and rule 7.
name: atlas-check
on:
  pull_request:
permissions:
  contents: read
jobs:
  repo-shape:
    name: docs · repo shape
    runs-on: ubuntu-latest
    # The check reads two directory trees and opens no network. It finishes in
    # seconds. The bound stops a runner being billed until someone kills it.
    timeout-minutes: 5
    steps:
      # actions/checkout v4.3.1
      - uses: actions/checkout@11d5960a326750d5838078e36cf38b85af677262
      - name: the base commit, for the no-loss rule
        uses: actions/checkout@11d5960a326750d5838078e36cf38b85af677262
        continue-on-error: true
        with:
          ref: \${{ github.event.pull_request.base.sha }}
          path: ${BASE_DIR}
      - run: node ${CHECK_PATH} --base ${BASE_DIR} --base-sha \${{ github.event.pull_request.base.sha }}
`;

// ---------------------------------------------------------------------------
// The YAML reader. Atlas ships no dependency, so the check reads the subset of
// YAML that atlas.yaml, the section files and a SKILL.md front matter block
// use: comments, nested maps by indentation, lists of scalars and of maps,
// quoted and plain scalars, null, booleans, numbers, and the block scalars
// | and >. Anything outside that subset raises, so a file is never half
// understood.
// ---------------------------------------------------------------------------

// A parse error names where it is. It never carries what is there.
//
// It used to put up to sixty characters of the offending line into the
// message, and `checkCredentials` returned that message before it ran the
// secret patterns. A credential written with bad indentation therefore reached
// the CI log and the job summary, and the scan that would have caught it never
// ran (security persona, finding S2-6; amendment A1.6 section 4.9). The line
// and the column say where to look. The reader opens the file.
export class YamlError extends Error {
  constructor(message, line, column) {
    const at = line === undefined ? '' : column === undefined
      ? ` (line ${line + 1})`
      : ` (line ${line + 1}, column ${column + 1})`;
    super(`${message}${at}`);
    this.name = 'YamlError';
    this.line = line;
    this.column = column;
  }
}

const KEY = /^(?:"((?:[^"\\]|\\.)*)"|'((?:[^']|'')*)'|([^:#]+?))\s*:(?:\s+(.*))?$/;

// One level of flow style, for scalars only: [a, b] and { a: 1, b: two }.
// A nested bracket raises, so a file is never half understood.
function flow(text, lineNumber) {
  const open = text[0], close = open === '[' ? ']' : '}';
  if (!text.endsWith(close)) throw new YamlError(`a flow ${open === '[' ? 'list' : 'map'} does not close`, lineNumber);
  const body = text.slice(1, -1);
  if (/[[\]{}]/.test(body)) throw new YamlError('a nested flow value is not read by this check; use a block list or map', lineNumber);
  const parts = body.split(',').map((part) => part.trim()).filter((part) => part !== '');
  if (open === '[') return parts.map((part) => scalar(part, lineNumber));
  const out = {};
  for (const part of parts) {
    const at = part.indexOf(':');
    if (at === -1) throw new YamlError('a flow map entry has no colon', lineNumber);
    out[part.slice(0, at).trim().replace(/^["']|["']$/g, '')] = scalar(part.slice(at + 1), lineNumber);
  }
  return out;
}

function scalar(raw, lineNumber) {
  const text = raw === undefined ? '' : raw.trim();
  if (!text || text === '~' || text === 'null' || text === 'Null' || text === 'NULL') return null;
  if (text === 'true' || text === 'True' || text === 'TRUE') return true;
  if (text === 'false' || text === 'False' || text === 'FALSE') return false;
  if (text === '[]') return [];
  if (text === '{}') return ({});
  if (text.startsWith('"')) {
    if (!text.endsWith('"') || text.length < 2) throw new YamlError('a double quoted value does not close', lineNumber);
    return text.slice(1, -1).replace(/\\(.)/g, (_, character) => ({ n: '\n', t: '\t', r: '\r' })[character] ?? character);
  }
  if (text.startsWith("'")) {
    if (!text.endsWith("'") || text.length < 2) throw new YamlError('a single quoted value does not close', lineNumber);
    return text.slice(1, -1).replaceAll("''", "'");
  }
  if (text.startsWith('[') || text.startsWith('{')) return flow(text, lineNumber);
  const plain = text.replace(/\s+#.*$/, '').trim();
  if (/^-?\d+$/.test(plain)) return Number(plain);
  if (/^-?\d+\.\d+$/.test(plain)) return Number(plain);
  return plain;
}

function indentOf(line) {
  if (/^\t/.test(line)) throw new YamlError('a tab starts a line; YAML indents with spaces');
  return line.length - line.trimStart().length;
}

export function parseYaml(source) {
  const raw = String(source ?? '').replace(/\r\n?/g, '\n').split('\n');
  const lines = [];
  for (let index = 0; index < raw.length; index += 1) {
    const line = raw[index];
    if (!line.trim() || /^\s*#/.test(line)) continue;
    // A document marker is allowed only before the first content line. After
    // that it starts a second document, and merging two documents into one map
    // lets a later key silently override an earlier one (review R-4). `kind`
    // and `spec` decide which files a repo needs, so a silent override there is
    // a silent wrong answer.
    if (/^(---|\.\.\.)\s*$/.test(line)) {
      if (lines.length) throw new YamlError('a second document starts here; this check reads one document per file', index, 0);
      continue;
    }
    if (/^\t/.test(line)) throw new YamlError('a tab starts a line; YAML indents with spaces', index, 0);
    lines.push({ text: line, number: index, indent: indentOf(line) });
  }
  if (!lines.length) return null;
  const state = { at: 0 };

  function blockScalar(header, indent) {
    const fold = header.startsWith('>');
    const chomp = header.includes('-') ? 'strip' : header.includes('+') ? 'keep' : 'clip';
    const parts = [];
    let inner = null;
    while (state.at < lines.length && lines[state.at].indent > indent) {
      const line = lines[state.at];
      if (inner === null) inner = line.indent;
      parts.push(line.text.slice(Math.min(inner, line.indent)));
      state.at += 1;
    }
    let text = fold ? parts.join(' ') : parts.join('\n');
    if (chomp !== 'strip') text += '\n';
    return text;
  }

  function value(indent) {
    if (state.at >= lines.length || lines[state.at].indent < indent) return null;
    return lines[state.at].text.trimStart().startsWith('- ') || lines[state.at].text.trim() === '-'
      ? list(lines[state.at].indent)
      : map(lines[state.at].indent);
  }

  function list(indent) {
    const out = [];
    while (state.at < lines.length && lines[state.at].indent === indent) {
      const line = lines[state.at];
      const body = line.text.trimStart();
      if (!body.startsWith('- ') && body !== '-') break;
      const rest = body === '-' ? '' : body.slice(2);
      state.at += 1;
      if (!rest.trim()) { out.push(value(indent + 1)); continue; }
      const match = KEY.exec(rest);
      if (match) {
        // A list entry that starts a map: re-read it at the column the key sits in.
        const keyColumn = indent + (body === '-' ? 1 : 2);
        state.at -= 1;
        lines[state.at] = { text: ' '.repeat(keyColumn) + rest, number: line.number, indent: keyColumn };
        out.push(map(keyColumn));
        continue;
      }
      out.push(scalar(rest, line.number));
    }
    return out;
  }

  function map(indent) {
    const out = {};
    while (state.at < lines.length && lines[state.at].indent === indent) {
      const line = lines[state.at];
      const body = line.text.trimStart();
      if (body.startsWith('- ')) break;
      const match = KEY.exec(body);
      if (!match) throw new YamlError('this line is neither a key nor a list entry', line.number, line.indent);
      const key = match[1] !== undefined ? match[1] : match[2] !== undefined ? match[2].replaceAll("''", "'") : match[3].trim();
      const rest = (match[4] ?? '').trim();
      state.at += 1;
      if (/^[|>][-+]?\d*$/.test(rest)) { out[key] = blockScalar(rest, indent); continue; }
      if (rest && !rest.startsWith('#')) { out[key] = scalar(rest, line.number); continue; }
      out[key] = value(indent + 1);
    }
    return out;
  }

  const result = value(lines[0].indent);
  if (state.at < lines.length) throw new YamlError('the indentation goes back out to a column no parent uses', lines[state.at].number, lines[state.at].indent);
  return result;
}

// The front matter block of a SKILL.md or a rule file: the text between the
// first two `---` lines. Returns null when the file has no front matter.
export function frontMatter(source) {
  const text = String(source ?? '').replace(/\r\n?/g, '\n');
  if (!text.startsWith('---\n')) return null;
  const end = text.indexOf('\n---', 3);
  if (end === -1) return null;
  const block = text.slice(4, end + 1);
  const parsed = parseYaml(block);
  return parsed && typeof parsed === 'object' && !Array.isArray(parsed) ? parsed : null;
}

// ---------------------------------------------------------------------------
// The scanners. One per part of the spec.
// ---------------------------------------------------------------------------

export const STATES = Object.freeze(['filled', 'empty', 'stale', 'not applicable', 'no extractor']);
export const NOT_FILLED = Object.freeze(['empty', 'stale', 'no extractor']);
export const CREDENTIAL_NAME = /^[A-Z][A-Z0-9_]*$/;
const PINNED = /^[0-9a-f]{40}$/;
const MAX_LISTED = 12;

const readText = (root, path) => { try { return readFileSync(join(root, path), 'utf8'); } catch { return null; } };
const isDirectory = (root, path) => { try { return statSync(join(root, path)).isDirectory(); } catch { return false; } };
const isFile = (root, path) => { try { return statSync(join(root, path)).isFile(); } catch { return false; } };

function walk(root, path, out = []) {
  let entries;
  try { entries = readdirSync(join(root, path), { withFileTypes: true }); } catch { return out; }
  for (const entry of entries.sort((a, b) => a.name.localeCompare(b.name))) {
    if (entry.name.startsWith('.')) continue;
    const child = posix.join(path, entry.name);
    if (entry.isDirectory()) walk(root, child, out);
    else if (entry.isFile()) out.push(child);
  }
  return out;
}

// Every symbolic link under a path. `walk` pushes only `entry.isFile()`, and a
// symbolic link is neither a file nor a directory, so it was invisible: a page
// under docs/ could be a link to any path in the repository, the check scored
// nothing, and a renderer that follows the link publishes what it points at
// (security persona, finding S3-10). This does not follow a link, so a loop is
// not reachable.
function symlinks(root, path, out = []) {
  let entries;
  try { entries = readdirSync(join(root, path), { withFileTypes: true }); } catch { return out; }
  for (const entry of entries.sort((a, b) => a.name.localeCompare(b.name))) {
    if (entry.name.startsWith('.')) continue;
    const child = posix.join(path, entry.name);
    if (entry.isSymbolicLink()) out.push(child);
    else if (entry.isDirectory()) symlinks(root, child, out);
  }
  return out;
}

// A symbolic link is a finding, never a state on its own: the part it sits
// under says what state it makes.
function symlinkFindings(root, path, keep = () => true) {
  const found = symlinks(root, path).filter(keep);
  return found.length
    ? [`${found.length} symbolic link(s) under ${path}/: ${found.slice(0, MAX_LISTED).join(', ')}; the check does not follow one, and a renderer that does would publish what it points at`]
    : [];
}

// Relative link targets a markdown file points at. Placeholders and parent
// paths are left out: they are not this repo's files.
export function pointers(text) {
  const out = new Set();
  for (const [, target] of String(text ?? '').matchAll(/\]\(([^)\s]+)(?:\s+"[^"]*")?\)/g)) {
    const path = target.split('#')[0].trim();
    if (!path || /^[a-z][a-z0-9+.-]*:/i.test(path) || path.startsWith('/') || path.startsWith('..') || path.startsWith('#')) continue;
    if (/[<>*{}$\\]/.test(path) || path.includes('...')) continue;
    out.add(path.replace(/^\.\//, ''));
  }
  return [...out];
}

// Every docs/ path an instruction file names, as a link, in backticks, or bare.
// One spelling per file. `docs/./index.md` and `docs//index.md` name the file
// `docs/index.md` names, and every consumer compares these paths as strings:
// the exemption below, and the merge actor of slice L4, which takes its
// excluded set from this list. Two characters of spelling would otherwise make
// a second row and leave the first one reading "nothing else names it", which
// is a false sentence in a report a gate reads.
export function normalizeDocsPath(path) {
  const parts = [];
  for (const piece of String(path).split('/')) {
    if (piece === '' || piece === '.') continue;
    if (piece === '..') { parts.pop(); continue; }
    parts.push(piece);
  }
  return parts.join('/');
}

export function docsReferences(text) {
  const out = new Set();
  for (const [, path] of String(text ?? '').matchAll(/(?:^|[\s`(\[<"'])(docs\/[A-Za-z0-9._/-]+)/g)) {
    const clean = normalizeDocsPath(path.replace(/[.,;:]+$/, ''));
    if (!clean.startsWith('docs/') || clean.endsWith('/') || /[<>*{}$]/.test(clean)) continue;
    out.add(clean);
  }
  return [...out];
}

function entryFor(part, kind) {
  const state = part.kind?.[kind];
  if (!state) throw new SpecError(`the spec gives part ${part.id} no state for kind ${kind}`);
  return state;
}

const result = (part, state, findings = []) => ({ id: part.id, path: part.path ?? part.default_path ?? null, procedure: part.procedure ?? null, holds: part.holds ?? '', class: part.class ?? null, state, findings });

function checkMarkdown(context, part) {
  const text = readText(context.root, part.path);
  if (text === null || !text.trim()) return result(part, 'empty', [`${part.path} is missing or holds nothing`]);
  // Design page D1 says the check says "wrong" when the entry map is missing,
  // over its line limit, or a pointer is dead. All three are states, not notes
  // on a filled file, or the count the report leads with is short (review R-1).
  const findings = [];
  const lines = text.replace(/\n$/, '').split('\n').length;
  if (part.max_lines && lines > part.max_lines) findings.push(`${lines} lines, over the ${part.max_lines}-line limit`);
  const dead = pointers(text).filter((path) => !existsSync(join(context.root, path)));
  if (dead.length) findings.push(`${dead.length} pointer(s) name nothing on disk: ${dead.slice(0, MAX_LISTED).join(', ')}`);
  return findings.length ? result(part, 'stale', findings) : result(part, 'filled');
}

function checkPathRules(context, part) {
  if (!isDirectory(context.root, part.path)) return result(part, 'empty', [`${part.path}/ does not exist`]);
  const files = walk(context.root, part.path).filter((path) => path.endsWith('.md'));
  if (!files.length) return result(part, 'empty', [`${part.path}/ holds no rule`]);
  const bad = [];
  for (const file of files) {
    const front = frontMatter(readText(context.root, file) ?? '');
    const paths = front?.paths;
    const list = Array.isArray(paths) ? paths : typeof paths === 'string' ? [paths] : [];
    if (!list.length) { bad.push(`${file} has no paths: key`); continue; }
    for (const pattern of list) {
      const base = String(pattern).split(/[*?[]/)[0].replace(/\/+$/, '');
      if (base && !existsSync(join(context.root, base))) bad.push(`${file} names ${pattern}, which does not exist`);
    }
  }
  return bad.length ? result(part, 'stale', bad.slice(0, MAX_LISTED)) : result(part, 'filled', [`${files.length} rule file(s)`]);
}

function checkProcedure(context, part) {
  const named = context.facts?.procedures?.[part.procedure];
  if (named === undefined) return result(part, 'empty', [`atlas.yaml has no procedures entry for ${part.procedure}`]);
  if (named === null || named === '') return result(part, 'empty', [`atlas.yaml sets procedures.${part.procedure} to null: the repo has no skill for it yet`]);
  const skill = posix.join('.claude/skills', String(named), 'SKILL.md');
  if (!isFile(context.root, skill)) return result(part, 'stale', [`atlas.yaml names skill "${named}", and ${skill} does not exist`]);
  const front = frontMatter(readText(context.root, skill) ?? '');
  if (!front?.name || !front?.description) return result(part, 'stale', [`${skill} has no name or no description in its front matter`]);
  return result(part, 'filled', [skill]);
}

// `scan` reports a missing or unreadable atlas.yaml as an error and returns
// before it scans any part, because the file names the kind, and the kind
// decides which parts a repo needs. So this scanner only ever runs on a file
// that parsed. The two dead guards that stood here are gone (acceptance review
// of batch 14b, finding 4).
function checkFactsRoot(context, part) {
  const missing = (part.keys ?? []).filter((key) => context.facts[key] === undefined || context.facts[key] === null || context.facts[key] === '');
  const findings = [];
  if (missing.length) return result(part, 'stale', [`atlas.yaml has no ${missing.join(', ')}`]);
  if (context.repoId && String(context.facts.repo) !== context.repoId) return result(part, 'stale', [`atlas.yaml names repo "${context.facts.repo}"; this checkout is ${context.repoId}`]);
  if (!context.facts.procedures) findings.push('atlas.yaml has no procedures map, so no procedure can be found');
  return result(part, 'filled', findings);
}

function sectionPath(context, part) {
  const pointed = context.facts?.files?.[part.section];
  return typeof pointed === 'string' && pointed.trim() ? pointed.trim() : part.default_path;
}

// A pointer in atlas.yaml names a file inside this repo. One that leaves the
// checkout would make the check read a stranger's file, and a parse error
// would carry a line of it into the CI log (review R-5).
export function insideRepo(root, path) {
  const base = resolve(root);
  const target = resolve(base, path);
  const step = relative(base, target);
  return step !== '' && !step.startsWith('..') && !posix.isAbsolute(step.split('\\').join('/'));
}

function readSection(context, part) {
  const path = sectionPath(context, part);
  if (!insideRepo(context.root, path)) return { path, outside: true };
  const text = readText(context.root, path);
  if (text === null || !text.trim()) return { path, missing: true };
  try { return { path, text, data: parseYaml(text) }; }
  catch (error) { return { path, text, error: error instanceof YamlError ? error.message : String(error?.message ?? error) }; }
}

const emptyValue = (value) => value === undefined || value === null || value === '' || (Array.isArray(value) && !value.length) || (typeof value === 'object' && !Array.isArray(value) && !Object.keys(value).length);

// A secret in any file the check reads, over the raw text, before anything is
// parsed or echoed. The patterns used to run over atlas/credentials.yaml alone,
// and every other facts file has its values quoted into findings: the kind, the
// repo id, a procedure's skill name, a pointer path (acceptance review of batch
// 16, note S3-2).
function secretIn(context, path, text) {
  for (const pattern of context.secretPatterns) {
    if (pattern.test(text ?? '')) {
      context.errors.push(`${path} holds something that looks like a secret value; no file the check reads carries one`);
      return true;
    }
  }
  return false;
}

function checkFactsSection(context, part) {
  const section = readSection(context, part);
  const withPath = { ...part, path: section.path };
  if (section.outside) return result(withPath, 'stale', [`atlas.yaml points at "${section.path}", which is outside the repo; the check reads this repo only`]);
  if (section.missing) return result(withPath, 'empty', [`${section.path} does not exist`]);
  if (secretIn(context, section.path, section.text)) return result(withPath, 'stale', [`${section.path} holds something that looks like a secret value`]);
  if (section.error) return result(withPath, 'stale', [`${section.path} cannot be read: ${section.error}`]);
  // `keys` must hold content. `keys_present` must exist and may be empty: a
  // repo with no dependency still answers, with `repos: []`.
  const missing = (part.keys ?? []).filter((key) => emptyValue(section.data?.[key]));
  const absent = (part.keys_present ?? []).filter((key) => section.data?.[key] === undefined || section.data?.[key] === null);
  const findings = [...missing, ...absent];
  if (findings.length) return result(withPath, 'stale', [`${section.path} has no ${findings.join(', ')}`]);
  return result(withPath, 'filled');
}

function checkCredentials(context, part) {
  const section = readSection(context, part);
  const withPath = { ...part, path: section.path };
  if (section.outside) return result(withPath, 'stale', [`atlas.yaml points at "${section.path}", which is outside the repo; the check reads this repo only`]);
  if (section.missing) return result(withPath, 'empty', [`${section.path} does not exist`]);
  // The patterns run over the raw text FIRST, before anything reads the parse
  // result and before a parse error can be reported. A credential written with
  // bad indentation used to take the parse-error path out of this function, so
  // the one content check in the whole check never ran on the one file it
  // guards (security persona, finding S2-6).
  for (const pattern of context.secretPatterns) {
    if (pattern.test(section.text ?? '')) {
      context.errors.push(`${section.path} holds something that looks like a secret value; this file carries names only`);
      return result(withPath, 'stale', [`${section.path} holds something that looks like a secret value`]);
    }
  }
  if (section.error) return result(withPath, 'stale', [`${section.path} cannot be read: ${section.error}`]);
  const rows = section.data?.credentials;
  if (emptyValue(rows)) return result(withPath, 'stale', [`${section.path} has no credentials`]);
  const names = (Array.isArray(rows) ? rows : Object.values(rows)).map((row) => (typeof row === 'string' ? row : row?.name));
  const bad = names.filter((name) => !CREDENTIAL_NAME.test(String(name ?? '')));
  if (bad.length) return result(withPath, 'stale', [`${bad.length} credential name(s) are not written as A-Z, digits and underscore: ${bad.slice(0, MAX_LISTED).join(', ')}`]);
  return result(withPath, 'filled', [`${names.length} credential name(s)`]);
}

function checkDocsIndex(context, part) {
  const text = readText(context.root, part.path);
  if (text === null || !text.trim()) return result(part, 'empty', [`${part.path} is missing or holds nothing`]);
  const listed = new Set(pointers(text).map((path) => (path.startsWith('docs/') ? path : posix.join('docs', path))));
  const onDisk = walk(context.root, 'docs').filter((path) => path.endsWith('.md') && path !== part.path && !path.startsWith('docs/site/'));
  const unlisted = onDisk.filter((path) => !listed.has(path));
  const gone = [...listed].filter((path) => !existsSync(join(context.root, path)));
  const findings = [];
  if (unlisted.length) findings.push(`${unlisted.length} file(s) under docs/ are not listed: ${unlisted.slice(0, MAX_LISTED).join(', ')}`);
  if (gone.length) findings.push(`${gone.length} listed file(s) are gone: ${gone.slice(0, MAX_LISTED).join(', ')}`);
  // The docs tree outside docs/site/. The pages part below owns docs/site/.
  findings.push(...symlinkFindings(context.root, 'docs', (path) => !path.startsWith('docs/site/')));
  return findings.length ? result(part, 'stale', findings) : result(part, 'filled', [`${onDisk.length} file(s) listed`]);
}

function checkDocsPages(context, part) {
  const links = symlinkFindings(context.root, part.path);
  if (!isDirectory(context.root, part.path)) return result(part, 'empty', [`${part.path}/ does not exist`]);
  const pages = walk(context.root, part.path).filter((path) => path.endsWith('.md') && !path.endsWith('/notes.md'));
  if (!pages.length) return result(part, links.length ? 'stale' : 'empty', [`${part.path}/ holds no page`, ...links]);
  const without = pages.filter((path) => !frontMatter(readText(context.root, path) ?? '')?.built_from);
  const findings = [...(without.length ? [`${without.length} page(s) do not name the commit they were built from: ${without.slice(0, MAX_LISTED).join(', ')}`] : []), ...links];
  return findings.length ? result(part, 'stale', findings) : result(part, 'filled', [`${pages.length} page(s)`]);
}

function checkFeatures(context, part) {
  const text = readText(context.root, part.path);
  if (text === null || !text.trim()) return result(part, 'empty', [`${part.path} is missing or holds nothing`]);
  let data;
  try { data = parseYaml(text); } catch (error) { return result(part, 'stale', [`${part.path} cannot be read: ${error.message}`]); }
  const rows = data?.features;
  if (emptyValue(rows)) return result(part, 'stale', [`${part.path} lists no feature`]);
  const list = Array.isArray(rows) ? rows : Object.values(rows);
  const dead = list.filter((row) => row?.page && !existsSync(join(context.root, String(row.page)))).map((row) => row.page);
  return dead.length ? result(part, 'stale', [`${dead.length} feature page(s) are gone: ${dead.slice(0, MAX_LISTED).join(', ')}`]) : result(part, 'filled', [`${list.length} feature(s)`]);
}

function checkNotes(context, part) {
  const text = readText(context.root, part.path);
  if (text === null || !text.trim()) return result(part, 'empty', [`${part.path} is missing or holds nothing`]);
  // Finding R12 and the spec: each note names who said it and the session.
  // A note that does not is a stale note, not a remark on a filled file.
  const entries = text.split('\n').filter((line) => /^\s*[-*]\s+/.test(line));
  if (!entries.length) return result(part, 'empty', [`${part.path} holds no note`]);
  const without = entries.filter((line) => !/session/i.test(line));
  if (without.length) return result(part, 'stale', [`${without.length} of ${entries.length} note(s) do not name the session they came from`]);
  return result(part, 'filled', [`${entries.length} note(s)`]);
}

function checkGenerated(context, part) {
  const available = context.extractors.includes(part.extractor);
  if (!available) return result(part, 'no extractor', [`no ${part.extractor} extractor exists yet; slice L3 builds it`]);
  const text = readText(context.root, part.path);
  if (text === null || !text.trim()) return result(part, 'empty', [`${part.path} is missing or holds nothing`]);
  return result(part, 'filled');
}

// Every permission the workflow grants at anything other than read. It reads a
// block map under `permissions:` and a flow map on the same line.
function writeGrants(text) {
  const out = [];
  const flow = /^\s*permissions\s*:\s*\{([^}]*)\}/m.exec(text);
  if (flow) {
    for (const pair of flow[1].split(',')) {
      const [name, value] = pair.split(':').map((piece) => (piece ?? '').trim());
      if (name && value && value !== 'read' && value !== 'none') out.push(`${name}: ${value}`);
    }
    return out;
  }
  const lines = text.replace(/\r\n?/g, '\n').split('\n');
  const head = lines.findIndex((line) => /^\s*permissions\s*:\s*$/.test(line));
  if (head === -1) return out;
  const indent = lines[head].length - lines[head].trimStart().length;
  for (let index = head + 1; index < lines.length; index += 1) {
    const line = lines[index];
    if (!line.trim()) continue;
    if (line.length - line.trimStart().length <= indent) break;
    const [name, value] = line.split(':').map((piece) => (piece ?? '').trim());
    if (name && value && value !== 'read' && value !== 'none') out.push(`${name}: ${value}`);
  }
  return out;
}

// Everything the check can only learn from the workflow's STRUCTURE, read from
// the parsed document and never from a line of text.
//
// The first version of this read lines. The acceptance reviewer of batch 16
// defeated it nine ways (finding S2-1). Three of those mattered most: replace
// the step that runs the check, delete it, or set `steps: []`, and the part
// still read "filled". A rule about "an `if:` on the check step" means nothing
// when nothing requires the check step to be there at all.
//
// A workflow this function cannot read is a finding, not a pass. That is the
// safe direction: the check says it cannot confirm the job runs, instead of
// saying the job is fine.
function workflowStructure(document) {
  const out = [];
  const jobs = document?.jobs;
  if (!jobs || typeof jobs !== 'object') return ['the workflow declares no jobs'];

  // The trigger. `paths` and `paths-ignore` stop the job from running at all on
  // the pull requests that change the files it guards, and the pull request
  // still reads green, because a job that never ran reports nothing (P13).
  const on = document.on;
  const trigger = on && typeof on === 'object' && !Array.isArray(on) ? on.pull_request : null;
  if (trigger && typeof trigger === 'object' && !Array.isArray(trigger)) {
    for (const key of ['paths', 'paths-ignore']) {
      if (trigger[key] !== undefined && trigger[key] !== null) {
        out.push(`the workflow narrows its trigger with ${key}; this check must run on every pull request`);
      }
    }
  }

  // The step that runs the check. Without it the workflow is a workflow that
  // runs nothing, and every rule below has nothing to attach to.
  let found = null;
  for (const [jobName, job] of Object.entries(jobs)) {
    for (const step of Array.isArray(job?.steps) ? job.steps : []) {
      const runs = typeof step?.run === 'string' ? step.run : '';
      if (runs.includes(CHECK_PATH)) found = { jobName, job, step, runs };
    }
  }
  if (!found) {
    out.push(`no step in this workflow runs "node ${CHECK_PATH}", so the job reports nothing`);
    return out;
  }

  // The no-loss rule's own two inputs, from slice L2 stage two.
  //
  // Without them the check still runs, still prints a report, and still goes
  // green — and the no-loss rule never runs at all. That is the same class of hole
  // the batch 16 reviewer found nine ways (finding S2-1): a workflow that
  // silences the job while the part still reads "filled". Deleting two flags
  // is the cheapest version of it, so the scanner reads the flags, not just
  // the path.
  for (const flag of ['--base', '--base-sha']) {
    if (!new RegExp(`${flag}(?:[ \t=]|$)`, 'm').test(found.runs)) {
      out.push(`the check step does not pass ${flag}, so the no-loss rule never runs and a pull request can take a part away with the job still green`);
    }
  }
  // And the tree it compares against has to be fetched by something.
  const fetchesBase = Object.values(jobs).some((job) => (Array.isArray(job?.steps) ? job.steps : [])
    .some((step) => typeof step?.uses === 'string' && step.uses.startsWith('actions/checkout') && step?.with?.path === BASE_DIR));
  if (!fetchesBase) {
    out.push(`no step checks the base commit out into ${BASE_DIR}, so the no-loss rule has no tree to compare against`);
  }

  // A condition switches the step, or its whole job, off. Same effect as a
  // narrowed trigger, by another route.
  if (found.step.if !== undefined) out.push('the workflow puts an if: on the check step; the step must always run');
  if (found.job.if !== undefined) out.push("the workflow puts an if: on the check's job; the job must always run");
  // Two more ways to make a red check look green. Neither is in the frozen
  // list. Both defeat the same purpose, and stage two's no-loss rule needs a red job
  // to mean something, so the check names them (reviewer of batch 16, S2-1).
  if (found.step['continue-on-error'] === true || found.job['continue-on-error'] === true) {
    out.push('the workflow sets continue-on-error on the check; a failed check would not turn the job red');
  }
  if (/\|\|\s*(true|exit\s+0|:)\s*$/m.test(found.runs)) {
    out.push('the check step swallows its own exit code, so a failed check would not turn the job red');
  }
  return out;
}

function checkWorkflow(context, part) {
  const text = readText(context.root, part.path);
  if (text === null || !text.trim()) return result(part, 'empty', [`${part.path} is missing or holds nothing`]);
  const findings = [];
  if (/^\s*pull_request_target\s*:/m.test(text)) findings.push('the workflow runs on pull_request_target; it must run on pull_request');
  if (!/^\s*pull_request\s*:/m.test(text)) findings.push('the workflow does not run on pull_request');
  // The structure, from the parsed document. A workflow this check cannot read
  // is a finding: it can no longer say the job runs at all.
  try {
    findings.push(...workflowStructure(parseYaml(text)));
  } catch (error) {
    findings.push(`${part.path} cannot be read, so the check cannot confirm this workflow runs it: ${error instanceof YamlError ? error.message : 'the file is not the YAML subset this check reads'}`);
  }
  if (!/^\s*timeout-minutes\s*:\s*\d+\s*$/m.test(text)) findings.push('the workflow sets no timeout-minutes; a run with no wall-clock bound is billed until it is killed');
  if (!/^\s*contents\s*:\s*read\s*$/m.test(text)) findings.push('the workflow does not set permissions contents: read');
  // A write permission beside the read one still grants write. GitHub accepts
  // a block map and a flow map for both permissions and steps, so read both
  // spellings or a workflow can widen itself past the check (review R-3).
  for (const grant of writeGrants(text)) findings.push(`the workflow grants ${grant}; this check needs read access only`);
  if (/\bsecrets\./.test(text)) findings.push('the workflow reads a repository secret; this check takes none');
  const unpinned = [...text.matchAll(/uses[ \t]*:[ \t]*["']?([^\s,}\]"']+)/g)]
    .map(([, value]) => value)
    .filter((value) => !value.startsWith('./'))
    .filter((value) => !PINNED.test(value.split('@')[1] ?? ''));
  if (unpinned.length) findings.push(`${unpinned.length} action(s) are not pinned by commit SHA: ${unpinned.slice(0, MAX_LISTED).join(', ')}`);
  return findings.length ? result(part, 'stale', findings) : result(part, 'filled');
}

// The stamps a copy of the check carries, read from its text. Reading the text
// works for any copy; importing it would only work for this one.
//
// A copy from before row F11 carries no CHECK_VERSION. When it declares a spec,
// it still reads as the Atlas check, so the no-loss rule can score a base tree that
// holds an old copy.
export function checkStamps(text) {
  const check = /^export const CHECK_VERSION = (\d+);/m.exec(text ?? '');
  const specs = [...String(text ?? '').matchAll(/^export const SPEC_(\d+) = /gm)].map(([, version_]) => Number(version_));
  return {
    check_version: check ? Number(check[1]) : null,
    version: check ? `check ${check[1]}` : specs.length ? 'a check from before check versions' : null,
    specs: specs.sort((a, b) => a - b),
  };
}

// File 7's own part, from spec 2. The check is judging its own sibling here, so
// it says only what a clone can prove. It never asks whether the copy is
// current: CI has no package to compare with, and a check with no network
// cannot learn the package's hash. The session verb makes that judgement from
// the package's release list (amendment A1.9), and the merge actor makes it
// again at slice L4.
//
// What it does prove, and what it puts in the report: the copy is there, it is
// the Atlas check, it can read the spec version this repo declares, and its
// sha256. The hash is the value the session verb and the merge actor compare,
// so the report is where they read it.
function checkCheckFile(context, part) {
  const text = readText(context.root, part.path);
  if (text === null || !text.trim()) return result(part, 'empty', [`${part.path} is missing or holds nothing; this repo runs no check of its own`]);
  const stamps = checkStamps(text);
  if (!stamps.version || !stamps.specs.length) {
    return result(part, 'stale', [`${part.path} does not read as the Atlas check: it carries no check version or no spec`]);
  }
  const declared = Number(context.facts?.spec);
  const findings = [stamps.version, `reads spec ${stamps.specs.join(', ')}`, `sha256 ${sha256(text)}`];
  if (Number.isInteger(declared) && !stamps.specs.includes(declared)) {
    return result(part, 'stale', [...findings, `this copy cannot read spec ${declared}, which atlas.yaml declares; refresh it`]);
  }
  return result(part, 'filled', findings);
}

function checkLinters(context, part) {
  const found = (part.candidates ?? []).filter((path) => existsSync(join(context.root, path)));
  return found.length ? result(part, 'filled', [found.slice(0, MAX_LISTED).join(', ')]) : result(part, 'empty', ['no linter or formatter config at the root']);
}

const CHECKS = {
  markdown: checkMarkdown,
  'path-rules': checkPathRules,
  procedure: checkProcedure,
  'facts-root': checkFactsRoot,
  'facts-section': checkFactsSection,
  'facts-credentials': checkCredentials,
  'docs-index': checkDocsIndex,
  'docs-pages': checkDocsPages,
  features: checkFeatures,
  notes: checkNotes,
  generated: checkGenerated,
  workflow: checkWorkflow,
  'check-file': checkCheckFile,
  linters: checkLinters,
};

// The one exemption in the by-reference set, and it is exactly one.
//
// File 1, the entry map, must hold a pointer to each of the seven files, and
// `docs/index.md` is one of them. Rule R1 makes any `docs/` file an instruction
// file points at instruction class by reference. Those two together make the
// index instruction class, and the frozen L4 path limit lets the upkeep routine
// self-merge it. Three rules, and the index can satisfy none of them.
//
// The owner cut the knot: a pointer from the entry map to
// `docs/index.md` does not make the index instruction class. An index lists
// files; it does not steer an agent.
//
// Bounded three ways, because the reason is true of a list and false of prose:
// only this one path, only these two pointing files, and the row stays in the
// report with `exempt: true` so nothing is hidden. Any other instruction file
// that names the index still makes it instruction class, and the index's own
// row then carries that file. The docs lint of slice L3 bounds the rest, by
// treating the index as an agent-facing surface.
export const EXEMPT_PATH = 'docs/index.md';
export const EXEMPT_FROM = Object.freeze(['CLAUDE.md', 'AGENTS.md']);

export function applyExemption(rows) {
  return rows.map((row) => {
    if (row.path !== EXEMPT_PATH) return row;
    const kept = row.pointed_at_by.filter((path) => !EXEMPT_FROM.includes(path));
    if (kept.length === row.pointed_at_by.length) return row;
    const exempt = !kept.length;
    return {
      ...row,
      pointed_at_by: kept,
      exempt,
      exempt_note: exempt
        ? `the entry map points here and that alone does not make it instruction class; nothing else names it`
        : `the entry map points here and that alone does not make it instruction class; ${kept.join(', ')} still does`,
    };
  });
}

function byReference(context, spec) {
  const scanned = [];
  for (const pattern of spec.by_reference?.scanned ?? []) {
    if (!pattern.includes('*')) { if (isFile(context.root, pattern)) scanned.push(pattern); continue; }
    const [head] = pattern.split('*');
    const directory = head.replace(/\/+$/, '');
    const tail = pattern.slice(pattern.lastIndexOf('*') + 1);
    for (const file of walk(context.root, directory)) if (file.endsWith(tail)) scanned.push(file);
  }
  const found = new Map();
  for (const file of scanned) {
    for (const path of docsReferences(readText(context.root, file) ?? '')) {
      if (!found.has(path)) found.set(path, { path, exists: existsSync(join(context.root, path)), pointed_at_by: [] });
      found.get(path).pointed_at_by.push(file);
    }
  }
  return applyExemption([...found.values()].sort((a, b) => a.path.localeCompare(b.path)));
}

export function readFacts(root) {
  const text = readText(root, 'atlas.yaml');
  if (text === null || !text.trim()) return { facts: null, error: null };
  try {
    const data = parseYaml(text);
    if (!data || typeof data !== 'object' || Array.isArray(data)) return { facts: null, error: 'atlas.yaml is not a map of keys' };
    return { facts: data, error: null };
  } catch (error) { return { facts: null, error: `atlas.yaml cannot be read: ${error.message}` }; }
}

// `scoreAs` is the no-loss rule's one lever. It replaces the kind and the spec this
// tree declares with the ones handed in, so two trees are scored by the same
// yardstick. Without it the base's `kind: service` and the head's
// `kind: library` would be two different spec tables, and the comparison would
// mean nothing (architect finding P2). Nothing else about the scan changes: the
// tree still speaks for itself about every part.
export function scan({ root, repoId = null, extractors = [], secretPatterns: patterns = secretPatterns(), scoreAs = null }) {
  const { facts, error: factsError } = readFacts(root);
  const errors = [];
  // The credential-value check is the only thing that turns the job red at the
  // shipped fail-on level. An empty pattern list disarms it, so it is an error,
  // never a silent pass (review R-6).
  // A list that is not a list of patterns used to crash here. It must refuse
  // the same way an empty list does (acceptance review of batch 14b, finding 10).
  const usable = Array.isArray(patterns) && patterns.every((pattern) => pattern instanceof RegExp) ? patterns : [];
  if (!usable.length) errors.push('the secret pattern list is empty or is not a list of patterns, so a credential value could not be caught; this check cannot be trusted');
  // Counting the patterns was never enough. Each one is tested against its own
  // canary, so a pattern edited to match nothing is loud (finding S2-5).
  const missed = canaryMisses();
  if (missed.length) errors.push(`${missed.length} secret pattern(s) no longer catch their own canary: ${missed.join(', ')}; this check cannot be trusted`);
  if (!facts && !factsError) errors.push('atlas.yaml does not exist, so the check cannot learn the spec version or the repo kind');
  if (factsError) errors.push(factsError);
  const kind = scoreAs ? scoreAs.kind ?? null : facts?.kind ?? null;
  const wantedSpec = scoreAs ? scoreAs.spec : facts?.spec;
  let spec = null;
  if (facts) {
    try { spec = loadSpec(wantedSpec); }
    catch (error) { errors.push(error.message); }
  }
  if (spec && !spec.kinds[kind]) { errors.push(`atlas.yaml names kind "${kind}"; spec ${spec.spec} knows ${Object.keys(spec.kinds).join(', ')}`); spec = null; }
  if (!spec) return { ok: false, check_version: CHECK_VERSION, repo: repoId, kind, spec: wantedSpec ?? null, scored_as: scoreAs, product: facts?.product ?? null, files: [], by_reference: [], counts: counts([]), errors };

  const context = { root, facts, factsError, repoId, extractors, secretPatterns: usable, errors };
  // atlas.yaml's own values reach the report: the kind, the repo id, a
  // procedure's skill name, every pointer path. Scan it before any of them is
  // quoted (acceptance review of batch 16, note S3-2).
  secretIn(context, 'atlas.yaml', readText(root, 'atlas.yaml'));
  const files = spec.files.map((file) => ({
    id: file.id,
    number: file.number,
    title: file.title,
    class: file.class,
    written_by: file.written_by,
    parts: file.parts.map((part) => {
      const required = entryFor(part, kind);
      if (required === 'not applicable') return { ...result(part, 'not applicable', [`a ${kind} repo does not need it`]), required };
      const check = CHECKS[part.check];
      if (!check) throw new SpecError(`the spec names check "${part.check}", which this version of the check does not have`);
      return { ...check(context, part), required };
    }),
  }));
  return { ok: !errors.length, check_version: CHECK_VERSION, repo: repoId ?? facts.repo ?? null, kind, spec: spec.spec, scored_as: scoreAs, product: facts.product ?? null, files, by_reference: byReference(context, spec), counts: counts(files), errors };
}

export function counts(files) {
  const out = { filled: 0, empty: 0, stale: 0, 'not applicable': 0, 'no extractor': 0, required: 0, optional: 0, not_filled: 0, required_not_filled: 0, optional_not_filled: 0 };
  for (const file of files) for (const part of file.parts) {
    out[part.state] += 1;
    if (part.required === 'required') out.required += 1;
    if (part.required === 'optional') out.optional += 1;
    if (NOT_FILLED.includes(part.state)) {
      out.not_filled += 1;
      if (part.required === 'required') out.required_not_filled += 1;
      if (part.required === 'optional') out.optional_not_filled += 1;
    }
  }
  return out;
}

// ---------------------------------------------------------------------------
// The no-loss rule. Milestone M2, slice L2 stage two.
//
// What it is. A pull request may not take away an instruction-class part that
// the base commit already had. Nothing else. It is never red on debt that was
// there before, and it is red on the pull request that made things worse.
//
// Why a no-loss rule and not a level. Turning `fail-on` up to `required` goes red on
// the day it is switched on, for parts a later slice builds. The first repo it
// ran on had seven required parts not filled, four of them a later slice's
// work. A level
// asks the repository to be finished. A no-loss rule asks it not to go backwards.
//
// Why per part and never a count. A count is defeated two ways. Empty one part,
// fill another, and the total does not move. Or change one line: `atlas.yaml`
// names the `kind`, the kind decides which parts are required, and `atlas.yaml`
// is inside the diff being scored, so `kind: service` to `kind: library` turns
// four required parts into "not applicable" and the count falls. Scoring per
// part, with the base tree's `kind` and `spec`, closes both (findings P2, P20).
//
// Which copy scores. The head's. That is this file. A pull request that
// improves the check would otherwise turn red under the old scanners, and a
// pull request that weakens one would turn green under them. The head's copy
// judging its own diff would be a hole, so the two cases where the diff touches
// the gate are the first two report-only cases below: a person merges those
// files, and the check says plainly that it did not gate (finding P1).
//
// Where it lives. Here. The repository still carries two files and only two.
// ---------------------------------------------------------------------------

// The five cases where the no-loss rule reports and does not gate. Each is named in
// the report, so a reader never has to guess why the job stayed green.
export const NO_LOSS_CASES = Object.freeze(['check-file', 'workflow', 'kind', 'spec', 'base-tree']);

const fileHash = (root, path) => { const text = readText(root, path); return text === null ? null : sha256(text); };

// The commit a checkout sits on, read from `.git/HEAD` as text. No git binary,
// no network. `actions/checkout` leaves a detached HEAD, so the first line is
// usually the SHA itself; a `ref:` line is followed once.
export function checkoutHead(root) {
  const head = readText(root, '.git/HEAD');
  if (head === null) return null;
  const line = head.trim();
  if (/^[0-9a-f]{40}$/.test(line)) return line;
  const named = /^ref:\s*(\S+)$/.exec(line);
  if (!named) return null;
  const loose = readText(root, posix.join('.git', named[1]));
  if (loose && /^[0-9a-f]{40}$/.test(loose.trim())) return loose.trim();
  // A clone may pack its refs instead of writing one file each.
  for (const row of (readText(root, '.git/packed-refs') ?? '').split('\n')) {
    const [sha, ref] = row.trim().split(/\s+/);
    if (ref === named[1] && /^[0-9a-f]{40}$/.test(sha ?? '')) return sha;
  }
  return null;
}

const partIndex = (report) => {
  const map = new Map();
  for (const file of report.files) for (const part of file.parts) map.set(`${file.id}/${part.id}`, { file, part });
  return map;
};

export function noLoss({ headRoot, baseRoot, baseSha = null, repoId = null, secretPatterns: patterns = secretPatterns() }) {
  const out = {
    ran: true,
    gates: true,
    green: true,
    base_dir: baseRoot,
    base_sha: baseSha,
    base_head: null,
    base_facts: null,
    head_facts: null,
    parts_compared: 0,
    report_only: [],
    regressions: [],
  };
  const excuse = (name, why) => { out.gates = false; out.report_only.push({ case: name, why }); };

  // 1. Is there a base tree at all, and is it the pull request's base?
  const baseRead = readFacts(baseRoot);
  if (!existsSync(join(baseRoot, 'atlas.yaml'))) {
    excuse('base-tree', `no base tree at ${baseRoot}: the checkout of the base commit did not land, so there is nothing to compare`);
    return out;
  }
  if (baseRead.error || !baseRead.facts) {
    excuse('base-tree', `the base tree at ${baseRoot} has no readable atlas.yaml${baseRead.error ? `: ${baseRead.error}` : ''}, so its kind and spec cannot be read`);
    return out;
  }
  out.base_head = checkoutHead(baseRoot);
  // The pull request promised a base commit. If the tree cannot say which
  // commit it is, the promise is unchecked, and an unchecked promise is not a
  // base tree. Reporting a sha this check was handed but never read would be a
  // claim it cannot support, so it takes the base-tree case instead.
  if (baseSha && !out.base_head) {
    excuse('base-tree', `the base tree at ${baseRoot} does not say which commit it is, so this check cannot confirm it is ${baseSha.slice(0, 12)}, the base this pull request names`);
    return out;
  }
  if (baseSha && out.base_head !== baseSha) {
    excuse('base-tree', `the base tree at ${baseRoot} is at ${out.base_head.slice(0, 12)}, and this pull request's base is ${baseSha.slice(0, 12)}; the comparison would be against the wrong commit`);
    return out;
  }

  // 2. The base tree's kind and spec score both trees.
  const scoreAs = { kind: baseRead.facts.kind ?? null, spec: baseRead.facts.spec ?? null };
  const headRead = readFacts(headRoot);
  out.base_facts = scoreAs;
  out.head_facts = { kind: headRead.facts?.kind ?? null, spec: headRead.facts?.spec ?? null };

  if (String(out.head_facts.kind) !== String(scoreAs.kind)) {
    excuse('kind', `atlas.yaml names kind "${scoreAs.kind}" at the base and "${out.head_facts.kind}" at the head; this pull request changes which parts the repo needs`);
  }
  if (String(out.head_facts.spec) !== String(scoreAs.spec)) {
    excuse('spec', `atlas.yaml names spec "${scoreAs.spec}" at the base and "${out.head_facts.spec}" at the head; this pull request changes what the spec version means`);
  }

  // 3. Does the diff change the gate itself?
  for (const [name, path] of [['check-file', CHECK_PATH], ['workflow', WORKFLOW_PATH]]) {
    if (fileHash(baseRoot, path) !== fileHash(headRoot, path)) {
      excuse(name, `this pull request changes ${path}, which is the gate itself; it is instruction class, so a person merges it`);
    }
  }

  // 4. Score both trees, by the same yardstick, and compare part by part.
  const base = scan({ root: baseRoot, repoId, secretPatterns: patterns, scoreAs });
  const head = scan({ root: headRoot, repoId, secretPatterns: patterns, scoreAs });
  if (!base.files.length) {
    excuse('base-tree', `the base tree at ${baseRoot} could not be scored: ${base.errors.join('; ') || 'no parts came back'}`);
    return out;
  }

  const headParts = partIndex(head);
  for (const [key, { file, part }] of partIndex(base)) {
    if (file.class !== 'instruction' || part.state !== 'filled') continue;
    out.parts_compared += 1;
    const now = headParts.get(key);
    if (!now) {
      out.regressions.push({ part: key, label: label(part), was: 'filled', now: 'gone', why: `the spec part ${key} was filled at the base and this copy of the check no longer scores it` });
      continue;
    }
    if (now.part.state !== 'filled') {
      out.regressions.push({ part: key, label: label(now.part), was: 'filled', now: now.part.state, findings: now.part.findings, why: `${label(now.part)} was filled at the base and is ${now.part.state} at the head` });
    }
  }
  out.green = !out.regressions.length;
  return out;
}

// ---------------------------------------------------------------------------
// The report. Two shapes: plain text for the CI log, and GitHub markdown for
// the job summary. Both list every part, its state and its findings.
// ---------------------------------------------------------------------------

const MARK = { filled: '+', empty: '-', stale: '~', 'not applicable': '.', 'no extractor': '?' };
const label = (part) => part.procedure ? `procedure ${part.procedure}` : part.path ?? part.id;

// The one number the owner sees is the count of REQUIRED files not filled.
// An optional file that is empty is not a gap: the spec says optional (review
// finding S2-1). The optional count follows it, so nothing is hidden.
export function headline(report) {
  if (!report.spec) return 'Atlas repo shape: the check could not run.';
  const { counts: seen } = report;
  return `Atlas repo shape: ${seen.required_not_filled} of ${seen.required} required file(s) not filled; `
    + `${seen.optional_not_filled} of ${seen.optional} optional; ${seen['not applicable']} not applicable. `
    + `Kind: ${report.kind}. Spec: ${report.spec}. Check version: ${report.check_version}.`;
}

export function toText(report) {
  const lines = [headline(report), ''];
  for (const error of report.errors) lines.push(`ERROR  ${error}`);
  if (report.errors.length) lines.push('');
  for (const file of report.files) {
    lines.push(`${file.number}. ${file.title} (${file.class})`);
    for (const part of file.parts) {
      lines.push(`   ${MARK[part.state]} ${part.state.padEnd(14)} ${part.required.padEnd(8)} ${label(part)}`);
      for (const finding of part.findings) lines.push(`       - ${finding}`);
    }
    lines.push('');
  }
  const instruction = report.by_reference.filter((row) => !row.exempt);
  lines.push(`By reference: ${instruction.length} file(s) under docs/ are named by an instruction file, so they are instruction class too.`);
  for (const row of report.by_reference) {
    lines.push(`   ${row.exists ? '+' : '-'} ${row.path}  <- ${row.pointed_at_by.join(', ') || 'the entry map only'}${row.exempt ? '  [exempt]' : ''}`);
    if (row.exempt_note) lines.push(`       - ${row.exempt_note}`);
  }
  if (report.noLoss) lines.push('', ...noLossLines(report.noLoss));
  return `${lines.join('\n')}\n`;
}

// The no-loss rule, in the CI log. It says which tree it compared against, what it
// compared, and either the parts that went backwards or the case that made it
// report instead of gate.
export function noLossLines(state) {
  const out = ['No-loss rule: instruction-class parts, base to head.'];
  // The sha this check READ from the base tree, never the one it was handed.
  // Printing the promise would assert a commit nothing verified.
  const read = state.base_head ? state.base_head.slice(0, 12) : 'a commit the tree does not name';
  const promised = state.base_sha ? `, named ${state.base_sha.slice(0, 12)} by the pull request` : '';
  out.push(`   base ${read} in ${state.base_dir}${promised}`);
  if (state.base_facts) out.push(`   scored both trees as kind ${state.base_facts.kind}, spec ${state.base_facts.spec}, from the base tree`);
  if (state.parts_compared) out.push(`   ${state.parts_compared} instruction-class part(s) were filled at the base`);
  for (const row of state.report_only) out.push(`   REPORT ONLY (${row.case}): ${row.why}`);
  for (const row of state.regressions) {
    out.push(`   BACKWARDS  ${row.label}: ${row.was} at the base, ${row.now} at the head`);
    for (const finding of row.findings ?? []) out.push(`       - ${finding}`);
  }
  if (!state.regressions.length && state.base_facts) out.push('   no instruction-class part went backwards');
  if (!state.gates) {
    out.push('   this no-loss rule reports and does not gate on this pull request');
    // The loudest line in the report, and the one a reader must not miss. The
    // frozen text excuses these five cases because a person merges every file
    // that causes one. That is a compensating control, not an absence of
    // findings, so the findings are said out loud beside the green.
    if (state.regressions.length) {
      out.push(`   WARNING: ${state.regressions.length} part(s) above went backwards and this job is NOT red for them.`);
      out.push('   A person merges this pull request. Read the BACKWARDS lines before you do.');
    }
  }
  return out;
}

export function toMarkdown(report) {
  const out = ['## Atlas repo shape', '', headline(report), ''];
  if (report.errors.length) {
    out.push('### Errors', '');
    for (const error of report.errors) out.push(`- ${error}`);
    out.push('');
  }
  for (const file of report.files) {
    out.push(`### ${file.number}. ${file.title}`, '', '| Part | Needed | State | Findings |', '|---|---|---|---|');
    for (const part of file.parts) out.push(`| \`${label(part)}\` | ${part.required} | ${part.state} | ${part.findings.map((finding) => finding.replaceAll('|', '\\|')).join('; ') || '—'} |`);
    out.push('');
  }
  const instruction = report.by_reference.filter((row) => !row.exempt);
  out.push('### By reference', '', `${instruction.length} file(s) under \`docs/\` are named by an instruction file. They are instruction class too.`, '');
  if (report.by_reference.length) {
    out.push('| Path | On disk | Named by | Instruction class |', '|---|---|---|---|');
    for (const row of report.by_reference) {
      out.push(`| \`${row.path}\` | ${row.exists ? 'yes' : 'no'} | ${row.pointed_at_by.map((path) => `\`${path}\``).join(', ') || '—'} | ${row.exempt ? `no — ${row.exempt_note}` : 'yes'} |`);
    }
    out.push('');
  }
  if (report.noLoss) {
    out.push('### The no-loss rule', '');
    for (const line of noLossLines(report.noLoss).slice(1)) out.push(`- ${line.trim()}`);
    out.push('');
  }
  return `${out.join('\n')}\n`;
}

// Two things can turn the job red, and they answer different questions.
//
// `fail-on` answers "is this repository finished?" over the whole-repository
// count. It keeps its three levels and it stays a report line at the shipped
// level.
//
// The no-loss rule answers "did this pull request take something away?" It is the
// one that can be true on a repository with debt, so it is checked first.
export function verdict(report, failOn) {
  if (report.errors.length) return { green: false, why: `the check hit ${report.errors.length} error(s)` };
  const state = report.noLoss;
  if (state?.gates && state.regressions.length) {
    return { green: false, why: `${state.regressions.length} instruction-class part(s) went backwards against the base: ${state.regressions.map((row) => row.label).join(', ')}` };
  }
  if (failOn === 'required' && report.counts.required_not_filled) return { green: false, why: `${report.counts.required_not_filled} required file(s) are not filled` };
  if (failOn === 'any' && report.counts.not_filled) return { green: false, why: `${report.counts.not_filled} file(s) are not filled` };
  const excused = state && !state.gates && state.regressions.length
    ? ` — WARNING: ${state.regressions.length} part(s) went backwards and were NOT gated; a person merges this one`
    : '';
  const noLossWhy = state ? (state.gates ? '; no instruction-class part went backwards' : `; the no-loss rule reported and did not gate (${state.report_only.map((row) => row.case).join(', ')})${excused}`) : '';
  return { green: true, why: `${report.counts.required_not_filled} required file(s) are not filled; fail-on is "${failOn}"${noLossWhy}` };
}

// ---------------------------------------------------------------------------
// The command line.
// ---------------------------------------------------------------------------

export const FAIL_ON = Object.freeze(['error', 'required', 'any']);
export const EXTRACTORS = Object.freeze([]); // Slice L3 adds routes, migrations and mcp.

export function parseArguments(argv) {
  const out = { root: process.cwd(), failOn: 'error', json: null, summary: null, quiet: false, base: null, baseSha: null };
  for (let index = 0; index < argv.length; index += 1) {
    const flag = argv[index];
    const next = () => { const value = argv[index + 1]; if (value === undefined) throw new Error(`${flag} needs a value`); index += 1; return value; };
    if (flag === '--root') out.root = resolve(next());
    else if (flag === '--fail-on') out.failOn = next();
    else if (flag === '--json') out.json = resolve(next());
    else if (flag === '--summary') out.summary = resolve(next());
    else if (flag === '--quiet') out.quiet = true;
    // The no-loss rule's two inputs. `--base` is the directory the workflow checked
    // the base commit out into. `--base-sha` is the pull request's base.sha, so
    // the check can say the tree it reads is the tree it was promised.
    else if (flag === '--base') out.base = resolve(next());
    else if (flag === '--base-sha') out.baseSha = next().trim() || null;
    else if (flag === '--repo') out.repo = next();
    else if (flag === '--version') out.version = true;
    else throw new Error(`unknown argument ${flag}`);
  }
  if (!FAIL_ON.includes(out.failOn)) throw new Error(`--fail-on must be one of ${FAIL_ON.join(', ')}`);
  return out;
}

export function run(argv, env = process.env) {
  const options = parseArguments(argv);
  const repoId = options.repo ?? env.GITHUB_REPOSITORY ?? null;
  const patterns = secretPatterns();
  const report = scan({ root: options.root, repoId, extractors: EXTRACTORS, secretPatterns: patterns });
  // No `--base` means no pull request to measure: a push build, or a run by
  // hand. The no-loss rule then does not run at all, and the report says nothing
  // about it rather than claiming a pass.
  report.noLoss = options.base
    ? noLoss({ headRoot: options.root, baseRoot: options.base, baseSha: options.baseSha, repoId, secretPatterns: patterns })
    : null;
  const decision = verdict(report, options.failOn);
  const text = toText(report);
  if (options.json) writeFileSync(options.json, `${JSON.stringify({ ...report, fail_on: options.failOn, green: decision.green }, null, 2)}\n`);
  if (options.summary) writeFileSync(options.summary, toMarkdown(report));
  if (env.GITHUB_STEP_SUMMARY) appendFileSync(env.GITHUB_STEP_SUMMARY, toMarkdown(report));
  if (env.GITHUB_OUTPUT) appendFileSync(env.GITHUB_OUTPUT, `not-filled=${report.counts.not_filled}\nrequired-not-filled=${report.counts.required_not_filled}\nkind=${report.kind ?? ''}\ngreen=${decision.green}\n`);
  return { report, decision, text, options };
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try {
    // --version is parsed like every other flag, so an unknown flag beside it
    // is still refused (acceptance review of batch 14b, finding 11).
    const asked = parseArguments(process.argv.slice(2));
    if (asked.version) {
      process.stdout.write(`atlas repo-shape check, check version ${CHECK_VERSION}; it reads spec ${Object.keys(SPECS).join(', ')}\n`);
    } else {
      const { decision, text, options } = run(process.argv.slice(2));
      if (!options.quiet) process.stdout.write(text);
      process.stdout.write(`${decision.green ? 'GREEN' : 'RED'}: ${decision.why}\n`);
      process.exitCode = decision.green ? 0 : 1;
    }
  } catch (error) {
    process.stderr.write(`atlas repo-shape check: ${error.message}\n`);
    process.exitCode = 2;
  }
}
