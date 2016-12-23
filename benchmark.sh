#!/usr/local/bin/bash

if [ -z "$1" ]
  then
    printf "No server provided!! \nUsage ./benchmark.sh <server_addr> <session_cookie>\n"
    exit 1
fi

if [ -z "$2" ]
  then
    printf "No session cookie provided!! \nUsage ./benchmark.sh <server_addr> <session_cookie>\n"
    exit 1
fi


SERVER=$1
SESSION_COOKIE=$2

declare -A AB_CMDS
AB_CMDS=(
 [GET_ACCOUNT_INFO]="ab -k -q -c 20 -n 200 -C $SESSION_COOKIE $SERVER/user/account/info"
 [INSERT]="ab -k -q -c 20 -n 200 -p insert_data -T 'application/json' -C $SESSION_COOKIE $SERVER/api/v1/table/todo/insert"
 [UPDATE]="ab -k -q -c 20 -n 200 -p update_data -T 'application/json' -C $SESSION_COOKIE $SERVER/api/v1/table/todo/update"
 [UPDATE_ALL]="ab -k -q -c 20 -n 200 -p update_data -T 'application/json' -C $SESSION_COOKIE $SERVER/api/v1/table/todo/delete_completed"
)

for test in "${!AB_CMDS[@]}"
do
  RESULT=`eval ${AB_CMDS[$test]}`
  echo
  echo "---------------------------------------------------"
  echo "$test"
  echo "$RESULT" | grep 'Complete requests'
  echo "$RESULT" | grep 'Failed requests'
  echo "$RESULT" | grep 'Non-2xx responses'
  echo "$RESULT" | grep 'Requests per second'
  echo "$RESULT" | grep '(mean, across all concurrent requests)'
  echo "---------------------------------------------------"
  echo
done
