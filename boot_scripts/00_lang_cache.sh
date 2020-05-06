#!/bin/bash
## Sample boot script that can pretty much do anything. Boot scripts are executed just before starting the 
## Frappe processes using bench commands.
## This example loads cache of specific languages from translations using bench console command.
cd /home/frappe/docker-bench
bench console <<EOF
languages = ['en-US', 'en-UK', 'en-IN', 'en']
for lang in languages:
    frappe.translate.load_lang(lang=lang)
    print("Loaded translations for ", lang)


EOF
if [ $? -ne 0 ]
then
    echo "WARN: Pre-loading of language translations failed"
fi
