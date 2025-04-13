#!/bin/bash

export LC_ALL=C
export LANG=en_US.UTF-8

archivo="/workspaces/ProyectoFinal/ventas.csv"
reporte="/workspaces/ProyectoFinal/cron_reporte.txt"
log="/workspaces/ProyectoFinal/log.txt"

> "$reporte"

declare -A Productos
declare -A Categorias
declare -A Meses
declare -A Clientes
declare -A Departamentos

monto_total_anual=0

{
    read
    while IFS=";" read -r producto categoria cliente depto fecha cantidad precio ingreso; do
   
        Productos["$producto"]=$(( ${Productos["$producto"]:-0} + cantidad ))

        Categorias["$categoria"]=$(awk "BEGIN {print ${Categorias["$categoria"]:-0} + $ingreso}")

        IFS='/' read -ra FECHA <<< "$fecha"
        mes=$(printf "%04d-%02d" "${FECHA[2]}" "${FECHA[1]}")
        Meses["$mes"]=$(awk "BEGIN {print ${Meses["$mes"]:-0} + $ingreso}")

        Clientes["$cliente"]=$(awk "BEGIN {print ${Clientes["$cliente"]:-0} + $ingreso}")

        Departamentos["$depto"]=$(awk "BEGIN {print ${Departamentos["$depto"]:-0} + $ingreso}")

        monto_total_anual=$(awk "BEGIN {print $monto_total_anual + $ingreso}")
    done
} < "$archivo"

producto_mas_vendido=$(for p in "${!Productos[@]}"; do echo "${Productos[$p]} $p"; done | sort -nr | head -n1 | awk '{$1=""; print substr($0,2)}')

cliente_mas_frecuente=$(for c in "${!Clientes[@]}"; do echo "${Clientes[$c]} $c"; done | sort -nr | head -n1 | awk '{$1=""; print substr($0,2)}')

{
    echo "============================================"
    echo "           REPORTE DE VENTAS"
    echo "============================================"
    echo ""
    echo " TOP 10 PRODUCTOS MÁS VENDIDOS:"
    for p in "${!Productos[@]}"; do echo "${Productos[$p]} $p"; done | sort -nr | head -n10
    echo ""
    echo " TOTAL DE INGRESOS POR CATEGORÍA:"
    for c in "${!Categorias[@]}"; do printf "%s: %.2f\n" "$c" "${Categorias[$c]}"; done | sort
    echo ""
    echo " TOTAL DE INGRESOS POR MES:"
    for m in "${!Meses[@]}"; do printf "%s: %.2f\n" "$m" "${Meses[$m]}"; done | sort
    echo ""
    echo " TOTAL DE INGRESOS POR CLIENTE:"
    for cli in "${!Clientes[@]}"; do printf "%s: %.2f\n" "$cli" "${Clientes[$cli]}"; done | sort
    echo ""
    echo " TOTAL DE INGRESOS POR DEPARTAMENTO:"
    for d in "${!Departamentos[@]}"; do printf "%s: %.2f\n" "$d" "${Departamentos[$d]}"; done | sort
    echo ""
    echo " Producto más vendido: $producto_mas_vendido"
    echo " Monto total anual: $monto_total_anual"
    echo " Cliente con mayor ingreso: $cliente_mas_frecuente"
    echo ""
    echo "============================================"
    echo "      REPORTE GENERADO CORRECTAMENTE"
    echo "============================================"
} >> "$reporte"
