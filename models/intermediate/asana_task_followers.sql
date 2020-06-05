with task_follower as (
    
    select *
    from {{ ref('stg_asana_task_follower') }}

)
-- add user name
select * from task_follower