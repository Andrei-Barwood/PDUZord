#!/usr/bin/env zsh
# monitor_test_perf.zsh
# Script auxiliar para monitorear el rendimiento de test_pduzord.zsh en tiempo real

PERF_LOG="/tmp/pduzord_test_perf.log"

echo "Monitoreando rendimiento de test_pduzord.zsh"
echo "Log: $PERF_LOG"
echo ""
echo "Ejecuta './test_pduzord.zsh' en otra terminal para ver los resultados aquí"
echo "Presiona Ctrl+C para salir"
echo ""
echo "=========================================="
echo ""

# Limpiar el log anterior
echo "" > "$PERF_LOG"

# Monitorear en tiempo real
tail -f "$PERF_LOG" 2>/dev/null || {
    echo "Esperando que el test inicie..."
    while [[ ! -f "$PERF_LOG" ]]; do
        sleep 0.1
    done
    tail -f "$PERF_LOG"
}

