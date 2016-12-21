#!/usr/local/bin/bash

if [ -z "$1" ]
  then
    printf "No server provided!! \nUsage ./benchmark.sh <server_addr>\n"
fi

SERVER=$1

declare -A AB_CMDS
AB_CMDS=(
 [GET_ACCOUNT_INFO]="ab -k -q -c 20 -n 200 -C ' _TodoRailsapi_session=SmNmSW5XaGVWNW1hS1UrUlJoMzRrdEczeTJJVUJmdHFpTUIxN0NERGlPN3JYc01wdFNZTENzT3E4QTRMTnZMeGEzdFZJd0wyVDBsYjVyV0RVZmhCVVllT2dSWXIzOW5BWm50NHlXVW9FcWc9LS1qTmNnQlY1amRheGVrVzdBZUVkYnRBPT0%3D--feed4f6771c508de644022e6e96832b6203f06e7' 104.155.111.199/user/account/info"
 [INSERT]="ab -k -q -c 20 -n 200 -p insert_data -T 'application/json' -C ' _TodoRailsapi_session=SmNmSW5XaGVWNW1hS1UrUlJoMzRrdEczeTJJVUJmdHFpTUIxN0NERGlPN3JYc01wdFNZTENzT3E4QTRMTnZMeGEzdFZJd0wyVDBsYjVyV0RVZmhCVVllT2dSWXIzOW5BWm50NHlXVW9FcWc9LS1qTmNnQlY1amRheGVrVzdBZUVkYnRBPT0%3D--feed4f6771c508de644022e6e96832b6203f06e7' 104.155.111.199/api/v1/table/todo/insert"
 [UPDATE]="ab -k -q -c 20 -n 200 -p update_data -T 'application/json' -C ' _TodoRailsapi_session=SmNmSW5XaGVWNW1hS1UrUlJoMzRrdEczeTJJVUJmdHFpTUIxN0NERGlPN3JYc01wdFNZTENzT3E4QTRMTnZMeGEzdFZJd0wyVDBsYjVyV0RVZmhCVVllT2dSWXIzOW5BWm50NHlXVW9FcWc9LS1qTmNnQlY1amRheGVrVzdBZUVkYnRBPT0%3D--feed4f6771c508de644022e6e96832b6203f06e7' 104.155.111.199/api/v1/table/todo/update"
 [UPDATE_ALL]="ab -k -q -c 20 -n 200 -p update_data -T 'application/json' -C ' _TodoRailsapi_session=SmNmSW5XaGVWNW1hS1UrUlJoMzRrdEczeTJJVUJmdHFpTUIxN0NERGlPN3JYc01wdFNZTENzT3E4QTRMTnZMeGEzdFZJd0wyVDBsYjVyV0RVZmhCVVllT2dSWXIzOW5BWm50NHlXVW9FcWc9LS1qTmNnQlY1amRheGVrVzdBZUVkYnRBPT0%3D--feed4f6771c508de644022e6e96832b6203f06e7' 104.155.111.199/api/v1/table/todo/delete_completed"
)

for test in "${!AB_CMDS[@]}"
do
  RESULT=`eval ${AB_CMDS[$test]}`
  echo
  echo "---------------------------------------------------"
  echo "$test"
  echo "$RESULT" | grep 'Complete requests'
  echo "$RESULT" | grep 'Non-2xx responses'
  echo "$RESULT" | grep 'Requests per second'
  echo "$RESULT" | grep '(mean, across all concurrent requests)'
  echo "---------------------------------------------------"
  echo
done
