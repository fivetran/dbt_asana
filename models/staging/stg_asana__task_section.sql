
with base as (

    select * 
    from {{ ref('stg_asana__task_section_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_asana__task_section_tmp')),
                staging_columns=get_task_section_columns()
            )
        }}
        {{ asana.apply_source_relation() }}

    from base
),

final as (
    
    select
        source_relation,
        section_id,
        task_id
    from fields
)

select * 
from final
