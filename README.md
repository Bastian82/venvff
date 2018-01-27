# venvff
Python virtualenv manager for fish shell

This simple script for fish shell will help to manage multiple python virtual environments, especially in case
of having many of it on workstation.
This script is equivalent for virtualenvwrapper dedicated to bash shell.

####Instalation
Script works as a custom user function. All you need to do is to download
the script and copy it to user local fish directory.

```bash
cp venvff.fish ~/.config/fish/functions/
```

####Usage

```bash
Usage: venvff [-h|--help] [--optional] [positional] [NAME]
Python virtualenv management for fish shell
Positional parameters:
create    --create new virtual environment
destroy   --destroy virtual environment
workon    --switch virtual environment
exit      --deactivate current virtual environment
list      --list virtual environments
```

```bash
# venvff create --help
Optional parameters:
--desc     -describe new virtual environment
--params   -set additional options provided by virtualenv, separated by semicolon. For example 'python=python3.5;no-download;no-pip'
```