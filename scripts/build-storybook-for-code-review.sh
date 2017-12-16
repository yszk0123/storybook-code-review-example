#!/bin/bash
set -eu

# Skip when components are not modified
if git diff master...HEAD --name-only | grep -q "src/\|stories/" ; then
  echo "[Storybook] Skip"
  exit 0
fi

# Skip when pull requests are not created
PULL_REQUEST_ID="${CI_PULL_REQUEST##*/pull/}"
if [ -z "$PULL_REQUEST_ID" ]; then
  echo "[Storybook] Skip"
  exit 0
fi

# Build storybook files and save as build artifacts
npm run build-storybook
mkdir -p "$CIRCLE_ARTIFACTS/storybook/"
mv storybook-static "$CIRCLE_ARTIFACTS"

# Post a pull request comment with the storybook link
STORYBOOK_URL="$CIRCLE_BUILD_URL/artifacts/$CIRCLE_NODE_INDEX/$CIRCLE_ARTIFACTS/storybook-static/index.html"
curl -X POST \
     -H "Authorization: bearer $GITHUB_API_TOKEN" \
     -H "Accept: application/vnd.github.v3.html+json" \
     -d "{\"body\":\"[Storybook] Created ([view stories]($STORYBOOK_URL))\"}" \
     "https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/issues/$PULL_REQUEST_ID/comments"
