# Attack-machine

Organized toolkit for subdomain enumeration and related utilities.

## Repository Structure

```
Attack-machine/
├── scripts/                 # Executable scripts (bash)
│   ├── hassan.sh
│   ├── subenum.sh
│   └── subfinder2.sh
├── docs/                    # Documentation and guides
│   └── DOMAIN_TO_FILE_README.md
├── outputs/                 # Generated output files (*.txt)
├── .gitignore
├── .gitattributes
└── README.md
```

## Quick Start

1) Subdomain enumeration (examples):

```bash
bash scripts/subenum.sh --domain example.com --out outputs
```

2) Check HTTP status of enumerated subdomains (from outputs):

```bash
# Example using httpx (requires installation)
httpx -l outputs/subs_unique.txt -silent -status-code
```

## Notes

- Place any generated .txt results into `outputs/` to keep the repo clean.
- Add any new documentation to `docs/`.
- Put any new scripts into `scripts/` and make them executable on Unix systems.
