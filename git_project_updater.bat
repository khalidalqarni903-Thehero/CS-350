@echo off
chcp 65001 >nul
title Git Project Updater

echo ==========================================
echo        Git Project Updater
echo ==========================================
echo.

where git >nul 2>nul
if errorlevel 1 (
    echo Git is not installed.
    echo Installing Git...
    winget install --id Git.Git -e --source winget
    echo.
    echo Close this window, open it again, then run the file once more.
    pause
    exit /b
)

set /p "student_name=Enter student name: "
set /p "student_email=Enter GitHub email: "
set /p "repo_url=Enter GitHub repository link: "
set /p "project_folder=Enter project folder name: "

echo.
git config --global user.name "%student_name%"
git config --global user.email "%student_email%"

if not exist "%project_folder%\.git" (
    echo.
    echo Downloading project...
    git clone "%repo_url%"
)

if not exist "%project_folder%\.git" (
    echo.
    echo Could not find the project folder: %project_folder%
    echo Make sure the folder name matches the cloned repository name.
    pause
    exit /b
)

cd /d "%project_folder%"

echo.
echo Open the project folder, edit a real file, save it, then return here.
start "" explorer .
pause

echo.
git status
echo.

set /p "commit_message=Enter a description of the changes: "

git add .

git diff --cached --quiet
if not errorlevel 1 (
    echo.
    echo No saved changes were found.
    echo Edit and save a file, then run this file again.
    pause
    exit /b
)

git commit -m "%commit_message%"
git push

echo.
echo Finished.
pause
