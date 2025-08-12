# dbt_asana v0.10.0
[PR #43](https://github.com/fivetran/dbt_asana/pull/43) includes the following updates:

### dbt Fusion Compatibility Updates
- Updated package to maintain compatibility with dbt-core versions both before and after v1.10.6, which introduced a breaking change to multi-argument test syntax (e.g., `unique_combination_of_columns`).
- Temporarily removed unsupported tests to avoid errors and ensure smoother upgrades across different dbt-core versions. These tests will be reintroduced once a safe migration path is available.
  - Removed all `dbt_utils.unique_combination_of_columns` tests.
  - Removed all `accepted_values` tests.
  - Moved `loaded_at_field: _fivetran_synced` under the `config:` block in `src_asana.yml`.

# dbt_asana v0.9.0
[PR #40](https://github.com/fivetran/dbt_asana/pull/40) includes the following updates:

## Breaking Change for dbt Core < 1.9.6

> *Note: This is not relevant to Fivetran Quickstart users.*

Migrated `freshness` from a top-level source property to a source `config` in alignment with [recent updates](https://github.com/dbt-labs/dbt-core/issues/11506) from dbt Core ([Asana Source v0.9.0](https://github.com/fivetran/dbt_asana_source/releases/tag/v0.9.0)). This will resolve the following deprecation warning that users running dbt >= 1.9.6 may have received:

```
[WARNING]: Deprecated functionality
Found `freshness` as a top-level property of `asana` in file
`models/src_asana.yml`. The `freshness` top-level property should be moved
into the `config` of `asana`.
```

**IMPORTANT:** Users running dbt Core < 1.9.6 will not be able to utilize freshness tests in this release or any subsequent releases, as older versions of dbt will not recognize freshness as a source `config` and therefore not run the tests.

If you are using dbt Core < 1.9.6 and want to continue running Asana freshness tests, please elect **one** of the following options:
  1. (Recommended) Upgrade to dbt Core >= 1.9.6
  2. Do not upgrade your installed version of the `asana` package. Pin your dependency on v0.8.3 in your `packages.yml` file.
  3. Utilize a dbt [override](https://docs.getdbt.com/reference/resource-properties/overrides) to overwrite the package's `asana` source and apply freshness via the previous release top-level property route. This will require you to copy and paste the entirety of the previous release `src_asana.yml` file and add an `overrides: asana_source` property.

## Under the Hood
- Updates to ensure integration tests use latest version of dbt.

# dbt_asana v0.8.3
[PR #39](https://github.com/fivetran/dbt_asana/pull/39) includes the following updates:

## Under the Hood
- Fixed `asana__using_tags` and `asana__using_task_tags` in the `quickstart.yml` configuration to ensure that, when their source tables are not selected, these variables are set to false and the below changes in v0.8.2 are applied in Quickstart.

# dbt_asana v0.8.2
This release will introduce the following changes: 

## Feature Updates
- Introduces variables `asana__using_tags` and `asana__using_task_tags` to allow the `tag` and `task_tag` source tables to be disabled. By default, these variables are set to True. ([#37](https://github.com/fivetran/dbt_asana/pull/37))
- This will disable the tables `int_asana__task_tags` and `asana__tag` if either of the variables are set to False. This allows the downstream models to run even if the respective source `tag` and `task_tag` tables don't exist. ([#37](https://github.com/fivetran/dbt_asana/pull/37)) 
- This will exclude the fields `tags` and `number_of_tags` in `asana__task` if either of the variables are set to false.
- For more information on how to configure these variables, refer to the [README](https://github.com/fivetran/dbt_asana/blob/main/README.md#step-4-enablingdisabling-models). ([#37](https://github.com/fivetran/dbt_asana/pull/37))

## Under the Hood
- Added `asana__using_tags` and `asana__using_task_tags` to the `quickstart.yml` configuration to ensure when these source tables are not selected, these variables are set to false and the above changes are applied in Quickstart. ([#37](https://github.com/fivetran/dbt_asana/pull/37))
- Added False configurations for `asana__using_tags` and `asana__using_task_tags` to our Buildkite `run_models.sh` script. ([#37](https://github.com/fivetran/dbt_asana/pull/37))
- Added consistency tests within `integration_tests` to ensure no unexpected row changes occur in the `asana__tag` and `asana_task` models in development. ([#37](https://github.com/fivetran/dbt_asana/pull/37))

## Documentation
- Added Quickstart model counts to README. ([#35](https://github.com/fivetran/dbt_asana/pull/35))
- Corrected references to connectors and connections in the README. ([#35](https://github.com/fivetran/dbt_asana/pull/35))

# dbt_asana v0.8.1
[PR #29](https://github.com/fivetran/dbt_asana/pull/29) includes the following updates:
## 🎉 Feature Update 🎉
- Updated `int_asana__task_projects` to create the following new columns that are brought into `asana__task`. These new fields provide additional insight into your tasks.
  - project_ids
  - project_names
  - number_of_projects
- Note `project_ids` and `project_names` are aggregated lists of all ids/names associated with the task. You can parse or explode the items in the list using a comma + space (`", "`) as a delimiter. To keep the table grain at the task_id level, this list is not parsed by default.
  - See also [our documentation](https://fivetran.github.io/dbt_asana/#!/overview). 

## Contributors
- [@irvingpop](https://github.com/irvingpop ) ([PR #25](https://github.com/fivetran/dbt_asana/pull/25))

# dbt_asana v0.8.0
## 🎉 Feature Update 🎉
- Databricks compatibility! ([#28](https://github.com/fivetran/dbt_asana/pull/28))

## 🚘 Under the Hood 🚘
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job. ([#26](https://github.com/fivetran/dbt_asana/pull/26))
- Updated the pull request [templates](/.github). ([#26](https://github.com/fivetran/dbt_asana/pull/26))

# dbt_asana v0.7.0

## 🚨 Breaking Changes 🚨:
[PR #23](https://github.com/fivetran/dbt_asana/pull/23) includes the following breaking changes:
- Dispatch update for dbt-utils to dbt-core cross-db macros migration. Specifically `{{ dbt_utils.<macro> }}` have been updated to `{{ dbt.<macro> }}` for the below macros:
    - `any_value`
    - `bool_or`
    - `cast_bool_to_text`
    - `concat`
    - `date_trunc`
    - `dateadd`
    - `datediff`
    - `escape_single_quotes`
    - `except`
    - `hash`
    - `intersect`
    - `last_day`
    - `length`
    - `listagg`
    - `position`
    - `replace`
    - `right`
    - `safe_cast`
    - `split_part`
    - `string_literal`
    - `type_bigint`
    - `type_float`
    - `type_int`
    - `type_numeric`
    - `type_string`
    - `type_timestamp`
    - `array_append`
    - `array_concat`
    - `array_construct`
- For `current_timestamp` and `current_timestamp_in_utc` macros, the dispatch AND the macro names have been updated to the below, respectively:
    - `dbt.current_timestamp_backcompat`
    - `dbt.current_timestamp_in_utc_backcompat`
- `dbt_utils.surrogate_key` has also been updated to `dbt_utils.generate_surrogate_key`. Since the method for creating surrogate keys differ, we suggest all users do a `full-refresh` for the most accurate data. For more information, please refer to dbt-utils [release notes](https://github.com/dbt-labs/dbt-utils/releases) for this update.
- Dependencies on `fivetran/fivetran_utils` have been upgraded, previously `[">=0.3.0", "<0.4.0"]` now `[">=0.4.0", "<0.5.0"]`.

# dbt_asana v0.6.0
🛠 Deprecated columns fix 🛠
## 🚨 Breaking Changes 🚨
- As per our [Release Notes](https://fivetran.com/docs/applications/asana/changelog#june2021) for the Asana connector, we have updated the `dbt_asana_source` package to remove deprecated columns from the Task table - please refer to the June 2021 and March 2021 release notes. The following columns have been deprecated from the Task table:
  - `assignee_status`
  - `hearted` - the `liked` column has been added to replace hearted
  - `num_hearts` - the `num_likes` column has been added to replace num_hearts
Please be sure to update your queries.

## 🎉 Features 🎉
PR [#19](https://github.com/fivetran/dbt_asana/pull/19) introduced the following updates.
- PostgreSQL compatibility 
- Updated README for enhanced user experience

## Contributors
- @fivetran-poonamagate ([#21](https://github.com/fivetran/dbt_asana_source/pull/21)).

# dbt_asana v0.5.0
🎉 dbt v1.0.0 Compatibility 🎉
## 🚨 Breaking Changes 🚨
- Adjusts the `require-dbt-version` to now be within the range [">=1.0.0", "<2.0.0"]. Additionally, the package has been updated for dbt v1.0.0 compatibility. If you are using a dbt version <1.0.0, you will need to upgrade in order to leverage the latest version of the package.
  - For help upgrading your package, I recommend reviewing this GitHub repo's Release Notes on what changes have been implemented since your last upgrade.
  - For help upgrading your dbt project to dbt v1.0.0, I recommend reviewing dbt-labs [upgrading to 1.0.0 docs](https://docs.getdbt.com/docs/guides/migration-guide/upgrading-to-1-0-0) for more details on what changes must be made.
- Upgrades the package dependency to refer to the latest `dbt_asana_source`. Additionally, the latest `dbt_asana_source` package has a dependency on the latest `dbt_fivetran_utils`. Further, the latest `dbt_fivetran_utils` package also has a dependency on `dbt_utils` [">=0.8.0", "<0.9.0"].
  - Please note, if you are installing a version of `dbt_utils` in your `packages.yml` that is not in the range above then you will encounter a package dependency error.

# dbt_asana v0.1.0 -> v0.4.0
Refer to the relevant release notes on the Github repository for specific details for the previous releases. Thank you!