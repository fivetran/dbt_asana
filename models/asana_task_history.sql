with task as (

    select *
    from {{ var('task') }}
),

story as (
    
    select * 
    from {{ ref('asana_task_story') }}
),

task_history as (

    select 
        task.task_id,
        task.task_name,
        task.created_at as task_created_at,
        story.story_id as event_id,
        story.created_at as happened_at,
        story.created_by_user_id as done_by_user_id,
        story.created_by_name as done_by_user_name,
        action_taken,
        action_description,
        comment_content -- if it is not a comment, this is null

   from task
   join story on task.task_id = story.target_task_id
   
)

select * from task_history