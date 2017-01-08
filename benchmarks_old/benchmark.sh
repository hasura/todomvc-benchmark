#!/bin/bash

OPTIND=1

CONCURRENCY=20
NUMREQUESTS=400
SESSION_COOKIE="''"

while getopts "c:C:n:t:" opt; do
  case "$opt" in
    c)
      CONCURRENCY=${OPTARG}
      ;;
    n)
      NUMREQUESTS=${OPTARG}
      ;;
    C)
      SESSION_COOKIE=${OPTARG}
      ;;
    t)
      TEST=${OPTARG}
      ;;
  esac
done

shift $((OPTIND-1))

echo "Project: $TEST"

declare -A TEST_SERVERS
TEST_SERVERS=(
  [rails_bm]="104.198.99.32"
  [rails_heroku]="https://peaceful-spire-96451.herokuapp.com"
  [django]="104.198.99.32:8000"
  [hasura]="warble80.hasura-app.io"
  [firebase]="https://todomvc-benchmark.firebaseio.com"
)

SERVER="${TEST_SERVERS[$TEST]}"

if [ -z "$SERVER" ]
  then
    printf "No server provided!! \nUsage ./benchmark.sh -t <backend_type> -C <session_cookie>\n"
    exit 1
fi

echo "Test: $TEST"
echo "Server: $SERVER"
echo "Concurrency: $CONCURRENCY"
echo "Num of Requests: $NUMREQUESTS"

firebase_todo_id="-K_dp6w-pKtArDrSy2Bl"

declare -A AB_CMDS

case $TEST in
  rails_bm|rails_heroku)
    AB_CMDS[GET_ACCOUNT_INFO]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -C $SESSION_COOKIE $SERVER/user/account/info"
    AB_CMDS[SELECT]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p select_data_rails -T 'application/json' -C $SESSION_COOKIE $SERVER/api/v1/table/todo/select"
    AB_CMDS[INSERT]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p insert_data_rails -T 'application/json' -C $SESSION_COOKIE $SERVER/api/v1/table/todo/insert"
    AB_CMDS[UPDATE]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p update_data_rails -T 'application/json' -C $SESSION_COOKIE $SERVER/api/v1/table/todo/update"
    AB_CMDS[UPDATE_ALL]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p update_data_rails -T 'application/json' -C $SESSION_COOKIE $SERVER/api/v1/table/todo/delete_completed"
    ;;
  django)
    AB_CMDS[GET_ACCOUNT_INFO]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -C $SESSION_COOKIE $SERVER/auth/user/"
    AB_CMDS[SELECT]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -C $SESSION_COOKIE $SERVER/api/tasks/"
    AB_CMDS[INSERT]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p insert_data_django -T 'application/json' -C $SESSION_COOKIE $SERVER/api/tasks/"
    AB_CMDS[UPDATE]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p update_data_django -m 'PATCH' -T 'application/json' -C $SESSION_COOKIE $SERVER/api/tasks/"
    AB_CMDS[UPDATE_ALL]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p update_data_django -T 'application/json' -C $SESSION_COOKIE $SERVER/api/tasks/delete-completed"
    ;;
  hasura)
    AB_CMDS[GET_ACCOUNT_INFO]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -C $SESSION_COOKIE https://auth.$SERVER/user/account/info"	#Use auth server
    AB_CMDS[SELECT]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p select_data_hasura -T 'application/json' -C $SESSION_COOKIE https://data.$SERVER/api/1/table/todo/select"
    AB_CMDS[INSERT]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p insert_data_hasura -T 'application/json' -C $SESSION_COOKIE https://data.$SERVER/api/1/table/todo/insert"
    AB_CMDS[UPDATE]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p update_data_hasura -T 'application/json' -C $SESSION_COOKIE https://data.$SERVER/api/1/table/todo/update"
    AB_CMDS[UPDATE_ALL]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p delete_completed_hasura -T 'application/json' -C $SESSION_COOKIE https://data.$SERVER/api/1/table/todo/delete"
    ;;
  firebase)
    AB_CMDS[GET_ACCOUNT_INFO]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS $SERVER/todos.json?auth=$SESSION_COOKIE"
    AB_CMDS[SELECT]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS $SERVER/todos.json?auth=$SESSION_COOKIE"
    AB_CMDS[INSERT]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p insert_data_firebase -T 'application/json' $SERVER/todos.json?auth=$SESSION_COOKIE"
    AB_CMDS[UPDATE]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -p update_data_firebase -m 'PATCH' -T 'application/json' $SERVER/todos/$firebase_todo_id.json?auth=$SESSION_COOKIE"
    AB_CMDS[UPDATE_ALL]="ab -k -q -c $CONCURRENCY -n $NUMREQUESTS -m 'DELETE' $SERVER/todos/$firebase_todo_id.json?auth=$SESSION_COOKIE"
    ;;
esac

for test in "${!AB_CMDS[@]}"
do
  echo "${AB_CMDS[$test]}"
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
