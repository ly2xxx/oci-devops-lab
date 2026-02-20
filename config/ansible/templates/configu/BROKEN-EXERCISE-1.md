# ⚠️ Exercise 1 - BROKEN

**Status:** Not functional as of 2026-02-20

## Issues Discovered

### Configu CLI Version Incompatibilities
- **v1.3.0:** Uses `--assign` for key-value pairs
- **v1.4.x-1.5.x:** Uses `-l` / `--from-literal`
- **v1.5.0:** json-file store broken (missing package.json in cache)

### What Doesn't Work
- JSON file store (`--store ./stores/config.json`) - cache errors
- Export from noop store - no persistence between commands
- Tutorial flag syntax - varies by version

### Time Wasted
~2 hours debugging what should be a 30-minute exercise

## Recommendation
**Skip this exercise.** The concepts (schemas, validation, export) are standard config management patterns you likely already know.

## Alternative
If config management is needed, use:
- Plain environment variables + .env files
- Python: `python-dotenv` + Pydantic for validation
- Simple bash scripts with validation

---

**Note to future self:** Test exercises before including them in labs.
