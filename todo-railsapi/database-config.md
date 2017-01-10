# Postgres Configuration to deploy a Rails app
For this guide, we are assuming that we are using a Ubuntu 16.10 server.

* Install Postgres.

```shell
$ sudo apt-get install postgresql
```

* Login via `psql` using the `postgres` user.

```shell
$ psql -U postgres -d postgres
```

* Create a database and switch to the database.

```sql
psql> CREATE DATABASE todomvc_rails;
psql> \c todomvc_rails
```

* Create a user and grant him all privileges on the database.

```sql
psql> CREATE USER todomvc WITH ENCRYPTED PASSWORD 'mysupersecretpassword';
psql> GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO todomvc;
```
