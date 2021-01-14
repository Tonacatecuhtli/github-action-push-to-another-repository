#!/bin/bash

set -e  # if a command fails it stops the execution
set -u  # script fails if trying to access to an undefined variable

echo "Starts"
printenv
echo "#####################"
env
# Githup automatically creates ENV variabels with INPUT_<variable-name> from the actions.yml
# https://docs.github.com/en/free-pro-team@latest/actions/creating-actions/metadata-syntax-for-github-actions#inputs
echo "INPUT_SOURCE_DIRECTORY $INPUT_SOURCE_DIRECTORY"
echo "INPUT_DESTINATION_GITHUB_USERNAME $INPUT_DESTINATION_GITHUB_USERNAME"
echo "INPUT_DESTINATION_REPOSITORY_NAME $INPUT_DESTINATION_REPOSITORY_NAME"
echo "INPUT_USER_EMAIL $INPUT_USER_EMAIL"
echo "INPUT_DESTINATION_REPOSITORY_USERNAME $INPUT_DESTINATION_REPOSITORY_USERNAME"
echo "INPUT_TARGET_BRANCH $INPUT_TARGET_BRANCH"
echo "INPUT_COMMIT_MESSAGE $INPUT_COMMIT_MESSAGE"
echo "INPUT_TARGET_REPO_DIRECTORY $INPUT_TARGET_REPO_DIRECTORY"

if [ -z "$INPUT_DESTINATION_REPOSITORY_USERNAME" ]
then
  INPUT_DESTINATION_REPOSITORY_USERNAME="$INPUT_DESTINATION_GITHUB_USERNAME"
fi

CLONE_DIR=$(mktemp -d)

echo "Cloning destination git repository"
# Setup git
git config --global user.email "$INPUT_USER_EMAIL"
git config --global user.name "$INPUT_DESTINATION_GITHUB_USERNAME"
echo "Cloning: git@github.com:$INPUT_DESTINATION_REPOSITORY_USERNAME/$INPUT_INPUT_DESTINATION_REPOSITORY_NAME.git"
git clone --single-branch --branch "$INPUT_TARGET_BRANCH" "git@github.com:$INPUT_DESTINATION_REPOSITORY_USERNAME/$INPUT_DESTINATION_REPOSITORY_NAME.git" "$CLONE_DIR"
ls -la "$CLONE_DIR"

TARGET_DIR=$(mktemp -d)
mv "$CLONE_DIR/.git" "$TARGET_DIR"

echo "Copying contents to git repo"
cp -ra "$INPUT_SOURCE_DIRECTORY"/. "$TARGET_DIR"/"$INPUT_TARGET_REPO_DIRECTORY"/
cd "$TARGET_DIR"/"$INPUT_TARGET_REPO_DIRECTORY"/

echo "Files that will be pushed"
ls -la

echo "Adding git commit"
if [ -z "$INPUT_COMMIT_MESSAGE" ]
then
  INPUT_COMMIT_MESSAGE="Update $INPUT_DESTINATION_REPOSITORY_NAME from $GITHUB_REPOSITORY"
fi

git add .
git status

# git diff-index : to avoid doing the git commit failing if there are no changes to be commit
git diff-index --quiet HEAD || git commit --message "$INPUT_COMMIT_MESSAGE"

echo "Pushing git commit"
# --set-upstream: sets de branch when pushing to a branch that does not exist
git push origin --set-upstream "$INPUT_TARGET_BRANCH"
