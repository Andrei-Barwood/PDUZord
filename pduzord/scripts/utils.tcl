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

proc logCritical {msg} { puts "CRIT: $msg" }
proc logWarning {msg} { puts "WARN: $msg" }
proc logInfo {msg} { puts "INFO: $msg" }
