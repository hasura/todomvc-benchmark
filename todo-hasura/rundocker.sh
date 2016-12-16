#!/bin/bash
docker run -ti --rm -e PROJECTNAME=bompod -p 7000:80 hasura/todomvc:1.0e
