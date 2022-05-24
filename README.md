[![Apache License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
# Asana ([docs](https://fivetran-dbt-asana.netlify.app/#!/overview))

This package models Asana data from [Fivetran's connector](https://fivetran.com/docs/applications/asana). It uses data in the format described by [this ERD](https://fivetran.com/docs/applications/asana#schemainformation).

This package enables you to better understand tasks and how they're being worked on in Asana. Its primary focus is to enhance the task table and other core objects that relate to tasks: users, projects, teams, and tags. Each of these objects is enriched with metrics that reflect the volume and breadth of work being done now and the velocity of work that has been completed. Moreover, the daily metrics table lays out a timeline of task creations and completions for understanding the overall pace of deliverables at the organization.

> The Asana dbt package is compatible with BigQuery, Redshift, and Snowflake.

## Models

This package contains transformation models, designed to work simultaneously with our [Asana source package](https://github.com/fivetran/dbt_asana_source). A dependency on the source package is declared in this package's `packages.yml` file, so it will automatically download when you run `dbt deps`. The primary outputs of this package are described below. Intermediate models are used to create these output models.

| **model**                | **description**                                                                                                                                |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| [asana__task](https://github.com/fivetran/dbt_asana/blob/master/models/asana__task.sql)             | Each record represents an Asana task, enriched with data about its assignee, projects, sections, tasks, teams, tags, parent task, comments, followers, and activity. |      
| [asana__user](https://github.com/fivetran/dbt_asana/blob/master/models/asana__user.sql)             | Each record represents an Asana user, enriched with metrics about their completed tasks, open tasks, and the projects they work on. Also includes data about the user's most recently completed task and their next due task. |
| [asana_project](https://github.com/fivetran/dbt_asana/blob/master/models/asana__project.sql)          | Each record represents an Asana project, enriched with metrics about their completed tasks, open tasks, and the users involved in the project. Also includes data about the project's most recently completed task and next due tasks. |
| [asana__team](https://github.com/fivetran/dbt_asana/blob/master/models/asana__team.sql)             | Each record represents an Asana team, enriched with data about their completed tasks, open tasks, their projects, and the users involved with the team. |
| [asana__tag](https://github.com/fivetran/dbt_asana/blob/master/models/asana__tag.sql)              | Each record represents an Asana tag, enriched with metrics about open and completed tasks associated with the tag. |
| [asana__daily_metrics](https://github.com/fivetran/dbt_asana/blob/master/models/asana__daily_metrics.sql)    | Each record represents a single day, enriched with metrics about tasks opened at created that day. |


## Installation Instructions
Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions, or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

Include in your `packages.yml`

```yaml
packages:
  - package: fivetran/asana
    version: [">=0.5.0", "<0.6.0"]
```

## Configuration
By default, this package will look for your Asana data in the `asana` schema of your [target database](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/configure-your-profile). If this is not where your Asana data is, please add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

...
config-version: 2

vars:
  asana_source:
    asana_database: your_database_name
    asana_schema: your_schema_name 
```
### Changing the Build Schema
By default this package will build the Asana staging models within a schema titled (<target_schema> + `_stg_asana`) and the Asana final models with a schema titled (<target_schema> + `_asana`) in your target database. If this is not where you would like your modeled Asana data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

...
models:
  asana:
    +schema: my_new_schema_name # leave blank for just the target_schema
  asana_source:
    +schema: my_new_schema_name # leave blank for just the target_schema
```

This package allows users to include additional columns to the source task table.  To do this, include any additional columns to the `asana_source` pass-through variables to ensure the downstream columns are present.

```yml
# dbt_project.yml

...
vars:
  asana_source:
    task_pass_through_columns: [custom_status, custom_department]
```

## Database support
This package is compatible with BigQuery, Snowflake, and Redshift.

## Contributions

Additional contributions to this package are very welcome! Please create issues
or open PRs against `main`. Check out 
[this post](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) 
on the best workflow for contributing to a package.

## Resources:
- Provide [feedback](https://www.surveymonkey.com/r/DQ7K7WW) on our existing dbt packages or what you'd like to see next
- Have questions, feedback, or need help? Book a time during our office hours [using Calendly](https://calendly.com/fivetran-solutions-team/fivetran-solutions-team-office-hours) or email us at solutions@fivetran.com
- Find all of Fivetran's pre-built dbt packages in our [dbt hub](https://hub.getdbt.com/fivetran/)
- Learn how to orchestrate your models with [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt)
- Learn more about Fivetran overall [in our docs](https://fivetran.com/docs)
- Check out [Fivetran's blog](https://fivetran.com/blog)
- Learn more about dbt [in the dbt docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](http://slack.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the dbt blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
