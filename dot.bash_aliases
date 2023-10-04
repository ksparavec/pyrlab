export PYTHON_VERSION=`python --version`
export PROMPT_COMMAND="printf '\e[01;31m%s\e[m ' ${PYTHON_VERSION}"
export PS1="\e[01;32m\w\e[m\$ "
printf '\033[?12l'
