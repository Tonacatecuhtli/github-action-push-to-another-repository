#!/bin/bash

set -e  # if a command fails it stops the execution
echo "Starts"

set -u  # script fails if trying to access to an undefined variable

CLONE_DIR=$(mktemp -d)

echo "Cloning destination git repository"
# Setup git
git config --global user.email "$USER_EMAIL"
git config --global user.name "$USER_NAME"
echo "Cloning: git@github.com:$DESTINATION_GITHUB_REPOSITORY_USERNAME/$DESTINATION_GITHUB_REPOSITORY_NAME.git"
git clone --single-branch --branch "$TARGET_BRANCH" "git@github.com:$DESTINATION_GITHUB_REPOSITORY_USERNAME/$DESTINATION_GITHUB_REPOSITORY_NAME.git" "$CLONE_DIR"
ls -la "$CLONE_DIR"

echo "Create destination repository folder if not existent"
mkdir -p "$CLONE_DIR"/"$DESTINATION_REPOSITORY_FOLDER"

echo "Delete destination files to handle deletions"
rm -rf "${CLONE_DIR:?}/$DESTINATION_REPOSITORY_FOLDER/*"

echo "Copying contents to git repo"
cp -ra "$SOURCE_DIRECTORY"/. "$CLONE_DIR"/"$DESTINATION_REPOSITORY_FOLDER"/
cd "$CLONE_DIR"/"$DESTINATION_REPOSITORY_FOLDER"/

echo "Files that will be pushed"
ls -la

echo "Adding git commit"
if [ -z "$COMMIT_MESSAGE" ]
then
  COMMIT_MESSAGE="Updated"
fi

git add .
git status

# git diff-index : to avoid doing the git commit failing if there are no changes to be commit
git diff-index --quiet HEAD || git commit --message "$COMMIT_MESSAGE
Folder: $DESTINATION_REPOSITORY_FOLDER
Source repository: $GITHUB_REPOSITORY
Source branch: $GITHUB_REF
Source commit: $GITHUB_SHA
User-Email: $USER_EMAIL"

echo "Pushing git commit"
# --set-upstream: sets de branch when pushing to a branch that does not exist
git push origin --set-upstream "$TARGET_BRANCH"
