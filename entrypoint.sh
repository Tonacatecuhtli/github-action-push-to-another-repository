#!/bin/bash

set -e  # if a command fails it stops the execution
echo "Starts"

echo "SOURCE_DIRECTORY $SOURCE_DIRECTORY"
echo "TARGET_BRANCH $TARGET_BRANCH"
echo "USER_EMAIL $USER_EMAIL"
echo "USER_NAME $USER_NAME"
echo "DESTINATION_GITHUB_REPOSITORY_USERNAME $DESTINATION_GITHUB_REPOSITORY_USERNAME"
echo "DESTINATION_GITHUB_REPOSITORY_NAME $DESTINATION_GITHUB_REPOSITORY_NAME"
echo "DESTINATION_REPOSITORY_FOLDER $DESTINATION_REPOSITORY_FOLDER"
echo "COMMIT_MESSAGE $COMMIT_MESSAGE"

set -u  # script fails if trying to access to an undefined variable

CLONE_DIR=$(mktemp -d)

echo "Cloning destination git repository"
# Setup git
git config --global user.email "$USER_EMAIL"
git config --global user.name "$USER_NAME"
echo "Cloning: git@github.com:$DESTINATION_GITHUB_REPOSITORY_USERNAME/$DESTINATION_GITHUB_REPOSITORY_NAME.git"
git clone --single-branch --branch "$TARGET_BRANCH" "git@github.com:$DESTINATION_GITHUB_REPOSITORY_USERNAME/$DESTINATION_GITHUB_REPOSITORY_NAME.git" "$CLONE_DIR"
ls -la "$CLONE_DIR"

TARGET_DIR=$(mktemp -d)
mv "$CLONE_DIR/.git" "$TARGET_DIR"

echo "Copying contents to git repo"
cp -ra "$SOURCE_DIRECTORY"/. "$TARGET_DIR"/"$DESTINATION_REPOSITORY_FOLDER"/
cd "$TARGET_DIR"/"$DESTINATION_REPOSITORY_FOLDER"/

echo "Files that will be pushed"
ls -la

echo "Adding git commit"
if [ -z "$COMMIT_MESSAGE" ]
then
  COMMIT_MESSAGE="Updated $DESTINATION_GITHUB_REPOSITORY_NAME from $GITHUB_REPOSITORY with user $USER_EMAIL"
fi

git add .
git status

# git diff-index : to avoid doing the git commit failing if there are no changes to be commit
git diff-index --quiet HEAD || git commit --message "$COMMIT_MESSAGE"

echo "Pushing git commit"
# --set-upstream: sets de branch when pushing to a branch that does not exist
git push origin --set-upstream "$TARGET_BRANCH"
