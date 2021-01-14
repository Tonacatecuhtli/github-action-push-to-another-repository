#!/bin/bash

set -e  # if a command fails it stops the execution
echo "Starts"

echo "SOURCE_DIRECTORY $SOURCE_DIRECTORY"
echo "DESTINATION_GITHUB_USERNAME $DESTINATION_GITHUB_USERNAME"
echo "DESTINATION_REPOSITORY_NAME $DESTINATION_REPOSITORY_NAME"
echo "USER_EMAIL $USER_EMAIL"
echo "DESTINATION_REPOSITORY_USERNAME $DESTINATION_REPOSITORY_USERNAME"
echo "TARGET_BRANCH $TARGET_BRANCH"
echo "COMMIT_MESSAGE $COMMIT_MESSAGE"
echo "TARGET_REPO_DIRECTORY $TARGET_REPO_DIRECTORY"

set -u  # script fails if trying to access to an undefined variable
if [ -z "$DESTINATION_REPOSITORY_USERNAME" ]
then
  DESTINATION_REPOSITORY_USERNAME="$DESTINATION_GITHUB_USERNAME"
fi

CLONE_DIR=$(mktemp -d)

echo "Cloning destination git repository"
# Setup git
git config --global user.email "$USER_EMAIL"
git config --global user.name "$DESTINATION_GITHUB_USERNAME"
echo "Cloning: git@github.com:$DESTINATION_REPOSITORY_USERNAME/$DESTINATION_REPOSITORY_NAME.git"
git clone --single-branch --branch "$TARGET_BRANCH" "git@github.com:$DESTINATION_REPOSITORY_USERNAME/$DESTINATION_REPOSITORY_NAME.git" "$CLONE_DIR"
ls -la "$CLONE_DIR"

TARGET_DIR=$(mktemp -d)
mv "$CLONE_DIR/.git" "$TARGET_DIR"

echo "Copying contents to git repo"
cp -ra "$SOURCE_DIRECTORY"/. "$TARGET_DIR"/"$TARGET_REPO_DIRECTORY"/
cd "$TARGET_DIR"/"$TARGET_REPO_DIRECTORY"/

echo "Files that will be pushed"
ls -la

echo "Adding git commit"
if [ -z "$COMMIT_MESSAGE" ]
then
  COMMIT_MESSAGE="Update $DESTINATION_REPOSITORY_NAME from $GITHUB_REPOSITORY"
fi

git add .
git status

# git diff-index : to avoid doing the git commit failing if there are no changes to be commit
git diff-index --quiet HEAD || git commit --message "$COMMIT_MESSAGE"

echo "Pushing git commit"
# --set-upstream: sets de branch when pushing to a branch that does not exist
git push origin --set-upstream "$TARGET_BRANCH"
