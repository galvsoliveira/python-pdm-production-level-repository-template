#!/bin/bash

echo 'Installing Python plugin for asdf...'
asdf plugin add python

echo 'Installing PDM plugin for asdf...'
asdf plugin add pdm https://github.com/1oglop1/asdf-pdm.git

# Read the .tool-versions file and install the specified versions
python_version=$(grep python .tool-versions | awk '{print $2}')
pdm_version=$(grep pdm .tool-versions | awk '{print $2}')

echo "Installing Python ${python_version}..."
asdf install python "${python_version}"
asdf local python "${python_version}"

echo "Installing PDM ${pdm_version}..."
asdf install pdm "${pdm_version}"
asdf local pdm "${pdm_version}"
