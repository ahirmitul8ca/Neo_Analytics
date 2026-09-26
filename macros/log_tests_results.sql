{% macro log_test_results(results) %}
  
  {%- set test_results = [] -%}
  
  {# Filter results to only process data test executions #}
  {%- for res in results if res.node.resource_type == 'test' -%}
    {%- set execution_time = res.execution_time | round(4) -%}
    {%- set rows_affected = res.adapter_response.get('rows_affected', 0) if res.adapter_response else 0 -%}
    
    {%- do test_results.append({
        'test_name': res.node.name,
        'model_tested': res.node.attached_node if res.node.attached_node else 'N/A',
        'status': res.status,
        'execution_time_seconds': execution_time,
        'failures_detected': rows_affected,
        'test_type': res.node.config.get('materialized', 'test'),
        'executed_at': run_started_at.strftime('%Y-%m-%d %H:%M:%S')
    }) -%}
  {%- endfor -%}

  {# Write records to BigQuery if any tests were run #}
  {%- if test_results | length > 0 -%}
    
    {# Fully dynamic database/project and schema/dataset target references #}
    {% set target_project = target.project %}
    {% set target_dataset = target.schema ~ '_dbt_test_audit' %}
    {% set target_table = 'audit_test_history' %}
    
    {% set audit_table_ref %}
      `{{ target_project }}`.`{{ target_dataset }}`.`{{ target_table }}`
    {% endset %}

    {# Ensure the audit history table exists dynamically in BigQuery #}
    {% set create_table_query %}
      create table if not exists {{ audit_table_ref }} (
        test_name string,
        model_tested string,
        status string,
        execution_time_seconds numeric,
        failures_detected int64,
        test_type string,
        executed_at timestamp
      );
    {% endset %}

    {% do run_query(create_table_query) %}

    {# Insert execution logs into audit_test_history #}
    {% set insert_query %}
      insert into {{ audit_table_ref }} (
        test_name,
        model_tested,
        status,
        execution_time_seconds,
        failures_detected,
        test_type,
        executed_at
      )
      values
      {% for row in test_results %}
        (
          '{{ row.test_name }}',
          '{{ row.model_tested }}',
          '{{ row.status }}',
          {{ row.execution_time_seconds }},
          {{ row.failures_detected }},
          '{{ row.test_type }}',
          timestamp('{{ row.executed_at }}')
        ){% if not loop.last %},{% endif %}
      {% endfor %};
    {% endset %}

    {% do run_query(insert_query) %}
    {% do log("Successfully logged " ~ test_results | length ~ " test results to " ~ audit_table_ref, info=True) %}

  {%- endif -%}

{% endmacro %}