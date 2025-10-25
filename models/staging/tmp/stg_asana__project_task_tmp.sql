{{
    asana.asana_union_connections(
        connection_dictionary=var('asana_sources'),
        single_source_name='asana',
        single_table_name='project_task',
        default_identifier='project_task'
    )
}}
