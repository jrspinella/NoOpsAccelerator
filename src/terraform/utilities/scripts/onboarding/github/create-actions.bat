@echo off
REM // ----------------------------------------------------------------------------------
REM // Copyright (c) Microsoft Corporation.
REM // Licensed under the MIT license.
REM //
REM // THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
REM // EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES
REM // OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
REM // ----------------------------------------------------------------------------------

echo.
echo Creating GitHub actions in the context of:
echo.
echo   GH Account:              %GH_ORG%
echo   GH Project:                   %GH_PROJECT_NAME%
echo   Repository Name/URL:              %GH_REPO_NAME_OR_URL%
echo   Repository Type:                  %GH_REPO_TYPE%
echo   Repository Branch ^& Environment:  %GH_REPO_BRANCH%
echo   Actions Suffix:            %GH_PIPELINE_NAME_SUFFIX%
echo.
choice /C YN /M "Do you want to proceed?"
if errorlevel 2 exit /b 0

REM Process all pipeline definitions
for %%N in (management-groups roles platform-logging policy platform-connectivity-hub-nva platform-connectivity-hub-azfw platform-connectivity-hub-azfw-policy subscriptions) do (

    REM Check for pipeline existence
    set FOUND=
    for /f usebackq %%F in (`call az actions list -o tsv --query="[?name=='%%N%GH_PIPELINE_NAME_SUFFIX%'].name | [0]"`) do set FOUND=true

    REM Only create GitHub actions if it does *not* already exist
    if not defined FOUND (
        echo Creating GitHub action [%%N%GH_PIPELINE_NAME_SUFFIX%]...
        call az actions create --name "%%N%GH_PIPELINE_NAME_SUFFIX%" --repository %GH_REPO_NAME_OR_URL% --repository-type %GH_REPO_TYPE% --branch %GH_REPO_BRANCH% --skip-first-run --yaml-path "/.actions/%%N.yml" --org %GH_ORG% --project %GH_PROJECT_NAME%
    ) else (
        echo Pipeline [%%N%GH_PIPELINE_NAME_SUFFIX%] already exists. Skipping creation.
    )
)

REM Get environments in the project
echo.
echo Retrieving list of environments for account [%GH_PROJECT_NAME%]..
call az GH invoke --organization "%GH_ORG%" --route-parameters project="%GH_PROJECT_NAME%" --http-method GET --api-version 6.0 --area distributedtask --resource environments -o json >%GH_OUTPUT_DIR%\environment.json

REM Check if environment matching repository branch name exists
set ENVIRONMENT=
echo Checking project for existing environment [%GH_REPO_BRANCH%]...
for /f "usebackq delims=" %%E in (`jq ".value[] | select(.name == \"%GH_REPO_BRANCH%\") | .name" %GH_OUTPUT_DIR%\environment.json`) do set ENVIRONMENT=%%~E

REM Create environment if it doesn't already exist
if not defined ENVIRONMENT (
    echo Creating environment [%GH_REPO_BRANCH%]...
    echo { "name": "%GH_REPO_BRANCH%" } >%GH_OUTPUT_DIR%\environment-body.json
    call az GH invoke --organization "%GH_ORG%" --route-parameters project="%GH_PROJECT_NAME%" --http-method POST --api-version 6.0 --area distributedtask --resource environments --in-file %GH_OUTPUT_DIR%\environment-body.json >nul
) else (
    echo Environment [%GH_REPO_BRANCH%] already exists. Skipping creation.
)

echo.
echo Now that an environment exists for the repository branch [%GH_REPO_BRANCH%],
echo learn more about configuring approvals and checks for deployments associated with this
echo environment by reviewing the following documentation:
echo    * https://docs.microsoft.com/azure/GH/actions/process/approvals
echo.
