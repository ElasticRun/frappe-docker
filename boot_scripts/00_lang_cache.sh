#!/bin/bash
cd /home/frappe/docker-bench
LANGUAGES=`echo 'select distinct language from tabUser;'|bench mariadb`
if [ $? -eq 0 ]
then
    for lang in ${LANGUAGES}
    do
        bench execute frappe.translate.load_lang --kwargs '{"lang": "'$lang'"}' 2>&1 > /home/frappe/docker-bench/logs/${lang}-cache.log
        if [ $? -eq 0 ]
        then
            echo "INFO: ${lang} translations cached successfully"
        else
            echo "WARN: ${lang} transactions could not be cached."
        fi
    done
fi
