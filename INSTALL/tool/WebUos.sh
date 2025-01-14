#!/bin/sh

LOGFILE=log.txt

#delete the log.txt if it's more than 8MB
if [ -f $LOGFILE ]; then
    logsize=$(stat -c '%s' $LOGFILE)
    if [ $logsize -gt 8388608 ]; then
        rm -f $LOGFILE
    fi
fi


if [ -f ./tool/$TOOLDIR/V2DServer.xz ]; then
    xz -d ./tool/$TOOLDIR/V2DServer.xz
    chmod +x ./tool/$TOOLDIR/V2DServer
fi

rm -rf ./*_VTMPDIR
vtWebTmpDir=$(mktemp -d -p ./ --suffix=_VTMPDIR)

V2DServer "$HOST" "$PORT" &
V2DPid=$!
sleep 1


vtVer=$(cat ventoy/version)
echo ""
echo "=================================================="
if [ "$LANG" = "zh_CN.UTF-8" ]; then
    echo "  Ventoy Server $vtVer 已经启动 ..."
else
    echo "  Ventoy Server $vtVer is running ..."
fi
echo "=================================================="
echo ""
echo "########### Press Ctrl + C to exit ###############"
echo ""


uos-browser --window-size=550,400 --app="http://${HOST}:${PORT}/index.html?chrome-app"  --user-data-dir=$vtWebTmpDir >> $LOGFILE 2>&1

[ -d /proc/$V2DPid ] && kill -2 $V2DPid
[ -d $vtWebTmpDir ] && rm -rf $vtWebTmpDir

if [ -n "$OLDDIR" ]; then 
    CURDIR=$(pwd)
    if [ "$CURDIR" != "$OLDDIR" ]; then
        cd "$OLDDIR"
    fi
fi
