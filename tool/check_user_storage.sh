#!/bin/bash

CHECK_DATE=$(date +%Y%m%d%H%M%S)
RESULT_FILE=${HOME}/Downloads/${CHECK_DATE}_storage_result.txt
time (TIMEFORMAT='total: %R sec' && du -sh ${HOME}/*/ 2>/dev/null | sort -hr) > ${RESULT_FILE} 2>&1
