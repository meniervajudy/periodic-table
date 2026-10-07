#!/bin/bash

if [[ $# -eq 0 ]]; then
  printf '%s\n' 'Please provide an element as an argument.'
  exit 0
fi

PSQL="psql --username=freecodecamp --dbname=periodic_table -X -t --no-align"
query="SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass,
       p.melting_point_celsius, p.boiling_point_celsius
FROM elements e
JOIN properties p USING (atomic_number)
JOIN types t USING (type_id)
WHERE e.atomic_number::text = :'lookup'
   OR e.symbol = :'lookup'
   OR e.name = :'lookup'
LIMIT 1;"
result=$($PSQL -F '|' -v "lookup=$1" <<< "$query")

if [[ -z $result ]]; then
  printf '%s\n' 'I could not find that element in the database.'
  exit 0
fi

IFS='|' read -r atomic_number name symbol type atomic_mass melting_point boiling_point <<< "$result"
printf "The element with atomic number %s is %s (%s). It's a %s, with a mass of %s amu. %s has a melting point of %s celsius and a boiling point of %s celsius.\n" \
  "$atomic_number" "$name" "$symbol" "$type" "$atomic_mass" "$name" \
  "$melting_point" "$boiling_point"