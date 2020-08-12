# Asana 

This package models Asana data from [Fivetran's connector](https://fivetran.com/docs/applications/asana). It uses data in the format described by [this ERD](https://docs.google.com/presentation/d/14m2L2aYGmt0IXseExR80FlEO-7fxjBKfoALR2jVh0G8/edit).

This package enables you to better understand tasks and how they're being worked on in Asana. Its primary focus is to enhance the task table and other core objects that relate to tasks: users, projects, teams, and tags. Each of these objects is enriched with metrics that reflect the volume and breadth of work being done now and the velocity of work that has been completed. Moreover, the daily metrics table lays out a timeline of task creations and completions for understanding the overall pace of deliverables at the organization.

## Models

This package contains transformation models, designed to work simultaneously with our [Asana source package](https://github.com/fivetran/dbt_asana_source). A dependency on the source package is declared in this package's `packages.yml` file, so it will automatically download when you run `dbt deps`. The primary outputs of this package are described below. Intermediate models are used to create these output models.

| **model**                | **description**                                                                                                                                |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| asana_task             | Each record represents an Asana task, enriched with data about its assignee, projects, sections, tasks, teams, tags, parent task, comments, followers, and activity. |      
| asana_user             | Each record represents an Asana user, enriched with metrics about their completed tasks, open tasks, and the projects they work on. Also includes data about the user's most recently completed task and their next due task. |
| asana_project          | Each record represents an Asana project, enriched with metrics about their completed tasks, open tasks, and the users involved in the project. Also includes data about the project's most recently completed task and next due tasks. |
| asana_team             | Each record represents an Asana team, enriched with data about their completed tasks, open tasks, their projects, and the users involved with the team. |
| asana_tag              | Each record represents an Asana tag, enriched with metrics about open and completed tasks associated with the tag. |
| asana_daily_metrics    | Each record represents a single day, enriched with metrics about tasks opened at created that day. |


## Installation Instructions
Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions, or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

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

## Contributions

Additional contributions to this package are very welcome! Please create issues
or open PRs against `master`. Check out 
[this post](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) 
on the best workflow for contributing to a package.

## Resources:
- Learn more about Fivetran [in the Fivetran docs](https://fivetran.com/docs)
- Check out [Fivetran's blog](https://fivetran.com/blog)
- Learn more about dbt [in the dbt docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](http://slack.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the dbt blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
