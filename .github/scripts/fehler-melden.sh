#!/usr/bin/env bash
# Schreibt die Fehlerblöcke aus einer Log-Datei als GitHub-Annotation,
# damit sie in der Übersicht des Laufs sichtbar sind.
set -u
log="${1:?Log-Datei fehlt}"
msg=$(grep -A8 "Error:" "$log" | head -40 \
  | sed -e 's/%/%25/g' -e 's/\r/%0D/g' | awk 'BEGIN{ORS="%0A"} {print}')
[ -n "$msg" ] || msg="Unbekannter Fehler, siehe Log."
echo "::error title=OpenTofu-Fehler::${msg}"
