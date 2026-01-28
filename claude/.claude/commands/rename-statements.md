# Rename Financial Statements

Scan the current directory for PDF financial statements and rename them using a consistent naming convention.

## Naming Convention

**Pattern:** `{Institution}_{AccountType}_{Owner}_{Period}.pdf`

- **Institution:** Single word (Fidelity, IBKR, Chase, Merrill, Wealthfront, Schwab, ETrade, Invest529, 1607Capital)
- **AccountType:** Brief descriptor (Brokerage, TraditionalIRA, RothIRA, RolloverIRA, 401k, Lease, 529, PrivateFund)
- **Owner:** First name (Ruiyi, Qifan, Joint) - for 529 plans, use beneficiary name instead (Angela, Daphne)
- **Period:** YYYY-MM for monthly, YYYY for annual, YYYY-Q# for quarterly

## Known Account Mappings

| Account Identifier | Institution | Account Type | Owner |
|---|---|---|---|
| U1464955 | IBKR | TraditionalIRA | Ruiyi |
| U1289377 | IBKR | Brokerage | Ruiyi |
| U1799362 | IBKR | RolloverIRA | Qifan |
| U2024861 | IBKR | RothIRA | Qifan |
| 1891-4083 | Schwab | 401k | Ruiyi |
| 8W352779 | Wealthfront | Brokerage | Joint |
| XXXXX225 / CMAEdge | Merrill | Brokerage | Joint |
| 8817 | ETrade | Brokerage | Qifan |

## Workflow

1. List all PDF files in the current directory
2. Read each PDF to identify: institution, account type, owner, and statement period
3. Use the naming convention and known mappings to determine the new filename
4. Present a rename mapping table for review before executing
5. After user approval, execute the renames
6. Verify with a final directory listing

## Examples

| Original | Renamed |
|---|---|
| Statement12312025.pdf | Fidelity_Brokerage_Qifan_2025-12.pdf |
| U1464955.2025.pdf | IBKR_TraditionalIRA_Ruiyi_2025.pdf |
| STATEMENT_2025-12_8W352779_*.pdf | Wealthfront_Brokerage_Joint_2025-12.pdf |
| ClientStatements_8817_123125.pdf | ETrade_Brokerage_Qifan_2025-12.pdf |
| Brokerage Statement_2025-12-31_083.PDF | Schwab_401k_Ruiyi_2025-12.pdf |

## Notes

- For 529 plans (Invest529), the naming uses beneficiary name as the "account type" position: `Invest529_Angela_Ruiyi_2025-Q4.pdf`
- If multiple statements exist for the same account/period, append `_2`, `_3`, etc.
- Always confirm the mapping with the user before renaming
