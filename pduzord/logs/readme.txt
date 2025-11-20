Snocomm Electrical

Logs generados por el sistema de monitoreo eléctrico de racks.

- Cada ejecución registra eventos de estado y alarmas.
- Los eventos se almacenan en archivos tipo log por fecha, ejemplo: log_2025-11-20.txt

Formato típico de eventos:
[TIMESTAMP] [NIVEL] [RACK] [MENSAJE]

Ejemplo:
2025-11-20 10:05:12 INFO   RACK3 OK, corriente: 8A, voltaje: 379V
2025-11-20 10:05:12 WARN   RACK5 alto consumo: 12A (75%)
2025-11-20 10:05:12 CRIT   RACK8 sobrecargado: 15.6A (97%)
2025-11-20 10:05:12 ACTION RACK8 Apagando puertos de baja prioridad por sobrecarga
