# AGENTS.md

## Overview
This repository contains an R package. This document defines guidelines for automated agents and contributors performing maintenance tasks such as updating dependencies, fixing checks, and improving documentation.

Agents should prioritize **stability, reproducibility, and CRAN compliance**.

---

## Core Principles

- Keep the package R CMD check clean (no errors, warnings, or notes where possible)
- Maintain backward compatibility unless explicitly instructed otherwise
- Prefer minimal, targeted changes
- Follow existing code style and structure
- Do not introduce breaking API changes without clear justification
- Do not modify package scope or purpose

---

## Repository Structure

Typical layout:

R/              # Function definitions  
man/            # Documentation (.Rd files)  
tests/          # Unit tests (testthat)  
vignettes/      # Long-form documentation  
DESCRIPTION     # Package metadata and dependencies  
NAMESPACE       # Exported functions  

---

## Common Tasks

### Fix R CMD Check Issues

Run:

devtools::check()

Address in priority order:

1. Errors
2. Warnings
3. Notes (especially CRAN-related)

---

### Update Documentation

- Ensure all exported functions have roxygen2 comments
- Regenerate docs:

devtools::document()

---

### Dependency Management

- Add dependencies to DESCRIPTION under Imports or Suggests
- Avoid unnecessary dependencies

---

### Testing

- Use testthat
- Add tests for new features and bug fixes

Run:

devtools::test()

---

### Code Style

- Follow existing style
- Prefer snake_case
- Keep functions small and focused

---

### Version Bumping

- Patch: 0.1.0 → 0.1.1
- Minor: 0.1.0 → 0.2.0
- Major: 0.1.0 → 1.0.0

---

### Continuous Integration

- Ensure all checks pass before merging

---

## CRAN Considerations

Run:

devtools::check(cran = TRUE)

---

## Useful Commands

devtools::check()  
devtools::test()  
devtools::document()  
devtools::install()  
devtools::check(cran = TRUE)

---

## Final Notes

- Prefer incremental improvements  
- Choose least invasive changes  
- Always verify with R CMD check  
