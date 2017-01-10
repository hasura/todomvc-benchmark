# Setting up gunicorn with django

* Install gunicorn on your webserver (and whitenoise to serve static files).
https://devcenter.heroku.com/articles/django-assets

```shell
$ sudo pip install gunicorn
$ sudo pip install whitenoise
```

* Start the gunicorn server

```shell
$  gunicorn -w 4 --access-logfile - --error-logfile - -b 0.0.0.0:8000 todo.wsgi
```
