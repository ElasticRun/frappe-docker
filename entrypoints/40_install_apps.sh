cd ${BENCH_HOME}
SITE=`cat ${BENCH_HOME}/sites/currentsite.txt`
INSTALLED_APPS=`bench list-apps`
INSTALLED_APPS_COUNT=`echo $INSTALLED_APPS | wc -l`
APPS_DIR_COUNT=`ls -l ./apps | wc -l`

if [ ${APPS_DIR_COUNT} -ne ${INSTALLED_APPS_COUNT} ]
then
    echo > ${BENCH_HOME}/sites/apps.txt
    for app in `ls ${BENCH_HOME}/apps`
    do
        # TODO - Check if app in apps dir is available in installed apps.
        # Install only if not available.
        export VAL=$app
        echo "$app" >> ${BENCH_HOME}/sites/apps.txt
        awk 'BEGIN
            {
                liststr = ENVIRON["INSTALLED_APPS"]
                val = ENVIRON["VAL"]
                #print "val = ", val
                arrlen = split(liststr, APP_ARR, sep="\n")
                #print "APP_ARR = ", APP_ARR[1], " length = ", arrlen
                retval = 1
                i = 1
                while ( and(i <= arrlen, retval == 1) ) {  printf("%i - key - %s\n", i, APP_ARR[i]);  if (APP_ARR[i]==val) {retval = 0}; i += 1 }
                #print "retval - ", retval
                exit retval
            }
            END
            { exit retval }'
        if [ $? -ne 0 ]
        then
            echo "Installing Application '$app'"
            bench --site ${SITE} install-app $app
        else
            echo "App $app already installed"
        fi
    done
fi
