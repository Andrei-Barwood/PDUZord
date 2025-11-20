#!/usr/bin/env tclsh
# main_monitor.tcl

# Snocomm Electrical

# Script principal para monitoreo y control de racks eléctricos via SNMP

source utils.tcl

set racks {RACK1 RACK2 RACK3 RACK4 RACK5 RACK6 RACK7 RACK8}

foreach rack $racks {
    set ip [getPduIp $rack]
    set cap [getRackCapacity $rack]
    set val [snmp_get_current $ip]
    set volt [snmp_get_voltage $ip]
    set percent [expr {100.0 * $val / $cap}]

    if {$percent > 90} {
        logCritical "$rack sobrecargado: $val A ($percent%)"
         shutdown_low_priority_ports $ip
    } elseif {$percent > 70} {
        logWarning "$rack alto consumo: $val A ($percent%)"
    } else {
        logInfo "$rack OK: $val A"
    }
}
