#!/bin/bash

# Collect static files
echo "Collect static files"
python manage.py collectstatic --noinput

# Apply database migrations
echo "Apply database migrations"
python manage.py migrate

# Start server
echo "Start server"
gunicorn --bind 0.0.0.0:80 --chdir realworld config.wsgi