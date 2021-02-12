#!/bin/bash
set -e

USER=daemon

if [ -n "$UID" ] && [ -n "$GID" ]; then
	usermod -u $UID $USER
	groupmod -g $GID $USER
fi

exec "$@"