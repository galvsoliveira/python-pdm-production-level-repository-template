#!/bin/bash

if [ ! -f pyproject.toml ]; then
    echo 'Creating pyproject.toml ...'
    pdm init
    pdm add --group dev pre-commit detect-secrets ruff mypy types-python-dateutil
    pdm add python-dotenv
    pdm self add pdm-dotenv
    pdm install
fi

if [ ! -f .secrets.baseline ]; then
    echo 'Creating .secrets.baseline ...'
    pdm run detect-secrets scan > .secrets.baseline
fi

if [ ! -f .pre-commit-config.yaml ]; then
    echo 'Creating .pre-commit-config.yaml ...'
    pdm run cat > .pre-commit-config.yaml << EOF
---
fail_fast: true
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: check-case-conflict
      - id: detect-private-key
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
        args: [--maxkb=500]
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ["--baseline", ".secrets.baseline"]
        exclude: package.lock.json
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.15
    hooks:
      - id: ruff
        args: [--fix, --exit-non-zero-on-fix, --show-fixes]
      - id: ruff-format
  - repo: https://github.com/pre-commit/mirrors-prettier
    rev: v4.0.0-alpha.8
    hooks:
      - id: prettier
        files: \.(js|ts|jsx|tsx|css|less|html|json|markdown|md|yaml|yml)$
  - repo: https://github.com/hadolint/hadolint
    rev: v2.12.1-beta
    hooks:
      - id: hadolint-docker
  - repo: https://github.com/PyCQA/isort
    rev: 5.13.2
    hooks:
      - id: isort
        args: [--profile=black]
  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.8.0
    hooks:
      - id: mypy
        args: [--strict, --ignore-missing-imports]
        language: python
        additional_dependencies:
          [
            pdm,
            types-PyYAML,
            alembic,
            types-python-dateutil,
            types-requests,
            types-certifi,
          ]
  - repo: https://github.com/pdm-project/pdm
    rev: 2.12.3
    hooks:
      - id: pdm-export
        args: ["-o", "requirements.txt", "--without-hashes", "--prod"]
        files: ^pdm.lock$
      - id: pdm-lock-check
      - id: pdm-sync
        additional_dependencies:
          - keyring
  - repo: https://github.com/sqlfluff/sqlfluff
    rev: 2.3.2
    hooks:
      - id: sqlfluff-lint
        name: sqlfluff-lint
        # args: [--dialect, sqlite]
        # additional_dependencies:
        #   ['dbt-sqlite==1.4.0', 'sqlfluff-templater-dbt==2.3.0']
EOF
fi

echo 'Installing dependencies and pre-commit ...'
pdm run git config --local --unset-all core.hooksPath
pdm install
pdm run pre-commit install
pdm run pre-commit autoupdate