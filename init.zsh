#!/bin/zsh
# Script de inicialización para PDUZord

# Crea la estructura de directorios del proyecto pduzord
mkdir -p pduzord/docs
mkdir -p pduzord/scripts
mkdir -p pduzord/config
mkdir -p pduzord/logs
mkdir -p pduzord/data

# Crea archivos básicos si no existen
[ ! -f pduzord/docs/memoria_proyecto.md ] && touch pduzord/docs/memoria_proyecto.md
[ ! -f pduzord/docs/diseno_electrico.md ] && touch pduzord/docs/diseno_electrico.md
[ ! -f pduzord/scripts/main_monitor.tcl ] && touch pduzord/scripts/main_monitor.tcl
[ ! -f pduzord/scripts/utils.tcl ] && touch pduzord/scripts/utils.tcl
[ ! -f pduzord/config/racks.conf ] && touch pduzord/config/racks.conf
[ ! -f pduzord/logs/readme.txt ] && touch pduzord/logs/readme.txt
[ ! -f pduzord/data/sample_data.csv ] && touch pduzord/data/sample_data.csv

echo "Estructura de directorios de PDUZord inicializada correctamente."
