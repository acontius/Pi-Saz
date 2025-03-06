#!/bin/bash
DB_NAME="psaz"
DB_USER="amin"

echo "Resetting database..."
psql -U $DB_USER -d postgres -c "DROP DATABASE IF EXISTS $DB_NAME;"
psql -U $DB_USER -d postgres -c "CREATE DATABASE $DB_NAME;"

for file in Products.sql Clients.sql Procedures.sql Triggers.sql
do
    echo "Executing $file..."
    psql -U $DB_USER -d $DB_NAME -f "$file"
done

echo "Database reset complete!"

# To run 
    # chmod +x reset.sh
    # ./reset.sh