#!/bin/bash

OPTIND=1

while getopts "c:C:n:t:" opt; do
  case "$opt" in
    c)
      CONCURRENCY="${OPTARG}"
      ;;
    n)
      NUMREQUESTS="${OPTARG}"
      ;;
    C)
      SESSION_COOKIE="${OPTARG}"
      ;;
    t)
      TEST="${OPTARG}"
      ;;
  esac
done

shift $((OPTIND-1))

echo "Project: $TEST"

declare -A TEST_SERVERS
TEST_SERVERS=(
  [rails_bm]="104.198.99.32"
  [rails_heroku]="peaceful-spire-96451"
  [django]="104.198.99.32"
  [hasura]="warble80.hasura-app.io"
)

SERVER="${TEST_SERVERS[$TEST]}"

if [ -z "$SERVER" ]
  then
    printf "No server provided!! \nUsage ./benchmark.sh -t <backend_type> -C <session_cookie>\n"
    exit 1
fi

echo "Server: $SERVER"

declare -A AB_CMDS

case $TEST in
  rails_bm|rails_heroku)
    AB_CMDS[GET_ACCOUNT_INFO]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -C $SESSION_COOKIE $SERVER/user/account/info"
    AB_CMDS[INSERT]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p insert_data_rails -T 'application/json' -C $SESSION_COOKIE $SERVER/api/v1/table/todo/insert"
    AB_CMDS[UPDATE]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p update_data_rails -T 'application/json' -C $SESSION_COOKIE $SERVER/api/v1/table/todo/update"
    AB_CMDS[UPDATE_ALL]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p update_data_rails -T 'application/json' -C $SESSION_COOKIE $SERVER/api/v1/table/todo/delete_completed"
    ;;
  django)
    echo "in django"
    AB_CMDS[GET_ACCOUNT_INFO]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -C $SESSION_COOKIE $SERVER/auth/user/"
    AB_CMDS[INSERT]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p insert_data_django -T 'application/json' -C $SESSION_COOKIE $SERVER/api/tasks/"
    AB_CMDS[UPDATE]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p update_data_django -m 'PATCH' -T 'application/json' -C $SESSION_COOKIE $SERVER/api/tasks/"
    AB_CMDS[UPDATE_ALL]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p update_data_django -T 'application/json' -C $SESSION_COOKIE $SERVER/api/tasks/delete-completed"
    ;;
  hasura)
    AB_CMDS[GET_ACCOUNT_INFO]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -C $SESSION_COOKIE https://auth.$SERVER/user/account/info"	#Use auth server
    AB_CMDS[INSERT]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p insert_data_hasura -T 'application/json' -C $SESSION_COOKIE https://data.$SERVER/api/1/table/todo/insert"
    AB_CMDS[UPDATE]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p update_data_hasura -T 'application/json' -C $SESSION_COOKIE https://data.$SERVER/api/1/table/todo/update"
    AB_CMDS[UPDATE_ALL]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p delete_completed_hasura -T 'application/json' -C $SESSION_COOKIE https://data.$SERVER/api/1/table/todo/delete"
    ;;
esac

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
