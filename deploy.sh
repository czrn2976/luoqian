#!/usr/bin/env bash
# ref: https://github.com/jekyll/jekyll

set -eu  # Exit on error or unset variable

PAGES_BRANCH="gh-pages"

init() {
  # Check if the script is running in a GitHub Actions environment
  if [[ -z ${GITHUB_ACTION+x} ]]; then
    echo "ERROR: Not allowed to deploy outside of the GitHub Action environment."
    exit 1
  fi
}

build() {
  # Run the Ruby script to generate the output
  bundle exec ruby "./scaffold.rb"
}

setup_gh() {
  if git show-ref --verify --quiet "refs/heads/$PAGES_BRANCH"; then
    git checkout -b "$PAGES_BRANCH"
  else
    git checkout "$PAGES_BRANCH"
  fi
}

flush() {
  shopt -s dotglob nullglob 

  for item in ./* .[^.]*; do
    # skip ./_output and CNAME
    if [[ "$item" != "./_output" && "$item" != "./CNAME" ]]; then
      rm -rf "$item"
    fi
  done

  shopt -u dotglob nullglob 

  # Move all generated files to the root directory
  mv ./_output/* ./
}

deploy() {
  # Configure Git user for the commit
  git config --global user.name "ZhgChgLiBot"
  git config --global user.email "no-reply@zhgchg.li"

  # Reset the current HEAD to prepare for new commits
  git update-ref -d HEAD
  git add -A
  git commit -m "[Automation] Site update No.${GITHUB_RUN_NUMBER}"

  # Push the new branch to the remote repository
  git push -u origin "$PAGES_BRANCH" --force
}

main() {
  init     # Initialize and validate environment
  setup_gh # Set up the gh-pages branch
  build    # Build the site
  flush
  deploy   # Deploy the site
}

# Execute the main function
main