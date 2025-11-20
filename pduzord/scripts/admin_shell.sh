#!/bin/bash

DATA="data/sample_data.csv"
CONFIG="config/racks.conf"
LOGDIR="logs"
SCRIPTDIR="scripts"
MONITOR="$SCRIPTDIR/main_monitor.tcl"

function show_menu {
    echo "==== SHELL DE ADMINISTRADOR DE RED ===="
    echo "1) Ver estados eléctricos en tiempo real"
    echo "2) Mostrar configuración de racks"
    echo "3) Comparar racks y sugerir acciones"
    echo "4) Mostrar logs actuales"
    echo "5) Recomendar ajustes para desempeño de red"
    echo "6) Ejecutar monitoreo TCL (main_monitor.tcl)"
    echo "7) Ejecutar chequeo manual de un rack"
    echo "8) Recargar configuración"
    echo "0) Salir"
    echo "======================================="
}

function show_realtime {
    echo "Estados eléctricos en tiempo real:"
    tail -n 8 "$DATA" | awk -F, '{printf "%-8s | %5.1f A | %4d V | %2d %% | %s\n", $2, $3, $4, $5, $6}'
}

function show_config {
    echo "Configuración de racks:"
    grep '^RACK' "$CONFIG" | awk -F, '{printf "%-8s | IP: %-15s | Capacidad: %2dA | Perfil: %s\n", $1, $2, $3, $4}'
}

function compare_racks {
    echo "Comparación entre racks (estado actual):"
    tail -n 8 "$DATA" | awk -F, '{
      alert = ($5>=90) ? "CRITICO" : ($5>=70) ? "ALTO" : "OK";
      printf "%-8s | %5.1f A (%2d%%) | %s\n", $2, $3, $5, alert;
    }'
}

function show_logs {
    echo "Eventos recientes:"
    tail -n 10 "$LOGDIR/log_$(date +%Y-%m-%d).txt"
}

function recommend_network_performance {
    echo "Recomendaciones automáticas:"
    echo "- Si el consumo de un rack supera el 90%, podrían generarse sobrevoltajes momentáneos afectando switches sensibles."
    echo "- El ancho de banda y disponibilidad de servicio puede verse degradada por reinicios de equipos ante sobrecarga eléctrica."
    echo "- Priorizar racks CORE para recuperación ante fallos eléctricos: evite apagarlos automáticamente."
    echo "- Considere la segmentación de cargas y puesta en marcha de switches solo cuando la corriente esté bajo umbral WARN."
    echo "- Revise las caídas frecuentes en los logs: pueden indicar mala distribución eléctrica que está limitando el tráfico de la red."
}

function run_monitor {
    echo "Ejecutando monitoreo TCL ($MONITOR)..."
    tclsh "$MONITOR"
    echo "-----"
}

function run_rack_check {
    read -p "Ingrese el nombre del rack a chequear (ej: RACK1): " rackname
    tclsh "$SCRIPTDIR/main_monitor.tcl" $rackname
    echo "-----"
}

function reload_config {
    echo "Recargando parámetros de configuración (simulación)..."
    sleep 1
    echo "Configuraciones recargadas."
}

while true; do
    show_menu
    read -p "Seleccione una opción: " opt
    case $opt in
        1) show_realtime ;;
        2) show_config ;;
        3) compare_racks ;;
        4) show_logs ;;
        5) recommend_network_performance ;;
        6) run_monitor ;;
        7) run_rack_check ;;
        8) reload_config ;;
        0) break ;;
        *) echo "Opción no válida" ;;
    esac
    echo ""
done

echo "Fin de la shell administrativa."
