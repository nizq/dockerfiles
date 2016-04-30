#!/bin/bash
set -eo pipefail

DATADIR="$(mysqld --verbose --help --log-bin-index=`mktemp -u` 2>/dev/null | awk '$1 == "datadir" { print $2; exit }')"
SOCKETDIR="$(dirname $(mysqld --verbose --help --log-bin-index=`mktemp -u` 2>/dev/null | awk '$1 == "socket" { print $2; exit }'))"
ERROR_LOG=/var/log/mysql.log
PID_FILE=/run/mysqld/mysqld.pid
MYSQLD_SAFE="/usr/bin/mysqld_safe --log-error=$ERROR_LOG --pid-file=$PID_FILE"


if [ ! -d "$SOCKETDIR" ]; then
    mkdir -p $SOCKETDIR
	  chown -R mysql:mysql $SOCKETDIR
fi

if [ ! -d "$DATADIR/mysql" ]; then
		if [ -z "$MYSQL_ROOT_PASSWORD" -a -z "$MYSQL_ALLOW_EMPTY_PASSWORD" -a -z "$MYSQL_RANDOM_ROOT_PASSWORD" ]; then
			  echo >&2 'error: database is uninitialized and password option is not specified '
			  echo >&2 '  You need to specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD'
			  exit 1
		fi

		mkdir -p "$DATADIR"
		chown -R mysql:mysql "$DATADIR"

		echo 'Initializing database'
		mysql_install_db --user=mysql --datadir="$DATADIR" --rpm
		echo 'Database initialized'

    if [ ! -z "$MYSQL_RANDOM_ROOT_PASSWORD" ]; then
			  MYSQL_ROOT_PASSWORD="$(pwgen -1 32)"
			  echo "GENERATED ROOT PASSWORD: $MYSQL_ROOT_PASSWORD"
		fi

    $MYSQLD_SAFE &
    MYSQLD_SAFE_PID=$!

    while true; do
        if grep "ready for connections" $ERROR_LOG; then
            break;
        else
            echo "Still waiting for DB service..." && sleep 1
        fi
    done

    # 创建新的数据库，如果挂载宿主目录，意味着可以反复使用run命令在创建新的数据库
    mysql=( mysql -uroot )

    if [ "$MYSQL_DATABASE" ]; then
		    echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;" | "${mysql[@]}"
		    mysql+=( "$MYSQL_DATABASE" )
    fi

    if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
		    echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' ;" | "${mysql[@]}"

		    if [ "$MYSQL_DATABASE" ]; then
				    echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%' ;" | "${mysql[@]}"
		    fi

		    echo 'FLUSH PRIVILEGES ;' | "${mysql[@]}"
    fi

    # 设置root用户密码
    mysqladmin password $MYSQL_ROOT_PASSWORD
else
    $MYSQLD_SAFE &
    MYSQLD_SAFE_PID=$!
fi

wait $MYSQLD_SAFE_PID
