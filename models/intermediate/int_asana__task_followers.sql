with task_follower as (
    
    select *
    from {{ ref('stg_asana__task_follower') }}

),

asana_user as (

    select * 
    from {{ ref('stg_asana__user') }}

),

agg_followers as (

    select
        task_follower.source_relation,
        task_follower.task_id,
        {{ fivetran_utils.string_agg( 'asana_user.user_name', "', '" )}} as followers,
        count(*) as number_of_followers
    from task_follower
    join asana_user
        on asana_user.user_id = task_follower.user_id
        and asana_user.source_relation = task_follower.source_relation
    group by 1, 2

)

select * from agg_followers