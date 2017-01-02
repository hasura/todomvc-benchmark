FROM debian:jessie
MAINTAINER Anon Ray <anon@hasura.io>

COPY requirements.txt /requirements.txt

RUN apt-get update && apt-get install -y python3 python3-pip \
  python3-pkg-resources libpq5 libpq-dev postgresql-client \
 && pip3 install -r /requirements.txt \
 && apt-get purge -y --auto-remove python3-pip libpq-dev \
 && rm -rf ~/.cache/pip \
 && rm -rf /var/lib/apt/lists/*

COPY app /app

WORKDIR /app

CMD ["gunicorn", "-w", "4", "--access-logfile", "-", "--error-logfile", "-", "-b", "0.0.0.0:8000", "todo.wsgi"]
