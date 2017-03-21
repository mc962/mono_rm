#!/usr/bin/env sh

dropdb dragons
createdb dragons
sqlite3 dragons.db < dragons.sql
