#!/bin/sh

# Push the source file to the server
tx push -s

# Download completed translations from transifex
tx pull -a --minimum-perc=100
