# dbt_asana v0.6.0
🛠 Deprecated columns fix 🛠
## 🚨 Breaking Changes 🚨
- As per our Release Notes for the Asana connector, we have updated the `dbt_asana_source` package to remove deprecated columns from the Task table (https://fivetran.com/docs/applications/asana/changelog#june2021) - please refer to the June 2021 and March 2021 release notes. The following columns have been deprecated from the Task table:
  - `assingee_status`
  - `hearted` - the `liked` column has been added to replace hearted
  - `num_hearts` - the `num_likes` column has been added to replace num_hearts
Please be sure to update your queries.

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
