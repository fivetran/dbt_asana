
with base as (

    select * 
    from {{ ref('stg_asana__project_task_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_asana__project_task_tmp')),
                staging_columns=get_project_task_columns()
            )
        }}
        {{ asana.apply_source_relation() }}

    from base
),

final as (
    
    select
        source_relation,
        project_id,
        task_id
    from fields
)

select * 
from final
