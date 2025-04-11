#!/bin/bash
export LC_ALL=c.
archivo="ventas.csv"
declare -A Productos

function productos_mas_vendido() {
    echo "Top 10 productos más vendidos:"
    while IFS=";" read -r producto cantidad; do
        # verificar que la cantidad sea un número
        if [[ $cantidad =~ ^[0-9]+$ ]]; then
            # Sumar la cantidad al producto existente o inicializarlo
            Productos["$producto"]=$(( ${Productos["$producto"]} + cantidad ))
        fi
    done < <(cut -d';' -f 1,6 "$archivo")

     #Ordenar y mostrar los 10 productos más vendidos
    for producto in "${!Productos[@]}"; do
        
        echo "${Productos[$producto]} $producto"
    done | sort -nr | head -n 10
}

# productos_mas_vendido



declare -A Clientes
function ingresos_por_clientes() {
    echo "Total de ingresos por clientes:"

    # Leer el archivo y llenar el arreglo
   while IFS=";" read -r cliente ingreso; do
    # Validar ingreso con grep
    
        valor_actual=${Clientes["$cliente"]} #Guarda el ingreso actual del cliente desde el array
        if [[ -z "$valor_actual" ]]; then #verificar si la variable valor_actual está vacía
            valor_actual=0
        fi
        nuevo_total=$(awk "BEGIN {print $valor_actual + $ingreso}")
        Clientes["$cliente"]=$nuevo_total # Guardar el nuevo total en el array Clientes
    
done < <(cut -d';' -f 3,8 "$archivo") ## Tomar solo la columna 3 y 8


    # Mostrar ingresos por cliente ordenados alfabéticamente
    for cliente in "${!Clientes[@]}"; do # recorrer el arreglo Clientes
        printf "%s: %.2f\n" "$cliente" "${Clientes[$cliente]}"
    done | sort #Mostar los nombres de los clientes por orden alfabético
}

ingresos_por_clientes



