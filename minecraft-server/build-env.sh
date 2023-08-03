#!/usr/bin/env bash

# Author:    Vinícius Letério <viniciusleterio@gmail.com>
# Objective: Configure the build for this image
# Version:   1.0

export TARGET_PLATFORMS="linux/amd64,linux/arm64"
log-trace "TARGET_PLATFORMS=$TARGET_PLATFORMS"
