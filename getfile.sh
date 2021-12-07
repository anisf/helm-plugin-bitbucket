#!/bin/bash

set -e

URI=$@ # eg: gitlab://username/project:master/kubernetes/helm-chart, github-https://username/project:v1/path
PROVIDER=$(echo $URI | cut -d: -f1) # eg: gitlab, bitbucket
REPO=$(echo $URI | cut -d: -f2 | sed -e "s/\/\///") # eg: username/project
BRANCH=$(echo $URI | cut -d: -f3 | cut -d/ -f1) # eg: master
FILEPATH=$(echo $URI | cut -d: -f3 | sed -e "s/$BRANCH\///") # eg: kubernetes/helm-chart

# make a temporary dir
TMPDIR="$(mktemp -d)"
cd $TMPDIR

git init --quiet
if [ "bitbucket" = $PROVIDER ]; then
  git remote add origin git@bitbucket.org:$REPO.git
elif [[ $PROVIDER == *-https ]]; then
  PROVIDER_HOST=$(echo $PROVIDER | cut -d- -f1)
  git remote add origin https://$PROVIDER_HOST.com/$REPO.git
else
  git remote add origin git@$PROVIDER.com:$REPO.git
fi
git pull --depth=1 --quiet origin $BRANCH

# remove the temporary dir
rm -rf $TMPDIR
