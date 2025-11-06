{{ config(enabled=var('asana__using_task_tags', True)) }}

{{
    asana.asana_union_connections(
        connection_dictionary='asana_sources',
        single_source_name='asana',
        single_table_name='task_tag'
    )
}}