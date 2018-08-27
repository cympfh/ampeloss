#!/bin/bash

# args
USER=${1:-cympfh}
echo "Notification to @${USER}"

# dependency
DEPS=(atq animetick)
NG=0
for c in $DEPS; do
    if which $c >/dev/null; then
        true
    else
        NG=1
        echo "Not found: ${c}"
    fi
done
if [ $NG -eq 1 ]; then
    exit 1
fi

report() {
    tw-cd ampeloss
    tw "@${USER} $@"
    echo reported
    true
}

skip() {
    echo skipped
    false
}

animetry() {
    animetick | ruby -p -e '
    require "time"
    a, b, *c = $_.split(" ")
    $_ = "#{Time.parse(a + " "  + b).to_i} #{c.join " "}\n"' |
    while read line; do
        anime_title=$(echo $line | sed 's/^[^ ]* //g')
        echo "Scheduled: $anime_title"
        time_before_5min=$(( $(echo $line | sed 's/ .*//g') - 300 ))
        atq $time_before_5min echo && report "$anime_title 5分前" || skip "$anime_title"
        time_before_1min=$(( $(echo $line | sed 's/ .*//g') - 60 ))
        atq $time_before_1min echo && report "$anime_title 1分前" || skip "$anime_title"
        if [ $? -eq 0 ]; then
            break
        fi
    done
}

while :; do
    animetry
    sleep 1m
done
