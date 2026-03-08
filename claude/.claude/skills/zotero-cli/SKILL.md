---
name: zotero-cli
description: Interact with the local Zotero library using the `zotero` CLI tool. Use when the user asks to search, browse, create, update, or delete Zotero items, collections, or tags, or asks to manage their Zotero library directly.
user-invocable: false
allowed-tools: Bash
---

# zotero CLI

`zotero` reads and writes the Zotero SQLite database directly — no Zotero API key or running Zotero instance required for reads.

Default DB path: `~/Zotero/zotero.sqlite`. Override with `--db <path>` or the `ZOTERO_DB_PATH` env var.

## IMPORTANT: Write Operations Require Zotero to Be Closed

**Before any write operation** (create, update, delete, add-to-collection, remove-from-collection, create-collection, rename-collection, delete-collection, add-tag, remove-tag, delete-tags), **ask the user to quit the Zotero desktop app**. Writing while Zotero is open risks database corruption and will cause Zotero to overwrite your changes on next sync.

Read operations (items, item, children, doi, collections, collection, collection-items, tags, item-tags, fulltext-search, fulltext-stats, item-types, fields) are safe while Zotero is running.

---

## Global Options

```bash
zotero --db <path>   # override DB path
zotero --json        # JSON output (overrides subcommand default)
zotero --version
```

---

## Items

### List items

```bash
zotero items
zotero items --type journalArticle
zotero items --collection <collectionKey>
zotero items --tag "machine learning"
zotero items --tag "ml" --tag "deep learning"   # AND: both tags required
zotero items --query "transformer"               # search in field values
zotero items --limit 50 --offset 100            # pagination
zotero items --count                             # count only, no listing
zotero items --json
```

### Get a single item

```bash
zotero item <key>
zotero item <key> --json
```

### Get child items (attachments, notes, annotations)

```bash
zotero children <key>
zotero children <key> --json
```

### Look up by DOI

```bash
zotero doi 10.1038/nature12373
zotero doi 10.1038/nature12373 --json
```

### List valid item types

```bash
zotero item-types
zotero item-types --json
```

### List valid fields for an item type

```bash
zotero fields journalArticle
zotero fields book --json
```

---

## Creating and Modifying Items

> **Close Zotero before running these commands.**

### Create an item

```bash
zotero create --type journalArticle \
  --field "title=Attention Is All You Need" \
  --field "date=2017" \
  --field "publicationTitle=NeurIPS" \
  --field "DOI=10.48550/arXiv.1706.03762" \
  --creator "author:Ashish:Vaswani" \
  --creator "author:Noam:Shazeer" \
  --tag "deep learning" \
  --tag "transformers" \
  --collection <collectionKey>
```

Creator format: `type:firstName:lastName` where type is `author`, `editor`, `translator`, etc.
Repeat `--field`, `--creator`, `--tag`, `--collection` for multiple values.

### Update an item

```bash
zotero update <key> --field "title=New Title"
zotero update <key> --field "date=2024" --field "url=https://example.com"
zotero update <key> --creator "author:Jane:Doe"   # replaces ALL creators
zotero update <key> --add-tag "reviewed" --remove-tag "inbox"
zotero update <key> --json
```

Note: `--creator` replaces all existing creators. Omit it to leave creators unchanged.

### Delete an item

```bash
zotero delete <key>       # prompts for confirmation
zotero delete <key> --yes # skip confirmation
```

Deletion cascades all related data (attachments metadata, tags, collection membership). Zotero will sync the deletion on next launch.

---

## Collections

### List all collections

```bash
zotero collections
zotero collections --limit 500
zotero collections --json
```

Output shows hierarchy with indentation: nested collections are indented under their parent.

### Get a single collection

```bash
zotero collection <key>
zotero collection <key> --json
```

### List items in a collection

```bash
zotero collection-items <key>
zotero collection-items <key> --type journalArticle
zotero collection-items <key> --query "neural"
zotero collection-items <key> --limit 50
zotero collection-items <key> --json
```

### Manage collection membership

> **Close Zotero before running these commands.**

```bash
zotero add-to-collection <itemKey> <collectionKey>
zotero remove-from-collection <itemKey> <collectionKey>
```

### Create, rename, delete collections

> **Close Zotero before running these commands.**

```bash
zotero create-collection "New Collection"
zotero create-collection "Sub-collection" --parent <parentKey>  # nested
zotero create-collection "My Collection" --json

zotero rename-collection <key> "Better Name"
zotero rename-collection <key> "Better Name" --json

zotero delete-collection <key>        # prompts for confirmation
zotero delete-collection <key> --yes  # skip confirmation
```

Note: `delete-collection` removes the collection only; items inside are NOT deleted.

---

## Tags

### List all tags

```bash
zotero tags
zotero tags --collection <collectionKey>   # tags within a specific collection
zotero tags --json
```

### List tags on a specific item

```bash
zotero item-tags <key>
zotero item-tags <key> --json
```

### Add or remove a tag on an item

> **Close Zotero before running these commands.**

```bash
zotero add-tag <itemKey> <tag>
zotero remove-tag <itemKey> <tag>
```

### Delete tags from the entire library

> **Close Zotero before running these commands.**

```bash
zotero delete-tags "inbox" "to-read"    # removes these tags from all items
zotero delete-tags "inbox" --yes        # skip confirmation
```

---

## Full-Text Search

```bash
zotero fulltext-search "transformer attention"
zotero fulltext-search "climate change" --limit 20
zotero fulltext-search "neural network" --json
```

Searches extracted text content of PDF attachments. Returns attachment items; use `zotero item <parentKey>` to get the parent bibliographic record.

### Full-text indexing stats for an attachment

```bash
zotero fulltext-stats <attachmentKey>
zotero fulltext-stats <attachmentKey> --json
```

---

## Common Workflows

### Find a paper and inspect it

```bash
zotero items --query "vaswani attention"
zotero item <key>
zotero children <key>       # see PDFs/notes
```

### Add a paper to a collection

```bash
# First find the item key and collection key
zotero items --query "paper title" --json
zotero collections --json

# Then add (close Zotero first)
zotero add-to-collection <itemKey> <collectionKey>
```

### Bulk-tag items in a collection

```bash
# List items in collection, then add tag to each
zotero collection-items <collectionKey> --json | jq -r '.[].key' | \
  xargs -I{} zotero add-tag {} "reviewed"
```

### Create a nested collection hierarchy

```bash
# Close Zotero first
zotero create-collection "Finance" --json               # note the returned key
zotero create-collection "Equities" --parent <financeKey>
zotero create-collection "Fixed Income" --parent <financeKey>
```

---

## Usage Notes

- Item `key` is an 8-character uppercase alphanumeric string (e.g. `A1B2C3D4`).
- Use `--json` when piping output to `jq` or other tools for programmatic processing.
- To discover valid item types and their fields before creating an item, run `zotero item-types` then `zotero fields <type>`.
- `zotero items --count` is fast for checking result size before paginating through a large set.
- Full-text search requires PDFs to be indexed by Zotero beforehand.
