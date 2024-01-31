# Squad Claimer for Squad

Squad Claimer is a simple and lightweight tool for the game Squad, written in AutoHotkey, that can automatically and near instantaneously create a new squad when joining a server or a new round, which allows for a convenient name claim at match start

## Main Features

* Automatic squad creation at the start of every new round

* Extremely fast squad creation before the level is even loaded

* Easily customizable features, such as squad name, hotkey, etc. 

## Requirements

* A 64-bit Windows system

* A copy of Squad

* AutoHotkey v1.1+*
  
  **only if running the script through the AHK file, the executable is entirely standalone*

## Setup & Usage

* Download the latest Release from GitHub and unzip it

* Run the executable

* Adjust the tool to your preferences, either through the GUI or by modifying the config.ini
  
  * Make sure to adjust the script Hotkey to the one that fits your liking
  
  * Make sure to change the Game Console Key to the key that opens up your in-game console window
  
  * If you notice high CPU usage, you can increase the script interval (e.g. 1000 ms)

## Considerations & Limitations

* The Squad game window needs to be opened (in focus) for the Squad Claimer to be able to create a squad (planned!)

* There is currently no way to manually create a squad using Squad Claimer (planned!)

* May not work in offline training

## Future

There are several new features that might be added in the future and ways in which existing ones might be improved:

* Ability for the script to interact with the background window

* Optional button for squad creation

* Better round-start detection for even faster squad creation

* Allow easier and more convenient hotkey setting through the GUI

* Etc.

## Development & Contributions

### Development Notes

* Written in AutoHotkey v1.1

* Compiled with Ahk2Exe

### How to Contribute

* If you've noticed a bug or wish to suggest a feature addition or improvement, feel free to open an issue on GitHub

* If you wish to improve the existing code or make new additions, feel free to create a pull request

## Credits

This project uses external libraries, credits to their respective authors.

* AddTooltip by Superfraggle, art and jballi
