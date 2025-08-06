#!/usr/bin/env bash

compute_drefs() {
  FILE="${1:-cachegrind.out}"
  events_line=$(grep "^events:" "$FILE")
  summary_line=$(grep "^summary:" "$FILE")

  read -ra EVENTS <<< "${events_line#events: }"
  read -ra VALUES <<< "${summary_line#summary: }"

  Dr=0
  Dw=0

  for i in "${!EVENTS[@]}"; do
    if [[ "${EVENTS[$i]}" == "Dr" ]]; then
      Dr="${VALUES[$i]}"
    elif [[ "${EVENTS[$i]}" == "Dw" ]]; then
      Dw="${VALUES[$i]}"
    fi
  done

  DREFS=$(( Dr + Dw ))
  return "$DREFS"
}
