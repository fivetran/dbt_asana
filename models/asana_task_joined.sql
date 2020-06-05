with tasks as (
    select *
    from {{ ref('stg_asana_task') }}
),

task_comments as (

    select * 
    from {{ref('asana_task_comments')}}
),

