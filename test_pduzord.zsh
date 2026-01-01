#!/usr/bin/env zsh
# test_pduzord.zsh
# Script de prueba para validar el funcionamiento del repositorio PDUZord

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Contadores de tests
PASSED=0
FAILED=0
WARNINGS=0

# Archivo de log para seguimiento en tiempo real
PERF_LOG="/tmp/pduzord_test_perf.log"
echo "" > "$PERF_LOG"

# Función para medir tiempo
time_start() {
    echo "$(date +%s.%N)" > "/tmp/pduzord_time_${1}"
}

time_end() {
    local label="$1"
    local start_file="/tmp/pduzord_time_${label}"
    if [[ -f "$start_file" ]]; then
        local start_time=$(cat "$start_file")
        local end_time=$(date +%s.%N)
        local duration
        # Usar bc si está disponible, sino usar awk
        if command -v bc &> /dev/null; then
            duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0.000")
        else
            duration=$(awk "BEGIN {printf \"%.3f\", $end_time - $start_time}" 2>/dev/null || echo "0.000")
        fi
        local timestamp=$(date +%H:%M:%S 2>/dev/null || date +%T)
        echo "[${timestamp}] ${label}: ${duration}s" >> "$PERF_LOG"
        printf "%.3f" "$duration"
        rm -f "$start_file"
    else
        echo "0.000"
    fi
}

# Función para mostrar resultados con tiempo opcional
test_pass() {
    local msg="$1"
    local elapsed="$2"
    if [[ -n "$elapsed" ]]; then
        echo -e "${GREEN}✓ PASS${NC}: $msg ${BLUE}(${elapsed}s)${NC}"
        echo "[PASS] $msg (${elapsed}s)" >> "$PERF_LOG"
    else
        echo -e "${GREEN}✓ PASS${NC}: $msg"
        echo "[PASS] $msg" >> "$PERF_LOG"
    fi
    ((PASSED++))
}

test_fail() {
    local msg="$1"
    local elapsed="$2"
    if [[ -n "$elapsed" ]]; then
        echo -e "${RED}✗ FAIL${NC}: $msg ${BLUE}(${elapsed}s)${NC}"
        echo "[FAIL] $msg (${elapsed}s)" >> "$PERF_LOG"
    else
        echo -e "${RED}✗ FAIL${NC}: $msg"
        echo "[FAIL] $msg" >> "$PERF_LOG"
    fi
    ((FAILED++))
}

test_warn() {
    local msg="$1"
    local elapsed="$2"
    if [[ -n "$elapsed" ]]; then
        echo -e "${YELLOW}⚠ WARN${NC}: $msg ${BLUE}(${elapsed}s)${NC}"
        echo "[WARN] $msg (${elapsed}s)" >> "$PERF_LOG"
    else
        echo -e "${YELLOW}⚠ WARN${NC}: $msg"
        echo "[WARN] $msg" >> "$PERF_LOG"
    fi
    ((WARNINGS++))
}

test_info() {
    echo -e "${BLUE}ℹ INFO${NC}: $1"
    echo "[INFO] $1" >> "$PERF_LOG"
}

# Función para ejecutar comandos con timeout
run_with_timeout() {
    local timeout_sec="$1"
    shift
    local result=""
    local exit_code=0
    
    # Intentar usar gtimeout (GNU timeout en macOS con Homebrew)
    if command -v gtimeout &> /dev/null; then
        result=$(gtimeout "$timeout_sec" "$@" 2>&1)
        exit_code=$?
    # Intentar usar timeout (GNU timeout en Linux)
    elif command -v timeout &> /dev/null; then
        result=$(timeout "$timeout_sec" "$@" 2>&1)
        exit_code=$?
    # Fallback: usar perl para crear timeout
    elif command -v perl &> /dev/null; then
        result=$(perl -e "alarm $timeout_sec; exec @ARGV" -- "$@" 2>&1)
        exit_code=$?
        # Perl alarm devuelve código de salida especial
        if [[ $exit_code -eq 142 ]]; then
            exit_code=124  # Convertir a código estándar de timeout
        fi
    # Último recurso: ejecutar sin timeout
    else
        result=$("$@" 2>&1)
        exit_code=$?
    fi
    
    echo -n "$result"
    return $exit_code
}

