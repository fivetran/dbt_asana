
# Asana dbt Package ([Docs](https://fivetran.github.io/dbt_asana/))

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

## What does this dbt package do?

- Produces modeled tables that leverage Asana data from [Fivetran's connector](https://fivetran.com/docs/applications/asana) in the format described by [this ERD](https://fivetran.com/docs/applications/asana#schemainformation).

- Enhances the task, users, projects, teams, and tags tables. Each of these tables is enriched with metrics that reflect the volume and breadth of current work and also the velocity of completed work.
- Provides a daily metrics table, which lays out a timeline of task creations and completions to show the overall pace of deliverables.
- Generates a comprehensive data dictionary of your source and modeled Asana data through the [dbt docs site](https://fivetran.github.io/dbt_asana/).

<!--section=“asana_transformation_model"-->
The following table provides a detailed list of all tables materialized within this package by default.
> TIP: See more details about these tables in the package's [dbt docs site](https://fivetran.github.io/dbt_asana/#!/overview?g_v=1&g_e=seeds).

| **Table**                | **Description**                                                                                                                                |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| [asana__task](https://fivetran.github.io/dbt_asana/#!/model/model.asana.asana__task)             | Each record represents an Asana task, enriched with data about its assignee, projects, sections, tasks, teams, tags, parent task, comments, followers, and activity. |
| [asana__user](https://fivetran.github.io/dbt_asana/#!/model/model.asana.asana__user)             | Each record represents an Asana user, enriched with metrics about their completed tasks, open tasks, and the projects they work on. Also includes data about the user's most recently completed task and their next due task. |
| [asana__project](https://fivetran.github.io/dbt_asana/#!/model/model.asana.asana__project)          | Each record represents an Asana project, enriched with metrics about their completed tasks, open tasks, and the users involved in the project. Also includes data about the project's most recently completed task and next due tasks. |
| [asana__team](https://fivetran.github.io/dbt_asana/#!/model/model.asana.asana__team)             | Each record represents an Asana team, enriched with data about their completed tasks, open tasks, their projects, and the users involved with the team. |
| [asana__tag](https://fivetran.github.io/dbt_asana/#!/model/model.asana.asana__tag)              | Each record represents an Asana tag, enriched with metrics about open and completed tasks associated with the tag. |
| [asana__daily_metrics](https://fivetran.github.io/dbt_asana/#!/model/model.asana.asana__daily_metrics)    | Each record represents a single day, enriched with metrics about tasks opened at created that day. |

### Materialized Models
Each Quickstart transformation job run materializes 28 models if all components of this data model are enabled. This count includes all staging, intermediate, and final models materialized as `view`, `table`, or `incremental`.
<!--section-end-->
## How do I use the dbt package?
### Step 1: Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran Asana connection syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, or **Databricks** destination.

### Step 2: Install the package
Include the following asana package version in your `packages.yml` file.
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions, or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yaml
packages:
  - package: fivetran/asana
    version: [">=1.2.0", "<1.3.0"] # we recommend using ranges to capture non-breaking changes automatically
```
> All required sources and staging models are now bundled into this transformation package. Do not include `fivetran/asana_source` in your `packages.yml` since this package has been deprecated.

### Step 3: Define database and schema variables

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

> **Note**: If there are source tables you do not have (see [Step 4](https://github.com/fivetran/dbt_asana?tab=readme-ov-file#step-4-disable-models-for-non-existent-sources)), you may still include them, as long as you have set the right variables to `False`.

2. Set the `has_defined_sources` variable (scoped to the `asana` package) to `True`, like such:
```yml
# dbt_project.yml
vars:
  asana:
    has_defined_sources: true
```

### Step 4: Enabling/Disabling Models

Your Asana connection might not sync every table that this package expects. If your syncs exclude certain tables, it is either because you do not use that functionality in Asana or have actively excluded some tables from your syncs. In order to enable or disable the relevant tables in the package, you will need to add the following variable(s) to your `dbt_project.yml` file.

By default, all variables are assumed to be `true`.

```yml
vars:
    asana__using_tags: false                # default is true
    asana__using_task_tags: false           # default is true
```

### (Optional) Step 5: Additional configurations
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

### (Optional) Step 6: Orchestrate your models with Fivetran Transformations for dbt Core™
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
## How is this package maintained and can I contribute?
### Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/asana/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_asana/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package.

## Are there any resources available?
- If you have questions or want to reach out for help, see the [GitHub Issue](https://github.com/fivetran/dbt_asana/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
