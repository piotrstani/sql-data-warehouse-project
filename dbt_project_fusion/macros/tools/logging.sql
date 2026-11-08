{% macro learn_log() %}
    --wyswietalenie w konsoli:  info=True
    {{ log("\n--------------------------------------------Hello there!---------------------------------------\n", info=True) }}
    --
    {# log("\n--------------------------------------------Hello there!---------------------------------------\n", info=True) #}
    SELECT 1;
 {% endmacro %}