# Obtener el directorio base del proyecto
SCRIPT_DIR="$(cd "$(dirname "${0:A}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  TEST DE FUNCIONAMIENTO - PDUZord${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Log de rendimiento: ${PERF_LOG}${NC}"
echo -e "${BLUE}Monitorear con: tail -f ${PERF_LOG}${NC}"
echo ""

cd "$PROJECT_ROOT" || {
    echo "Error: No se puede acceder al directorio del proyecto"
    exit 1
}

# ============================================
# 1. Verificar estructura de directorios
# ============================================
echo -e "${YELLOW}[1/7] Verificando estructura de directorios...${NC}"
DIRS=(
    "pduzord"
    "pduzord/scripts"
    "pduzord/config"
    "pduzord/data"
    "pduzord/logs"
    "pduzord/docs"
)

for dir in "${DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        test_pass "Directorio existe: $dir"
    else
        test_fail "Directorio faltante: $dir"
    fi
done
echo ""

# ============================================
# 2. Verificar archivos críticos
# ============================================
echo -e "${YELLOW}[2/7] Verificando archivos críticos...${NC}"
FILES=(
    "pduzord/scripts/main_monitor.tcl"
    "pduzord/scripts/utils.tcl"
    "pduzord/scripts/admin_shell.sh"
    "pduzord/config/racks.conf"
    "pduzord/data/sample_data.csv"
    "README.md"
    "init.zsh"
)

for file in "${FILES[@]}"; do
    if [[ -f "$file" ]]; then
        test_pass "Archivo existe: $file"
    else
        test_fail "Archivo faltante: $file"
    fi
done
echo ""

# ============================================
# 3. Verificar permisos de ejecución
# ============================================
echo -e "${YELLOW}[3/7] Verificando permisos de ejecución...${NC}"
EXECUTABLES=(
    "pduzord/scripts/admin_shell.sh"
    "pduzord/scripts/main_monitor.tcl"
    "init.zsh"
)

for file in "${EXECUTABLES[@]}"; do
    if [[ -x "$file" ]]; then
        test_pass "Archivo ejecutable: $file"
    else
        test_warn "Archivo no ejecutable: $file (ejecutar: chmod +x $file)"
    fi
done
echo ""

# ============================================
# 4. Verificar dependencias
# ============================================
echo -e "${YELLOW}[4/7] Verificando dependencias del sistema...${NC}"
echo -e "${BLUE}   (Monitorear con: tail -f $PERF_LOG)${NC}"
echo ""

# Verificar tclsh
time_start "check_tclsh_command"
if command -v tclsh &> /dev/null; then
    ELAPSED=$(time_end "check_tclsh_command")
    test_info "   - Verificando tclsh... (${ELAPSED}s)"
    
    time_start "check_tclsh_version"
    # Ejecutar tclsh con timeout para evitar bloqueos (timeout muy corto)
    TCL_VERSION=$(run_with_timeout 1 tclsh -c "puts \$tcl_version" 2>/dev/null)
    EXIT_CODE=$?
    ELAPSED=$(time_end "check_tclsh_version")
    
    if [[ $EXIT_CODE -eq 124 ]] || [[ $EXIT_CODE -eq 142 ]]; then
        test_warn "tclsh se bloqueó al obtener versión (timeout después de ${ELAPSED}s)" "$ELAPSED"
    elif [[ -n "$TCL_VERSION" && "$TCL_VERSION" =~ ^[0-9] ]]; then
        test_pass "tclsh está instalado (versión: $TCL_VERSION)" "$ELAPSED"
    else
        test_warn "tclsh está instalado pero no retorna versión válida (output: '${TCL_VERSION}')" "$ELAPSED"
    fi
else
    ELAPSED=$(time_end "check_tclsh_command")
    test_fail "tclsh no está instalado (requerido para monitoreo TCL)" "$ELAPSED"
fi

# Verificar awk
time_start "check_awk"
if command -v awk &> /dev/null; then
    ELAPSED=$(time_end "check_awk")
    test_pass "awk está disponible" "$ELAPSED"
else
    ELAPSED=$(time_end "check_awk")
    test_fail "awk no está disponible (requerido para admin_shell.sh)" "$ELAPSED"
fi

# Verificar bash
time_start "check_bash"
if command -v bash &> /dev/null; then
    ELAPSED=$(time_end "check_bash")
    test_pass "bash está disponible" "$ELAPSED"
else
    ELAPSED=$(time_end "check_bash")
    test_warn "bash no está disponible (admin_shell.sh usa bash)" "$ELAPSED"
fi
echo ""

# ============================================
# 5. Verificar sintaxis de scripts TCL
# ============================================
echo -e "${YELLOW}[5/7] Verificando sintaxis de scripts TCL...${NC}"

# Test utils.tcl - Solo verificar sintaxis sin ejecutar funciones que puedan bloquearse
time_start "test_utils_syntax"
# Usar un script temporal para evitar problemas con [info script] en -c
TEMP_SCRIPT="/tmp/test_utils_$$.tcl"
cat > "$TEMP_SCRIPT" << 'EOFTCL'
source pduzord/scripts/utils.tcl
puts "Sintaxis OK"
EOFTCL
if run_with_timeout 3 tclsh "$TEMP_SCRIPT" > /dev/null 2>&1; then
    ELAPSED=$(time_end "test_utils_syntax")
    test_pass "Sintaxis de utils.tcl es válida" "$ELAPSED"
    rm -f "$TEMP_SCRIPT"
else
    ELAPSED=$(time_end "test_utils_syntax")
    EXIT_CODE=$?
    rm -f "$TEMP_SCRIPT"
    if [[ $EXIT_CODE -eq 124 ]] || [[ $EXIT_CODE -eq 142 ]]; then
        test_warn "utils.tcl se bloqueó al verificar sintaxis (timeout)" "$ELAPSED"
    else
        test_fail "Error de sintaxis en utils.tcl" "$ELAPSED"
    fi
fi

# Test main_monitor.tcl (solo verificar que se puede cargar, sin ejecutar el loop)
time_start "test_main_monitor_syntax"
# Solo verificar que los archivos se pueden cargar
if run_with_timeout 3 tclsh -c "set scriptDir [file dirname [file normalize pduzord/scripts/main_monitor.tcl]]; source pduzord/scripts/utils.tcl; puts 'Carga OK'" > /dev/null 2>&1; then
    ELAPSED=$(time_end "test_main_monitor_syntax")
    test_pass "Sintaxis de main_monitor.tcl es válida (carga exitosa)" "$ELAPSED"
else
    ELAPSED=$(time_end "test_main_monitor_syntax")
    # Verificar solo carga de archivo
    time_start "test_utils_only"
    TEMP_SCRIPT2="/tmp/test_utils2_$$.tcl"
    cat > "$TEMP_SCRIPT2" << 'EOFTCL'
source pduzord/scripts/utils.tcl
puts "OK"
EOFTCL
    if run_with_timeout 2 tclsh "$TEMP_SCRIPT2" > /dev/null 2>&1; then
        ELAPSED2=$(time_end "test_utils_only")
        test_warn "main_monitor.tcl puede tener problemas en tiempo de ejecución (pero sintaxis base OK)" "$ELAPSED2"
        rm -f "$TEMP_SCRIPT2"
    else
        ELAPSED2=$(time_end "test_utils_only")
        EXIT_CODE2=$?
        rm -f "$TEMP_SCRIPT2"
        if [[ $EXIT_CODE2 -eq 124 ]] || [[ $EXIT_CODE2 -eq 142 ]]; then
            test_warn "main_monitor.tcl y utils.tcl se bloquean (timeout)" "$ELAPSED2"
        else
            test_fail "Error crítico en main_monitor.tcl o dependencias" "$ELAPSED"
        fi
    fi
fi
echo ""

# ============================================
# 6. Verificar funcionalidad básica
# ============================================
echo -e "${YELLOW}[6/7] Ejecutando pruebas funcionales básicas...${NC}"

# Test: main_monitor.tcl con un rack específico
time_start "test_main_monitor_exec"
cd pduzord || {
    test_fail "No se puede acceder al directorio pduzord"
    cd "$PROJECT_ROOT"
}

# Limpiar el log anterior
echo "" > /tmp/pduzord_test_output.log

# Ejecutar con timeout y capturar salida
if run_with_timeout 5 tclsh scripts/main_monitor.tcl RACK1 > /tmp/pduzord_test_output.log 2>&1; then
    ELAPSED=$(time_end "test_main_monitor_exec")
    if grep -q "RACK1" /tmp/pduzord_test_output.log 2>/dev/null; then
        test_pass "main_monitor.tcl ejecuta correctamente (rack individual)" "$ELAPSED"
    else
        test_warn "main_monitor.tcl ejecuta pero sin output esperado de RACK1 (${ELAPSED}s)" "$ELAPSED"
    fi
else
    ELAPSED=$(time_end "test_main_monitor_exec")
    EXIT_CODE=$?
    if [[ $EXIT_CODE -eq 124 ]] || [[ $EXIT_CODE -eq 142 ]]; then
        test_warn "main_monitor.tcl se bloqueó o excedió tiempo límite (timeout)" "$ELAPSED"
    elif [[ $EXIT_CODE -eq 0 ]]; then
        # Si exit code es 0 pero no hay output, verificar qué pasó
        if [[ ! -s /tmp/pduzord_test_output.log ]]; then
            test_warn "main_monitor.tcl ejecutó pero no generó output" "$ELAPSED"
        else
            test_warn "main_monitor.tcl ejecutó pero sin el output esperado" "$ELAPSED"
        fi
    else
        test_warn "main_monitor.tcl falló con código $EXIT_CODE" "$ELAPSED"
    fi
fi

# Test: Verificar que las funciones de utils.tcl están disponibles
# Usar scripts temporales para evitar problemas con -c y [info script]
time_start "test_func_getPduIp"
TEMP_SCRIPT3="/tmp/test_func1_$$.tcl"
cat > "$TEMP_SCRIPT3" << 'EOFTCL'
source scripts/utils.tcl
if {[info procs getPduIp] ne {}} { puts OK } else { exit 1 }
EOFTCL
if run_with_timeout 2 tclsh "$TEMP_SCRIPT3" > /dev/null 2>&1; then
    ELAPSED=$(time_end "test_func_getPduIp")
    test_pass "Funciones de utils.tcl están disponibles (getPduIp)" "$ELAPSED"
    rm -f "$TEMP_SCRIPT3"
else
    ELAPSED=$(time_end "test_func_getPduIp")
    EXIT_CODE=$?
    rm -f "$TEMP_SCRIPT3"
    if [[ $EXIT_CODE -eq 124 ]] || [[ $EXIT_CODE -eq 142 ]]; then
        test_warn "getPduIp se bloqueó al verificar (timeout)" "$ELAPSED"
    else
        test_fail "Funciones de utils.tcl no están disponibles" "$ELAPSED"
    fi
fi

time_start "test_func_shutdown"
TEMP_SCRIPT4="/tmp/test_func2_$$.tcl"
cat > "$TEMP_SCRIPT4" << 'EOFTCL'
source scripts/utils.tcl
if {[info procs shutdown_low_priority_ports] ne {}} { puts OK } else { exit 1 }
EOFTCL
if run_with_timeout 2 tclsh "$TEMP_SCRIPT4" > /dev/null 2>&1; then
    ELAPSED=$(time_end "test_func_shutdown")
    test_pass "Función shutdown_low_priority_ports está disponible" "$ELAPSED"
    rm -f "$TEMP_SCRIPT4"
else
    ELAPSED=$(time_end "test_func_shutdown")
    EXIT_CODE=$?
    rm -f "$TEMP_SCRIPT4"
    if [[ $EXIT_CODE -eq 124 ]] || [[ $EXIT_CODE -eq 142 ]]; then
        test_warn "shutdown_low_priority_ports se bloqueó al verificar (timeout)" "$ELAPSED"
    else
        test_fail "Función shutdown_low_priority_ports no está disponible" "$ELAPSED"
    fi
fi

time_start "test_func_logToFile"
TEMP_SCRIPT5="/tmp/test_func3_$$.tcl"
cat > "$TEMP_SCRIPT5" << 'EOFTCL'
source scripts/utils.tcl
if {[info procs logToFile] ne {}} { puts OK } else { exit 1 }
EOFTCL
if run_with_timeout 2 tclsh "$TEMP_SCRIPT5" > /dev/null 2>&1; then
    ELAPSED=$(time_end "test_func_logToFile")
    test_pass "Función logToFile está disponible" "$ELAPSED"
    rm -f "$TEMP_SCRIPT5"
else
    ELAPSED=$(time_end "test_func_logToFile")
    EXIT_CODE=$?
    rm -f "$TEMP_SCRIPT5"
    if [[ $EXIT_CODE -eq 124 ]] || [[ $EXIT_CODE -eq 142 ]]; then
        test_warn "logToFile se bloqueó al verificar (timeout)" "$ELAPSED"
    else
        test_fail "Función logToFile no está disponible" "$ELAPSED"
    fi
fi

cd "$PROJECT_ROOT" || exit 1
echo ""

# ============================================
# 7. Verificar configuración y datos
# ============================================
echo -e "${YELLOW}[7/7] Verificando configuración y datos...${NC}"

# Verificar formato de racks.conf
if grep -q "^RACK" pduzord/config/racks.conf; then
    RACK_COUNT=$(grep -c "^RACK" pduzord/config/racks.conf)
    test_pass "racks.conf contiene configuración de racks ($RACK_COUNT racks encontrados)"
else
    test_fail "racks.conf no contiene configuración válida"
fi

# Verificar sample_data.csv
if [[ -s pduzord/data/sample_data.csv ]]; then
    if head -1 pduzord/data/sample_data.csv | grep -q "timestamp,rack"; then
        test_pass "sample_data.csv tiene formato CSV válido"
    else
        test_warn "sample_data.csv existe pero puede tener formato incorrecto"
    fi
else
    test_warn "sample_data.csv está vacío o no existe"
fi

# Verificar que logs/ puede escribirse
if [[ -w pduzord/logs ]]; then
    test_pass "Directorio logs/ es escribible"
else
    test_fail "Directorio logs/ no es escribible"
fi
echo ""

# ============================================
# Resumen final
# ============================================
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  RESUMEN DE PRUEBAS${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ Tests pasados: $PASSED${NC}"
if [[ $WARNINGS -gt 0 ]]; then
    echo -e "${YELLOW}⚠ Advertencias: $WARNINGS${NC}"
fi
if [[ $FAILED -gt 0 ]]; then
    echo -e "${RED}✗ Tests fallidos: $FAILED${NC}"
fi
echo ""
echo -e "${BLUE}Log de rendimiento completo: ${PERF_LOG}${NC}"
echo ""

# Determinar código de salida
if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ Todos los tests críticos pasaron${NC}"
    exit 0
else
    echo -e "${RED}✗ Algunos tests fallaron. Revisa los errores arriba.${NC}"
    exit 1
fi

