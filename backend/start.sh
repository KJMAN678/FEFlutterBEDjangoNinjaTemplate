#!/bin/sh
uv run manage.py migrate
uv run manage.py createsuperuser --noinput || true
uv run gunicorn --bind 0.0.0.0:8080 config.wsgi:application
