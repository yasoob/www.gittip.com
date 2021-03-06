#!/bin/sh

# Exit if any subcommands or pipeline returns a non-zero status.
set -e

# Make a database for Gittip.
#
#   usage: DATABASE_URL=postgres://foo:bar@baz:5234/buz recreate-schema.sh


# Configure the Postgres environment.
# ===================================

# Store ./configure-pg-env.sh output in a variable, so if it fails, it'll exit
# before running `export` (export with no args will print all exported variables).
ENV=`./configure-pg-env.sh`

# If we successfully got a result in $ENV, export it.
export $ENV



echo "=============================================================================="

# I got the idea for dropping the schema as a way to clear out the db from
# http://www.postgresql.org/message-id/200408241254.19075.josh@agliodbs.com. On
# Heroku Postgres we don't have permission to drop and create the db as a 
# whole.

echo "Recreating public schema ... "
echo "DROP SCHEMA public CASCADE" | psql
echo "CREATE SCHEMA public" | psql


echo "=============================================================================="
echo "Applying schema.sql ..."
echo 

psql < enforce-utc.sql
psql < schema.sql


echo "=============================================================================="
echo "Looking for branch.sql ..."
echo 

if [ -f branch.sql ]
then psql < branch.sql
else echo "None found."
fi

echo 
echo "=============================================================================="
