with story as (

    select *
    from {{ ref('asana_task_story') }}
),

user as (

    select *
    from {{ var('user') }}
),

ordered_stories as (

    select 
        target_task_id,
        created_by_user_id,
        created_at,
        row_number() over ( partition by target_task_id order by created_at asc ) as nth_story
        
    from story
    where created_by_user_id is not null -- sometimes user id can be null in story. limit to ones with associated users

),

first_modification as (

    select  
        target_task_id as task_id,
        created_by_user_id as first_modifier_user_id

    from ordered_stories 
    where nth_story = 1
),

-- grabbing the user name
first_modifier as (
    
    select 
        first_modification.task_id,
        first_modification.first_modifier_user_id,
        user.user_name as first_modifier_name
    
    from first_modification
    join user 
        on first_modification.first_modifier_user_id = user.user_id
)

select *
from first_modifier