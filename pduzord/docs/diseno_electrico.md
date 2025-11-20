# Diseño Eléctrico

## Esquema

- Tablero General: Fuente principal con protecciones para 8 circuitos independientes.
- Cada circuito alimenta un subtablero de rack, con interruptor termomagnético y medidor SNMP.

## Características por rack

- Capacidad máxima por rack: 16A.
- Cada rack cuenta con PDU inteligente gestionable por red.
- El cableado y protección cumplen con criterios ideales, ajustar los valores a la escala de su rig.

## Ventajas de la distribución en paralelo

- Un sobreconsumo en un rack no afecta el resto de la instalación.
- Permite registrar el consumo por rack y automatizar acciones.
- Escalabilidad, al poder agregar racks repitiendo el patrón.

## Elementos monitorizables por SNMP

- Corriente RMS (Amperes)
- Tensión de línea (Volts)
- Estado de alarmas y salidas PDU

## Observaciones

- Se recomienda especificar cada alimentador conforme a la reglamentación vigente.
- El monitoreo remoto es solo apoyo, los dispositivos físicos son los que realmente interrumpen/conmutan la energía.

