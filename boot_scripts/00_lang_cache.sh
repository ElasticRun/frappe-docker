#!/bin/bash
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
