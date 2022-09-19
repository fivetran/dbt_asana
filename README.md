<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_asana_source/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.0.0_<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
</p>

# Asana dbt Package ([Docs](https://fivetran.github.io/dbt_asana/))
# 📣 What does this dbt package do?

- Produces modeled tables that leverage Asana data from [Fivetran's connector](https://fivetran.com/docs/applications/asana) in the format described by [this ERD](https://fivetran.com/docs/applications/asana#schemainformation) and builds off of the output of our [Asana source package](https://github.com/fivetran/dbt_asana_source).

- Enhances the task, users, projects, teams, and tags tables. Each of these tables is enriched with metrics that reflect the volume and breadth of current work and also the velocity of completed work. 
- Provides a daily metrics table, which lays out a timeline of task creations and completions to show the overall pace of deliverables.
- Generates a comprehensive data dictionary of your source and modeled Asana data through the [dbt docs site](https://fivetran.github.io/dbt_asana/).
- These tables are designed to work simultaneously with our [Asana source package](https://github.com/fivetran/dbt_asana_source).

The following table provides a detailed list of all models materialized within this package by default. 
> TIP: See more details about these models in the package's [dbt docs site](https://fivetran.github.io/dbt_asana/#!/overview?g_v=1&g_e=seeds).

| **Model**                | **Description**                                                                                                                                |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| [asana__task](https://fivetran.github.io/dbt_asana/#!/model/model.asana.asana__task)             | Each record represents an Asana task, enriched with data about its assignee, projects, sections, tasks, teams, tags, parent task, comments, followers, and activity. |      
| [asana__user](https://fivetran.github.io/dbt_asana/#!/model/model.asana.asana__user)             | Each record represents an Asana user, enriched with metrics about their completed tasks, open tasks, and the projects they work on. Also includes data about the user's most recently completed task and their next due task. |
| [asana_project](https://fivetran.github.io/dbt_asana/#!/model/model.asana.asana__project)          | Each record represents an Asana project, enriched with metrics about their completed tasks, open tasks, and the users involved in the project. Also includes data about the project's most recently completed task and next due tasks. |
| [asana__team](https://fivetran.github.io/dbt_asana/#!/model/model.asana.asana__team)             | Each record represents an Asana team, enriched with data about their completed tasks, open tasks, their projects, and the users involved with the team. |
| [asana__tag](https://fivetran.github.io/dbt_asana/#!/model/model.asana.asana__tag)              | Each record represents an Asana tag, enriched with metrics about open and completed tasks associated with the tag. |
| [asana__daily_metrics](https://fivetran.github.io/dbt_asana/#!/model/model.asana.asana__daily_metrics)    | Each record represents a single day, enriched with metrics about tasks opened at created that day. |

# 🎯 How do I use the dbt package?
## Step 1: Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran Asana connector syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, or **PostgreSQL** destination.

## Step 2: Install the package
Include the following asana package version in your `packages.yml` file.
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions, or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yaml
packages:
  - package: fivetran/asana
    version: [">=0.6.0", "<0.7.0"]
```

## Step 3: Define database and schema variables
By default, this package runs using your [destination](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/configure-your-profile) and the `asana` schema. If this is not where your Asana data is (for example, if your Asana schema is named `asana_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
config-version: 2

vars:
  asana_source:
    asana_database: your_database_name
    asana_schema: your_schema_name 
```

## (Optional) Step 4: Additional configurations
<details><summary>Expand for configurations</summary>

### Passing Through Additional Columns 
This package allows users to include additional columns to the source task table.  To do this, include any additional columns to the `asana_source` pass-through variables to ensure the downstream columns are present.

```yml
vars:
  asana_source:
    task_pass_through_columns: [custom_status, custom_department]
```

### Changing the Build Schema
By default this package will build the Asana staging models within a schema titled (<target_schema> + `_stg_asana`) and the Asana final models with a schema titled (<target_schema> + `_asana`) in your target database. If this is not where you would like your modeled Asana data to be written to, add the following configuration to your root `dbt_project.yml` file:

```yml
models:
  asana:
    +schema: my_new_schema_name # leave blank for just the target_schema
  asana_source:
    +schema: my_new_schema_name # leave blank for just the target_schema
```

### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:

> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_asana_source/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
vars:
    asana_<default_source_table_name>_identifier: your_table_name 
```

</details>

## (Optional) Step 5: Orchestrate your models with Fivetran Transformations for dbt Core™    
<details><summary>Expand for more details</summary>

Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).

</details>

# 🔍 Does this package have dependencies?
This dbt package is dependent on the following dbt packages. Please be aware that these dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.

```yml
packages:
    - package: fivetran/asana_source
      version: [">=0.6.0", "<0.7.0"]

    - package: fivetran/fivetran_utils
      version: [">=0.3.0", "<0.4.0"]

    - package: dbt-labs/dbt_utils
      version: [">=0.8.0", "<0.9.0"]
```
# 🙌 How is this package maintained and can I contribute?
## Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/asana/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_asana/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

## Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions! 

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package!

# 🏪 Are there any resources available?
- If you have questions or want to reach out for help, please refer to the [GitHub Issue](https://github.com/fivetran/dbt_asana/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
- Have questions or just want to say hi? Book a time during our office hours [on Calendly](https://calendly.com/fivetran-solutions-team/fivetran-solutions-team-office-hours) or email us at solutions@fivetran.com.
