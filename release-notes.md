# Changelog

## [0.4.0] - 2024-04-22

### 🚀 Features

- Add cursor based incremental refresh (#40)
- Support for cursor field during syncs config (#43)
- Support cron expression in sync api (#66)

### 🐛 Bug Fixes

- Changed color for disabled Pagination button and cursor type (#42)
- Add query_type in connector protocol
- Remove salesforce default cursor
- Sync creation process (#48)
- Source_defined_cursor default value to false in stream
- Add source_defined_cursor in catalog
- Salesforce consumer goods cloud schema helper picklist type (#54)
- Salesforce query offset removed (#57)
- Add cursor-based exit condition in BatchQuery (#58)
- Remove \n from rendered liquid template data
- Add greater than zero validation for sync_interval (#61)
- Update apply button condition for template mapping (#62)
- Remove default cursor field from catalog (#63)
- Update scheduler type for manual interval (#67)

### Refactor

- Models finalize screen (#68)

<!-- generated by git-cliff -->
