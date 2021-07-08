#!/bin/sh
set -e

# Generate new SYSDBA password if not set
[ -z "$ISC_PASSWORD" ] && ISC_PASSWORD=`dd if=/dev/urandom bs=10 count=1 2>/dev/null | od -x | head -n 1 | tr -d ' ' | cut -c8-27`
echo "SYSDBA password: $ISC_PASSWORD"

# Update SYSDBA password
/usr/local/firebird/bin/isql -q << EOF
connect /usr/local/firebird/security3.fdb user SYSDBA;
alter user SYSDBA password '$ISC_PASSWORD';
commit;
quit;
EOF

# Write new password to SYSDBA.password
sed -i "s/^ISC_PASSWORD=.*/ISC_PASSWORD=$ISC_PASSWORD/" /usr/local/firebird/SYSDBA.password
sed -i "s/^ISC_PASSWD=.*/ISC_PASSWD=$ISC_PASSWORD/" /usr/local/firebird/SYSDBA.password

# Launch firebird
exec /usr/local/firebird/bin/firebird
