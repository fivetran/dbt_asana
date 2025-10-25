{% macro apply_source_relation() -%}

{{ adapter.dispatch('apply_source_relation', 'asana') () }}

{%- endmacro %}

{% macro default__apply_source_relation() -%}

{% if var('asana_sources', []) != [] %}
, _dbt_source_relation as source_relation
{% else %}
, '{{ var("asana_database", target.database) }}' || '.'|| '{{ var("asana_schema", "asana") }}' as source_relation
{% endif %}

{%- endmacro %}