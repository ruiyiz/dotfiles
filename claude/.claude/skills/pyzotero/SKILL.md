---
name: pyzotero
description: Use the pyzotero CLI to search and query a local Zotero library. Use when the user asks to search their Zotero library, find papers, list collections, look up DOIs, or explore Zotero data.
user-invocable: false
allowed-tools: Bash
---

# Pyzotero CLI

`pyzotero` is a CLI for querying a local Zotero library via Zotero's local API. It requires **Zotero 7 to be running** with local API access enabled (Zotero > Settings > Advanced > "Allow other applications on this computer to communicate with Zotero"). No API key or library ID is needed.

Install with `uv add "pyzotero[cli]"` or run without installing via `uvx --from "pyzotero[cli]" pyzotero <command>`.

## Connection

```bash
pyzotero test
```

Verifies Zotero is running and accepting local connections. Run this if other commands fail unexpectedly.

## Search

```bash
pyzotero search -q "machine learning"
pyzotero search -q "climate change" --fulltext        # include PDF content
pyzotero search -q "topic" --itemtype journalArticle  # filter by type
pyzotero search -q "topic" --itemtype book --itemtype journalArticle  # OR types
pyzotero search --collection ABC123 -q "test"         # within a collection
pyzotero search -q "topic" --tag "climate" --tag "adaptation"  # AND tags
pyzotero search -q "topic" --limit 20 --offset 0     # pagination
pyzotero search -q "topic" --json                     # JSON output
```

**`--fulltext`** expands search to PDF attachment content and automatically returns the parent bibliographic items (not the raw attachment records).

Default text output includes: title, authors, date, publication, volume, issue, DOI, URL, key, PDF attachment paths.

`--json` output shape: `{ "count": N, "items": [ { "key", "itemType", "title", "creators", "date", "publication", "volume", "issue", "doi", "url", "pdfAttachments" }, ... ] }`

## Item Lookup

```bash
pyzotero item ABC123          # single item by key
pyzotero item ABC123 --json

pyzotero subset ABC123 DEF456 GHI789  # up to 50 items in one call
pyzotero subset ABC123 DEF456 --json
```

## Children (Attachments & Notes)

```bash
pyzotero children ABC123       # get attachments/notes for an item
pyzotero children ABC123 --json
```

## Full-Text Content

```bash
pyzotero fulltext ABC123       # get extracted text from a PDF attachment key
```

Output: `{ "content": "...", "indexedPages": N, "totalPages": N }`

Note: `key` must be an **attachment** key, not a top-level item key. Use `pyzotero children` first to find attachment keys.

## Collections

```bash
pyzotero listcollections
pyzotero listcollections --limit 10
```

Output: JSON array of `{ "id", "name", "items", "parent": { "id", "name" } | null }`

Use `"id"` values as the `--collection` argument in `search`.

## Tags

```bash
pyzotero tags
pyzotero tags --collection ABC123
pyzotero tags --json
```

## DOI Lookup

```bash
# Look up specific DOIs (checks if they're in the library)
pyzotero alldoi 10.1234/example
pyzotero alldoi 10.1234/abc https://doi.org/10.5678/def doi:10.9012/ghi
pyzotero alldoi 10.1234/example --json

# Build a complete DOI-to-key index (cacheable)
pyzotero doiindex
pyzotero doiindex > doi_cache.json
```

`alldoi` JSON output: `{ "found": [{ "doi", "key" }], "not_found": ["..."] }`

`doiindex` JSON output: `{ "10.1234/abc": { "key": "ABC123", "original": "https://doi.org/10.1234/ABC" }, ... }`

DOI matching is case-insensitive and strips `https://doi.org/`, `http://doi.org/`, `doi:` prefixes automatically.

## Item Types

```bash
pyzotero itemtypes    # list all valid Zotero item type strings
```

## Semantic Scholar Integration

These commands hit the Semantic Scholar API and by default cross-check results against the local Zotero library.

```bash
# Find semantically similar papers (SPECTER2 embeddings)
pyzotero related --doi "10.1038/nature12373"
pyzotero related --doi "10.1038/nature12373" --limit 50 --min-citations 100

# Find papers citing a given paper
pyzotero citations --doi "10.1038/nature12373"
pyzotero citations --doi "10.1038/nature12373" --limit 50 --min-citations 50

# Find papers referenced by a given paper
pyzotero references --doi "10.1038/nature12373"
pyzotero references --doi "10.1038/nature12373" --min-citations 100

# Search Semantic Scholar's index
pyzotero s2search -q "climate adaptation"
pyzotero s2search -q "machine learning" --year 2020-2024
pyzotero s2search -q "neural networks" --open-access --limit 50
pyzotero s2search -q "deep learning" --sort citations --min-citations 100

# Skip library check for faster results
pyzotero related --doi "..." --no-check-library
```

Semantic Scholar output JSON shape: `{ "count": N, "papers": [ { "title", "authors", "year", "doi", "citationCount", "in_library": bool, "zotero_key": "..." | null }, ... ] }`

## Global Options

```bash
pyzotero --locale fr-FR search -q "..."   # localized item type strings
pyzotero --version
```

## Usage Notes

- Always check `pyzotero test` if commands fail with connection errors.
- Use `--json` when piping output to other tools or scripts.
- `pyzotero doiindex` is expensive (full library scan) but cacheable; prefer `pyzotero alldoi` for one-off DOI lookups.
- `pyzotero subset` is far more efficient than multiple `item` calls for batch key lookups (up to 50 per call).
- Full-text search is slower than metadata-only search since it fetches parent items for matched attachments.
