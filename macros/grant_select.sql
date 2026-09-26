{% macro grant_select(schema=target.schema, role='roles/bigquery.dataViewer') %}
    {% set sql %}
        grant `{{ role }}` on schema `{{ target.project }}`.`{{ schema }}` to "analytics-team@example.com";
    {% endset %}
    {% do run_query(sql) %}
    {% do log("Granted " ~ role ~ " on " ~ schema, info=True) %}
{% endmacro %}