#!/bin/sh

case "$1" in
    start)
        echo "Starting aesdsocket"
        start-stop-daemon -S aesdsocket -- -d
        ;;
    stop)
        echo "Stopping aesdsocket"
        start-stop-daemon -K aesdsocket
        ;;
    restart)
        echo "Restarting aesdsocket"
        start-stop-daemon -K aesdsocket
        sleep 1
        start-stop-daemon -S aesdsocket -- -d
        ;;
    status)
        if pgrep aesdsocketd > /dev/null; then
            echo "aesdsocket is running"
        else
            echo "aesdsocket is not running"
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
