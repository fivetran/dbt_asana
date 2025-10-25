{{
    asana.asana_union_connections(
        connection_dictionary=var('asana_sources'),
        single_source_name='asana',
        single_table_name='project',
        default_identifier='project'
    )
}}
