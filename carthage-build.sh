#!/bin/bash

MODULE_NAME=${1:?"Must set module name"}
PROJ_DIR="$(cd $(dirname $0) && pwd)"
WORKING_DIR="${PROJ_DIR}/${MODULE_NAME}"
VERSIONS_PATH="${PROJ_DIR}/versions"

if [ ! -f "${VERSIONS_PATH}" ]; then
    echo "${VERSIONS_PATH} does not exist"
    exit 2
fi

VERSION_NUM=$(grep ${MODULE_NAME} "${VERSIONS_PATH}" | grep -oE '\d+.\d+.\d+')

if [ "${VERSION_NUM}" = "" ]; then
    echo "${MODULE_NAME} version not found in ${VERSIONS_PATH}"
    exit 3
fi

PRODUCTS_DIR="${WORKING_DIR}/Products"
CART_DIR="${WORKING_DIR}/Carthage"
ZIP_DIR="${PRODUCTS_DIR}/${VERSION_NUM}"
ZIP_PATH="${ZIP_DIR}/framework.zip"
TEMP_FRAMEWORK_PATH="${WORKING_DIR}/${MODULE_NAME}.framework.zip"

cd "${PRODUCTS_DIR}"

if [ ! -e "${ZIP_DIR}" ]; then
    mkdir "${ZIP_DIR}"
    echo "Create ${ZIP_DIR} directory"
fi

cd "${WORKING_DIR}"

carthage build --platform iOS --no-skip-current "${MODULE_NAME}"
carthage archive

if [ ! -f "${TEMP_FRAMEWORK_PATH}" ]; then
    echo "${TEMP_FRAMEWORK_PATH} does not exist"
    exit 4
fi

mv "${TEMP_FRAMEWORK_PATH}" "${ZIP_PATH}"

echo ""
echo "*** Removing Carthage directory ***"
rm -rf ${CART_DIR}

# Generate JSON file
JSON_PATH="${PROJ_DIR}/${MODULE_NAME}.json"
URL="https://github.com/abema/twitter-kit-ios/raw/develop/${MODULE_NAME}/Products/${VERSION_NUM}/framework.zip"
TEMP_PATH="${WORKING_DIR}/temp.json"

echo ""
echo "*** Creating ${MODULE_NAME}.json ***"
echo ""

if [ -f "${TEMP_PATH}" ]; then
    rm -f "${TEMP_PATH}"
fi

if [ -s "${JSON_PATH}" ]; then
    if [ "$(grep "${VERSION_NUM}" "${JSON_PATH}")" = "" ]; then
        # If version number does not exist, insert newline
        sed -e 's/"$/",/g' -e '/^}$/d' "${JSON_PATH}" > "${TEMP_PATH}"
        echo -e "\t\"${VERSION_NUM}\": \"${URL}\"\n}" >> "${TEMP_PATH}"
    else
        # If version number exists, replace line
        REGEX="s|\"${VERSION_NUM}\": \(.*\)|\"${VERSION_NUM}\": \"${URL}\"|g"
        sed -e "${REGEX}" "${JSON_PATH}" > "${TEMP_PATH}"
    fi
    mv "${TEMP_PATH}" "${JSON_PATH}"
else
    # Create Json file if file does not exist or is empty
    echo -e "{\n\t\"${VERSION_NUM}\": \"${URL}\"\n}" > "${JSON_PATH}"
fi

echo "*** ${MODULE_NAME} build process finished ***"
