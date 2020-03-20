cd ${BENCH_HOME}
SITE=`cat ${BENCH_HOME}/sites/currentsite.txt`
export INSTALLED_APPS=`bench list-apps`
export INSTALLED_APPS_COUNT=`echo $INSTALLED_APPS | wc -l`
export APPS_DIR_COUNT=`ls -l ./apps | wc -l`
echo "Installed Apps - ${INSTALLED_APPS}(${INSTALLED_APPS_COUNT})"
echo "Apps Dir Count - ${APPS_DIR_COUNT}"
if [ ${APPS_DIR_COUNT} -ne ${INSTALLED_APPS_COUNT} ]
then
    echo "Clearing apps.txt"
    echo > ${BENCH_HOME}/sites/apps.txt
    echo "apps.txt cleared"
    for app in `ls ${BENCH_HOME}/apps`
    do
        # TODO - Check if app in apps dir is available in installed apps.
        # Install only if not available.
        echo "Processing application $app"
        export VAL=$app
        echo "Exported VAL=$VAL. Adding to apps.txt"
        echo "$app" >> ${BENCH_HOME}/sites/apps.txt
        AWK_RESULT=$(awk 'BEGIN {
            liststr = ENVIRON["INSTALLED_APPS"]
            val = ENVIRON["VAL"]
            #print "val = ", val
            arrlen = split(liststr, APP_ARR, sep="\n")
            #print "APP_ARR = ", APP_ARR[1], " length = ", arrlen
            retval = 1
            i = 1
            while ( i <= arrlen && retval == 1 ) {  if (APP_ARR[i]==val) {retval = 0}; i += 1 }
            #print "retval - ", retval
            print retval
        }')
        echo "AWK Result = ${AWK_RESULT}"
        if [ ${AWK_RESULT} -ne 0 ]
        then
            echo "Installing Application '$app'"
            bench --site ${SITE} install-app $app
        else
            echo "App $app already installed"
        fi
    done
fi
