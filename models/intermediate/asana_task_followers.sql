with task_follower as (
    
    select *
    from {{ ref('stg_asana_task_follower') }}

),

user as (

    select * 
    from {{ ref('stg_asana_user') }}

),

agg_followers as (

    select
        task_follower.task_id,
        string_agg( concat("'", user.user_name, "'"), ", " ) as followers
    from task_follower 
    join user 
        on user.user_id=task_follower.user_id
    group by 1
    
)

select * from agg_followers