#!/bin/bash
set -e

USER=nginx

if [ -n "$UID" ] && [ -n "$GID" ]; then
	usermod -u $UID $USER
	groupmod -g $GID $USER
fi

exit 0
