#!/bin/bash
# Скрипт-обертка для запуска Swift версии check
swift run --package-path Tools/Scripts scripts check "$@"
