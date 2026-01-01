# utils.tcl

# Snocomm Electrical

# Funciones auxiliares

set rackPduIp {
    RACK1 192.168.10.11
    RACK2 192.168.10.12
    RACK3 192.168.10.13
    RACK4 192.168.10.14
    RACK5 192.168.10.15
    RACK6 192.168.10.16
    RACK7 192.168.10.17
    RACK8 192.168.10.18
}
set rackCapacity {
    RACK1 16
    RACK2 16
    RACK3 16
    RACK4 16
    RACK5 16
    RACK6 16
    RACK7 16
    RACK8 16
}

proc getPduIp {rack} {
    global rackPduIp
    return [dict get $rackPduIp $rack]
}
proc getRackCapacity {rack} {
    global rackCapacity
    return [dict get $rackCapacity $rack]
}

proc snmp_get_current {ip} {
    # Retorna aleatorio para monitoreo
    return [expr {round(rand()*16)}]
}
proc snmp_get_voltage {ip} {
    return [expr {380 + int(rand()*10)}] ;# Voltaje Trifásico
}

proc logCritical {msg} { 
    puts "CRIT: $msg"
    logToFile "CRIT" $msg
}
proc logWarning {msg} { 
    puts "WARN: $msg"
    logToFile "WARN" $msg
}
proc logInfo {msg} { 
    puts "INFO: $msg"
    logToFile "INFO" $msg
}

proc logToFile {level msg} {
    # Determina la ruta del directorio de logs relativa al script
    set scriptDir [file dirname [file normalize [info script]]]
    set projectRoot [file dirname $scriptDir]
    set logDir [file join $projectRoot logs]
    set logFile [file join $logDir "log_[clock format [clock seconds] -format %Y-%m-%d].txt"]
    
    # Crea el directorio si no existe
    if {![file exists $logDir]} {
        file mkdir $logDir
    }
    
    # Escribe el log
    set timestamp [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
    set logEntry "$timestamp $level   $msg"
    set fp [open $logFile "a"]
    puts $fp $logEntry
    close $fp
}

proc shutdown_low_priority_ports {ip} {
    logCritical "Ejecutando shutdown de puertos de baja prioridad en PDU $ip"
    # TODO: Implementar SNMP SET para apagar puertos de baja prioridad
    # snmp_set_port_state $ip <port_list> off
    puts "   [SIMULACIÓN] Apagando puertos de baja prioridad en $ip"
}
