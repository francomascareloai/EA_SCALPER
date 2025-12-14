#!/bin/bash

SOURCE="/mnt/c/Users/Admin/Documents/EA_SCALPER_XAUUSD/Python_Agent_Hub/ml_pipeline/data/CSV_2003-2025XAUUSD_ftmo_all-TICK-No Session.csv"
DEST="/root/projetos/EA_SCALPER_XAUUSD/Python_Agent_Hub/ml_pipeline/data/"
LOG="/tmp/master-csv-copy.log"

echo "[$(date)] Iniciando copia do master CSV (29GB)" | tee $LOG
echo "Source: $SOURCE" | tee -a $LOG
echo "Dest: $DEST" | tee -a $LOG

cp -v "$SOURCE" "$DEST" 2>&1 | tee -a $LOG

if [ $? -eq 0 ]; then
    echo "[$(date)] Copia concluida com sucesso!" | tee -a $LOG
    ls -lh "$DEST"*.csv | tee -a $LOG
else
    echo "[$(date)] ERRO na copia (exit code: $?)" | tee -a $LOG
fi
