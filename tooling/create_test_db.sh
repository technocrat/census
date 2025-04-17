#!/bin/bash

# Connect to the default 'postgres' database to create a new database
psql -d postgres -c "CREATE DATABASE test;"

echo "Test database created successfully."

