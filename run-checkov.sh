#!/usr/bin/env bash
set -euo pipefail
checkov -d . --framework terraform --download-external-modules false
