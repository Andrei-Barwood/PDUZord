# Memoria de Proyecto: Monitorización Eléctrica Inteligente para Racks

## Resumen

Este proyecto plantea reconfigurar la alimentación de ocho racks de switches, migrando de un esquema en serie a una arquitectura paralela, permitiendo mayor selectividad, control y monitoreo por software usando Tcl y SNMP.

## Objetivo

- Dotar a cada rack de su propio alimentador desde el tablero general.
- Instalar un medidor/PDU inteligente en cada tablero de rack.
- Implementar un sistema automatizado que lea, analice y actúe sobre datos eléctricos en tiempo real.

## Principios Técnicos

- Alimentadores en paralelo para máxima seguridad y flexibilidad eléctrica.
- Sistema de medición remota por SNMP expuesto vía red local.
- Scripts TCL para recorrido automatizado, análisis y reacción ante eventos de sobrecarga o desconexión.
- El software puede visualizar, registrar y reenviar avisos críticos.

## Diagrama conceptual

(Tablero general)───┬──(Rack 1 + PDU 1)
                    ├──(Rack 2 + PDU 2)
                    ├──(Rack 3 + PDU 3)
                    ├──(Rack 4 + PDU 4)
                    ├──(Rack 5 + PDU 5)
                    ├──(Rack 6 + PDU 6)
                    ├──(Rack 7 + PDU 7)
                    └──(Rack 8 + PDU 8)
