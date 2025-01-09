#!/bin/bash
echo "Installing dependencies for Bumblebee Status Bar modules..."
while IFS= read package; do
	echo "Installing $package" 
	sudo apt-get install "$package"
done < ./bee_bar_deps.txt
echo "Done..."
