with comments as (

    select *
    from {{ ref('int_asana__task_story') }}
    where comment_content is not null
    order by source_relation, target_task_id, created_at asc

),

task_conversation as (

    select
        source_relation,
        target_task_id as task_id,
        -- creates a chronologically ordered conversation about the task
        {{ fivetran_utils.string_agg( "created_at || '  -  ' || created_by_name || ':  ' || comment_content", "'\\n'" ) }} as conversation,
        count(*) as number_of_comments

    from comments
    group by 1, 2
)

select * from task_conversation
