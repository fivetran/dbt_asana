
with base as (

    select * 
    from {{ ref('stg_asana__user_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_asana__user_tmp')),
                staging_columns=get_user_columns()
            )
        }}
        {{ asana.apply_source_relation() }}

    from base
),

final as (
    
    select
        source_relation,
        id as user_id,
        email,
        name as user_name
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select * 
from final
