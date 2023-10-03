#!/bin/bash

# Define the function
read -r -d '' PDM_FUNC <<'EOF'
pdm() {
  local command=$1

  if [[ "$command" == "shell" ]]; then
      eval $(pdm venv activate)
  else
      command pdm $@
  fi
}
EOF

# Append the function to bashrc
echo "$PDM_FUNC" >> ~/.bashrc

echo "Please, reboot the terminal and run 'source ~/.bashrc' to load the settings. Then run 'pdm shell' to enter the virtual environment."
