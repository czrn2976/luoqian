#!/usr/bin/env bash
# ref: https://github.com/jekyll/jekyll

set -eu

PAGES_BRANCH="gh-pages"

init() {
  if [[ -z ${GITHUB_ACTION+x}]]; then
    echo "ERROR: Not allowed to deploy outside of the GitHub Action envrionment."
    exit -1
  fi
}

build() {
  bundle exec ruby "./scaffold.rb"

  mv ./_output/* ./
}

setup_gh() {
  if git branch --list "$PAGES_BRANCH" > /dev/null; then
    echo "Branch '$PAGES_BRANCH' exists. Deleting and recreating it..."
    git branch -D "$PAGES_BRANCH"  # Delete the branch
  fi

  # Create and switch to the branch
  git checkout -b "$PAGES_BRANCH"
}

deploy() {
  git config --global user.name "ZhgChgLiBot"
  git config --global user.email "no-reply@zhgchg.li"

  git update-ref -d HEAD
  git add -A
  git commit -m "[Automation] Site update No.${GITHUB_RUN_NUMBER}"

  git push -u origin "$PAGES_BRANCH"
}

main() {
  init
  build
  setup_gh
  deploy
}

main
