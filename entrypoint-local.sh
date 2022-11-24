#!/bin/bash

echo "Migrate"
python manage.py migrate

echo "Start server"
python manage.py runserver 0.0.0.0:8000