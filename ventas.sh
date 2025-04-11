#!/bin/bash
export LC_ALL=c
archivo="ventas.csv"
reporte="Reporte.txt"

# Función para mostrar los 10 productos más vendidos
declare -A Productos
function productos_mas_vendido() {
    echo "      TOP 10 PRODUCTOS MÁS VENDIDOS:" | tee -a "$reporte" 
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
    done | sort -nr | head -n 10 | tee -a "$reporte" 
}

# Función para mostrar la lista de ingresos por clientes
declare -A Clientes
function ingresos_por_clientes() {
    echo "     TOTAL DE INGRESOS POR CLIENTES:" | tee -a "$reporte"

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
    done | sort | tee -a "$reporte"  #Mostar los nombres de los clientes por orden alfabético
}

# Función para mostrar los ingresos por departamentos
declare -A Departamentos
function ingresos_por_departamentos(){
    {
    read 
    while IFS=";" read -r producto categoria cliente depto fecha cantidad precio ingreso; do
        if [[ -n "$depto" && -n "$ingreso" ]]; then
            #Suma
            Departamentos["$depto"]=$(awk "BEGIN {print ${Departamentos["$depto"]:-0} + $ingreso}")
        fi
        done
    } < "$archivo"

#reporte
echo "       REPORTE DE INGRESOS POR DEPARTAMENTO"    | tee -a "$reporte"

for depto in "${!Departamentos[@]}"; do
    printf "%s: %.2f\n" "$depto" "${Departamentos[$depto]}"
done | LC_ALL=C sort | tee -a "$reporte"
}


#Opciones 
while true; do
    echo "-----------------------------------------------------------------"
    echo "\n¿ Qué te gustaría obtener?"
    echo "-----------------------------------------------------------------"
    echo "1) Obtenga el TOP 10 de los productos más vendidos"
    echo "2) Total, de ingresos por categoría"
    echo "3) Total, de ingresos por mes"
    echo "4) Total, de ingresos por clientes"
    echo "5) Total, de ingresos por departamento"
    echo "6) Salir"
    
    read -p "Seleccione una opción: " opcion
    case $opcion in
        1) productos_mas_vendido ;;
        2) ;;
        3)  ;;
        4) ingresos_por_clientes ;;
        5) ingresos_por_departamentos ;;
        6) echo "Saliendo..."; exit ;;
        *) echo "Opción no válida" ;;
    esac
done
