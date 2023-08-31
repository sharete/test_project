:: Umgebungsvariable PROXY_WRAPPER muss definiert sein
@echo off
setlocal

:: Aktuellen Git Branch ermitteln
:: https://superuser.com/a/1662605
set GIT_BRANCH=
for /F "delims=" %%n in ('git branch --show-current') do set "GIT_BRANCH=%%n"

:: Variablen für Terraform setzen
set TF_WORKSPACE=%GIT_BRANCH%
set TF_CLI_ARGS_plan=--var-file=tf-%GIT_BRANCH%.tfvars
set TF_CLI_ARGS_apply=--var-file=tf-%GIT_BRANCH%.tfvars
set TF_CLI_ARGS_destroy=--var-file=tf-%GIT_BRANCH%.tfvars
set TF_CLI_ARGS_init=--var-file=tf-%GIT_BRANCH%.tfvars
set TF_CLI_ARGS_import=--var-file=tf-%GIT_BRANCH%.tfvars

:: Terraform aufrufen
terraform.exe %*
endlocal