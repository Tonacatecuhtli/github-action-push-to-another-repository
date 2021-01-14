#!/bin/sh -ex

# Inspired from
#https://github.com/johno/actions-push-subdirectories/blob/master/entrypoint.sh#L10

SOURCE_FOLDER="$1"
DESTINATION_FOLDER="$2"
GITHUB_USERNAME="$3"
GITHUB_REPO="$4"
GITHUB_USER_EMAIL="$5"

CLONE_DIR=output_clone

apt-get update && apt-get install git
apk add --no-cache git

git config --global user.email "$GITHUB_USER_EMAIL"
git config --global user.name "$GITHUB_USERNAME"

echo "Clone $GITHUB_REPO"
git clone "git@github.com:$GITHUB_USERNAME/$GITHUB_REPO.git" "$CLONE_DIR"

echo "Delete old files to handle deletions"
rm -rf "${CLONE_DIR:?}/$DESTINATION_FOLDER/*"

echo "Copy new files"
cp -r "$SOURCE_FOLDER"/* "$CLONE_DIR"/"$DESTINATION_FOLDER"/

cd $CLONE_DIR
git add .
git commit --message "Update from $GITHUB_REPOSITORY"
git push origin master

echo "Done!"
