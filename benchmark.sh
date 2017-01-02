#!/bin/bash

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
AB_RAILS_CMDS=(
 [GET_ACCOUNT_INFO]="ab -k -q -c 20 -n 200 -C $SESSION_COOKIE $SERVER/user/account/info"
 [INSERT]="ab -k -q -c 20 -n 200 -p insert_data -T 'application/json' -C $SESSION_COOKIE $SERVER/api/v1/table/todo/insert"
 [UPDATE]="ab -k -q -c 20 -n 200 -p update_data -T 'application/json' -C $SESSION_COOKIE $SERVER/api/v1/table/todo/update"
 [UPDATE_ALL]="ab -k -q -c 20 -n 200 -p update_data -T 'application/json' -C $SESSION_COOKIE $SERVER/api/v1/table/todo/delete_completed"
)


#For django
AB_DJANGO_CMDS=(
 [GET_ACCOUNT_INFO]="ab -k -q -c 20 -n 200 -C $SESSION_COOKIE $SERVER/auth/user/"
 [INSERT]="ab -k -q -c 20 -n 200 -p insert_data -T 'application/json' -C $SESSION_COOKIE $SERVER/api/tasks/"
 [UPDATE]="ab -k -q -c 20 -n 200 -p update_data -m 'PATCH' -T 'application/json' -C $SESSION_COOKIE $SERVER/api/tasks/"
 [UPDATE_ALL]="ab -k -q -c 20 -n 200 -p update_data -T 'application/json' -C $SESSION_COOKIE $SERVER/api/tasks/delete-completed"
)

#For hasura
AB_CMDS=(
 [GET_ACCOUNT_INFO]="ab -k -q -c 200 -n 2000 -C $SESSION_COOKIE $SERVER/user/account/info"	#Use auth server
 [INSERT]="ab -k -q -c 200 -n 2000 -p insert_data -T 'application/json' -C $SESSION_COOKIE $SERVER/api/1/table/todo/insert"
 [UPDATE]="ab -k -q -c 200 -n 2000 -p update_data -T 'application/json' -C $SESSION_COOKIE $SERVER/api/1/table/todo/update"
 [UPDATE_ALL]="ab -k -q -c 200 -n 2000 -p delete_completed -T 'application/json' -C $SESSION_COOKIE $SERVER/api/1/table/todo/delete"
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
