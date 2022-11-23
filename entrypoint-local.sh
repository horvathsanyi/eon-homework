#!/bin/bash

echo "Migrate"
python manage.py migrate

echo "Start server"
python manage.py runserver