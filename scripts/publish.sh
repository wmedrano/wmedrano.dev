#!/bin/bash
# Publishes the contents. This is a bit hacky at the moment and should be rewritten.
#   - Must be run from the root directory.
#   - Publishes the contents of the "main" branch.
#   - Overwrites the "branches" git branch and publishes to the origin.

publish() {
    git checkout main || exit
    git branch -D pages || exit
    git checkout -b pages || exit
    hugo || exit
    git add . || exit
    git commit -m 'Publish contents.' || exit
    git push origin pages -f || exit
    git checkout main
}
