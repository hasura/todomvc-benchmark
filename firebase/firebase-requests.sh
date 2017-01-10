#!/bin/bash

# app secret key to act as an admin user :P
cred=$FIREBASE_SECRET_KEY

echo "Inserting new todo"
resp=$(curl -XPOST -d '{"title": "holla new one", "completed": false}' https://todomvc-benchmark.firebaseio.com/todos.json?auth=$cred)
id=$(echo $resp | jq '.name' | tr -d '"')

echo "Get all todos"
curl https://todomvc-benchmark.firebaseio.com/todos.json?auth=$cred

echo ""
echo "Update a todo"
curl -XPATCH -d '{"completed": true}' "https://todomvc-benchmark.firebaseio.com/todos/$id.json?auth=$cred"

echo ""
echo "Delete a todo"
curl -XDELETE "https://todomvc-benchmark.firebaseio.com/todos/$id.json?auth=$cred"
