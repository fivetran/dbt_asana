<!--section="asana_transformation_model"-->
# Asana dbt Package

<p align="left">
    <a alt="License"
        href="https://github.com/fivetran/dbt_asana/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0,_<3.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
    <a alt="Fivetran Quickstart Compatible"
        href="https://fivetran.com/docs/transformations/dbt/quickstart">
        <img src="https://img.shields.io/badge/Fivetran_Quickstart_Compatible%3F-yes-green.svg" /></a>
</p>

This dbt package transforms data from Fivetran's Asana connector into analytics-ready tables.

## Resources

- Number of materialized models¹: 28
- Connector documentation
  - [Asana connector documentation](https://fivetran.com/docs/connectors/applications/asana)
  - [Asana ERD](https://fivetran.com/docs/connectors/applications/asana#schemainformation)
- dbt package documentation
  - [GitHub repository](https://github.com/fivetran/dbt_asana)
  - [dbt Docs](https://fivetran.github.io/dbt_asana/#!/overview)
  - [DAG](https://fivetran.github.io/dbt_asana/#!/overview?g_v=1)
  - [Changelog](https://github.com/fivetran/dbt_asana/blob/main/CHANGELOG.md)

## What does this dbt package do?
This package enables you to enhance task, user, project, team, and tag tables with metrics and provide daily metrics for task tracking. It creates enriched models with metrics focused on work volume, breadth, and velocity.

### Output schema
Final output tables are generated in the following target schema:

```
<your_database>.<connector/schema_name>_asana
```

### Final output tables

By default, this package materializes the following final tables:

| Table | Description |
| :---- | :---- |
| [asana__task](https://fivetran.github.io/dbt_asana/#!/model/model.asana.asana__task) | Provides comprehensive task-level data including assignments, due dates, completion status, project associations, and custom field values to track work progress and team productivity. <br></br>**Example Analytics Questions:**<ul><li>Which tasks are overdue or at risk of missing their due dates?</li><li>How many tasks are assigned to each team member and what is their completion rate?</li><li>What custom field values correlate with faster task completion times?</li></ul>|
| [asana__user](https://fivetran.github.io/dbt_asana/#!/model/model.asana.asana__user) | Summarizes user activity and workload including assigned tasks, created tasks, completion metrics, and project involvement to understand individual productivity and capacity. <br></br>**Example Analytics Questions:**<ul><li>Which users have the highest task completion rates and productivity metrics?</li><li>What is the current workload (open tasks) for each team member?</li><li>How many tasks has each user created versus completed over time?</li></ul>|
| [asana__project](https://fivetran.github.io/dbt_asana/#!/model/model.asana.asana__project) | Tracks all Asana projects with completion metrics, ownership details, and privacy settings to understand project status, workload distribution, and team organization. <br></br>**Example Analytics Questions:**<ul><li>Which projects have the most open tasks and longest completion times?</li><li>How are projects distributed across teams and owners?</li><li>What is the ratio of completed to total tasks for each active project?</li></ul>|
| [asana__team](https://fivetran.github.io/dbt_asana/#!/model/model.asana.asana__team) | Tracks team-level metrics including total tasks, completion rates, and project counts to monitor team performance and workload balance across the organization. <br></br>**Example Analytics Questions:**<ul><li>Which teams have the highest task volumes and completion rates?</li><li>How are projects and tasks distributed across different teams?</li><li>What is the average task completion time for each team?</li></ul>|
| [asana__tag](https://fivetran.github.io/dbt_asana/#!/model/model.asana.asana__tag) | Aggregates task metrics by tag to categorize work, track themes, and analyze patterns across projects using Asana's tagging system. <br></br>**Example Analytics Questions:**<ul><li>Which tags are associated with the most tasks and longest completion times?</li><li>How are tags distributed across different projects and teams?</li><li>What percentage of tasks with specific tags are completed on time?</li></ul>|
| [asana__daily_metrics](https://fivetran.github.io/dbt_asana/#!/model/model.asana.asana__daily_metrics) | Summarizes daily task activity including tasks created, completed, and overall team productivity to track workflow trends and identify peak productivity periods. <br></br>**Example Analytics Questions:**<ul><li>How many tasks are created versus completed each day across the organization?</li><li>What days of the week show the highest task creation and completion rates?</li><li>Are there daily patterns in task activity that could inform capacity planning?</li></ul>|

¹ Each Quickstart transformation job run materializes these models if all components of this data model are enabled. This count includes all staging, intermediate, and final models materialized as `view`, `table`, or `incremental`.

---

## Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran Asana connection syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, or **Databricks** destination.

## How do I use the dbt package?
You can either add this dbt package in the Fivetran dashboard or import it into your dbt project:

- To add the package in the Fivetran dashboard, follow our [Quickstart guide](https://fivetran.com/docs/transformations/data-models/quickstart-management).
- To add the package to your dbt project, follow the setup instructions in the dbt package's [README file](https://github.com/fivetran/dbt_asana/blob/main/README.md#how-do-i-use-the-dbt-package) to use this package.

<!--section-end-->

### Install the package
Include the following asana package version in your `packages.yml` file.
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions, or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yaml
packages:
  - package: fivetran/asana
    version: [">=1.3.0", "<1.4.0"] # we recommend using ranges to capture non-breaking changes automatically
```
> All required sources and staging models are now bundled into this transformation package. Do not include `fivetran/asana_source` in your `packages.yml` since this package has been deprecated.

### Define database and schema variables

#### Option A: Single connection
By default, this package runs using your [destination](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/configure-your-profile) and the `asana` schema. If this is not where your Asana data is (for example, if your Asana schema is named `asana_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
  asana:
    asana_database: your_database_name
    asana_schema: your_schema_name
```

#### Option B: Union multiple connections
If you have multiple Asana connections in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. For each source table, the package will union all of the data together and pass the unioned table into the transformations. The `source_relation` column in each model indicates the origin of each record.

To use this functionality, you will need to set the `asana_sources` variable in your root `dbt_project.yml` file:

```yml
# dbt_project.yml

vars:
  asana:
    asana_sources:
      - database: connection_1_destination_name # Required
        schema: connection_1_schema_name # Required
        name: connection_1_source_name # Required only if following the step in the following subsection

      - database: connection_2_destination_name
        schema: connection_2_schema_name
        name: connection_2_source_name
```

##### Recommended: Incorporate unioned sources into DAG
> *If you are running the package through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt#transformationsfordbtcore), the below step is necessary in order to synchronize model runs with your Asana connections. Alternatively, you may choose to run the package through Fivetran [Quickstart](https://fivetran.com/docs/transformations/quickstart), which would create separate sets of models for each Asana source rather than one set of unioned models.*

By default, this package defines one single-connection source, called `asana`, which will be disabled if you are unioning multiple connections. This means that your DAG will not include your Asana sources, though the package will run successfully.

To properly incorporate all of your Asana connections into your project's DAG:
1. Define each of your sources in a `.yml` file in the `models` directory of your project. Utilize the following template for the `source`-level configurations, and, **most importantly**, copy and paste the table and column-level definitions from the package's `src_asana.yml` [file](https://github.com/fivetran/dbt_asana/blob/main/models/staging/src_asana.yml).

```yml
# a .yml file in your root project

version: 2

sources:
  - name: <name> # ex: Should match name in asana_sources
    schema: <schema_name>
    database: <database_name>
    loader: fivetran
    config:
      loaded_at_field: _fivetran_synced
      freshness: # feel free to adjust to your liking
        warn_after: {count: 72, period: hour}
        error_after: {count: 168, period: hour}

    tables: # copy and paste from asana/models/staging/src_asana.yml - see https://support.atlassian.com/bitbucket-cloud/docs/yaml-anchors/ for how to use anchors to only do so once
```

> **Note**: If there are source tables you do not have (see [Enabling/Disabling Models](https://github.com/fivetran/dbt_asana?tab=readme-ov-file#step-4-disable-models-for-non-existent-sources)), you may still include them, as long as you have set the right variables to `False`.

2. Set the `has_defined_sources` variable (scoped to the `asana` package) to `True`, like such:
```yml
# dbt_project.yml
vars:
  asana:
    has_defined_sources: true
```

### Enabling/Disabling Models

Your Asana connection might not sync every table that this package expects. If your syncs exclude certain tables, it is either because you do not use that functionality in Asana or have actively excluded some tables from your syncs. In order to enable or disable the relevant tables in the package, you will need to add the following variable(s) to your `dbt_project.yml` file.

By default, all variables are assumed to be `true`.

```yml
vars:
    asana__using_tags: false                # default is true
    asana__using_task_tags: false           # default is true
```

### (Optional) Additional configurations
<details open><summary>Expand/Collapse details</summary>

#### Passing Through Additional Columns
This package allows users to include additional columns to the source task table.  To do this, include any additional columns to the pass-through variables to ensure the downstream columns are present.

```yml
vars:
  asana:
    task_pass_through_columns: [custom_status, custom_department]
```

#### Changing the Build Schema
By default this package will build the Asana staging models within a schema titled (<target_schema> + `_stg_asana`) and the Asana final models with a schema titled (<target_schema> + `_asana`) in your target database. If this is not where you would like your modeled Asana data to be written to, add the following configuration to your root `dbt_project.yml` file:

```yml
models:
    asana:
      +schema: my_new_schema_name # Leave +schema: blank to use the default target_schema.
      staging:
        +schema: my_new_schema_name # Leave +schema: blank to use the default target_schema.
```

#### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:

> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_asana/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
vars:
    asana_<default_source_table_name>_identifier: your_table_name 
```

</details>

### (Optional) Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for more details</summary>

Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).

</details>

## Does this package have dependencies?
This dbt package is dependent on the following dbt packages. These dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.

```yml
packages:
    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]
```

<!--section="asana_maintenance"-->
## How is this package maintained and can I contribute?

### Package Maintenance
The Fivetran team maintaining this package only maintains the [latest version](https://hub.getdbt.com/fivetran/asana/latest/) of the package. We highly recommend you stay consistent with the latest version of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_asana/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Learn how to contribute to a package in dbt's [Contributing to an external dbt package article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657).

<!--section-end-->

## Are there any resources available?
- If you have questions or want to reach out for help, see the [GitHub Issue](https://github.com/fivetran/dbt_asana/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).