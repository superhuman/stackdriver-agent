#!/bin/bash

# Copyright (C) 2016 wikiwi.io
#
# This software may be modified and distributed under the terms
# of the MIT license. See the LICENSE file for details.

set -eo pipefail
no=0
file=/opt/stackdriver/collectd/etc/collectd.d/postgresql.conf

# $1 = number
# $2 = variable name
get_var() {
  echo $(indir="POSTGRESQL_${1}_${2^^}"; echo ${!indir})
}

while [ -n "$(get_var ${no} db)" ]; do
db=$(get_var ${no} db)
host=$(get_var ${no} host)
port=$(get_var ${no} port)
user=$(get_var ${no} user)
password=$(get_var ${no} password)
echo "Configuring PostgreSQL database \"${db}\"..."
if [[ "${no}" == "0" ]]; then
cat <<EOL > "${file}"
LoadPlugin postgresql
<Plugin "postgresql">
EOL
fi
cat <<EOL >> "${file}"
  <Database "${db}">
    Host "${host:-"localhost"}"
    Port "${port:-"5432"}"
    User "${user:-"postgres"}"
    $(test -n "${password}" && echo "Password \"${password}\"")

    Query backends
    Query transactions
    Query queries
    Query queries_by_table
    Query query_plans
    Query table_states
    Query query_plans_by_table
    Query table_states_by_table
    Query disk_io
    Query disk_io_by_table
    Query disk_usage
  </Database>
EOL
no=$(expr ${no} + 1)
done

if [[ "${no}" != "0" ]]; then
echo "</Plugin>" >> "${file}"
fi
