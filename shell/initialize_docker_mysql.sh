#!/bin/bash -e

NAME="mysql"
DATABASE="database"
USER="user"
PASSWORD=""

usage() {
    cat <<-EOF
USAGE: $(basename "$0")

    OPTIONS


EOF
    return;
}

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | sed 's/^[^=]*=//g'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --name)
            NAME=$VALUE
            ;;
        --database)
            DATABASE=$VALUE
            ;;
        --user)
            USER=$VALUE
            ;;
        --password)
            PASSWORD=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

lsof -Pi :3306 -sTCP:LISTEN -t || {
    docker run --name $NAME -p 3306:3306 -e MYSQL_DATABASE=$DATABASE -e MYSQL_USER=$USER -e MYSQL_PASSWORD=$PASSWORD -d mysql/mysql-server:5.7
}

while [ $(docker inspect --format "{{json .State.Health.Status }}" $NAME) != '"healthy"' ]; do echo "Waiting for Mysql Container..."; sleep 5; done
