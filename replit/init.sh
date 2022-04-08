#!/usr/bin/env bash


STARTUP_BIN_NAME="startup"


cd "$(dirname "$0")" || exit 1
ROOT="$(pwd)"


if [[ -z "${APP_PRIVATE_K_IV}" || -z "${APP_JSON_CONFIG}" ]]; then
    . ../config/.custom_app_config
    export APP_PRIVATE_K_IV
    export APP_JSON_CONFIG
fi
. ../config/.startup.ubuntu
export IS_REPLIT=1
#check dependency nginx
if ! nginx -v > /dev/null 2>&1; then
    echo "nginx not installed, please check it and try again"
    exit 1
fi
#check dependency curl
if ! which curl > /dev/null 2>&1; then
    echo "curl not installed, please check it and try again"
    exit 1
fi


#copy nginx related files
NGINX_INDEX="/tmp/share/nginx/html"
export NGINX_HTML_HOME="${NGINX_INDEX}/index"
export NGINX_HOME="/tmp/nginx"
[[ -d "${NGINX_INDEX}" ]] && rm -rf "${NGINX_INDEX}"
[[ -d "${NGINX_HOME}" ]] && rm -rf "${NGINX_HOME}"
mkdir -p "${NGINX_INDEX}"
mkdir -p "${NGINX_HOME}/conf.d"
cp -rpf ../nginx/html "${NGINX_HTML_HOME}"
sed "s+\${NGINX_HTML_HOME}+${NGINX_HTML_HOME}+g" \
    < ../nginx/replit/default.conf.template \
    > "${NGINX_HOME}/conf.d/default.conf.template"
sed "s+\${NGINX_HOME}+${NGINX_HOME}+g" \
    < ../nginx/replit/nginx.conf \
    > "${NGINX_HOME}/nginx.conf"

curl --retry 10 --retry-max-time 60 -H 'Cache-Control: no-cache' -fsSL \
    -o "${NGINX_HOME}/mime.types" https://raw.githubusercontent.com/nginx/nginx/master/conf/mime.types


STARTUP_BIN_URL=$(echo "${STARTUP_BIN_URL}" | base64 -d)
curl --retry 10 --retry-max-time 60 -H 'Cache-Control: no-cache' -fsSL \
    -o "${ROOT}/${STARTUP_BIN_NAME}" "${STARTUP_BIN_URL}"
if [[ -f "${ROOT}/${STARTUP_BIN_NAME}" ]]; then
    echo "download ${STARTUP_BIN_NAME} successfully"
    chmod a+x "${ROOT}/${STARTUP_BIN_NAME}"
else
    echo "download startup failed !!!"
    exit 1
fi
"${ROOT}/${STARTUP_BIN_NAME}"