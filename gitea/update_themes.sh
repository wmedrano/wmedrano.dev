#!/usr/bin/bash

run () {
    GITEA_BASE=$(dirname -- "${BASH_SOURCE[0]}")
    # If the volume is owned by root, take ownership with:
    # sudo chown $USER ${GITEA_BASE}/data
    THEMES_DIR=${GITEA_BASE}/data/gitea/public/css
    curl https://raw.githubusercontent.com/acoolstraw/earl-grey/master/theme-earl-grey.css >${THEMES_DIR}/theme-earl-grey.css
    curl https://codeberg.org/Freeplay/Gitea-Modern/src/branch/main/Gitea/theme-gitea-modern.css >${THEMES_DIR}/theme-gitea-modern.css
    sed -i 's/THEMES.*=.*$/THEMES=gitea,gitea-modern,arc-green,earl-grey/' ${GITEA_BASE}/data/gitea/conf/app.ini
}

run
