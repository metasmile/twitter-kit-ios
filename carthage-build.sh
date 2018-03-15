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

cd "${PRODUCTS_DIR}"

if [ ! -e "${ZIP_DIR}" ]; then
    mkdir "${ZIP_DIR}"
    echo "Create ${ZIP_DIR} directory"
fi

cd "${WORKING_DIR}"

carthage build --platform iOS --no-skip-current "${MODULE_NAME}"

echo ""
echo "*** Creating framework.zip from Carthage directory ***"
echo ""
zip -r "${ZIP_PATH}" "Carthage"

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

if [ -a "${TEMP_PATH}" ]; then
    rm -f "${TEMP_PATH}"
fi

touch "${TEMP_PATH}"

if [ -f "${JSON_PATH}" ]; then
    while read line
    do
        # Ignore last line
        if [ "${line}" != "}" ]; then

            # If line has VERSION_NUM, not added
            if [ "$(echo ${line} | grep ${VERSION_NUM})" = "" ]; then

                if [ "${line}" = "{" ]; then
                    echo "${line}" >> "${TEMP_PATH}"
                else

                    # If line does not have ',',  add to tail
                    if [ "$(echo ${line} | grep ,)" = "" ]; then
                        echo -e "\t${line}," >> "${TEMP_PATH}"
                    else
                        echo -e "\t${line}" >> "${TEMP_PATH}"
                    fi
                fi
            fi
        fi
    done < "${JSON_PATH}"
else
    echo "{" >> "${TEMP_PATH}"
fi

echo -e "\t\"${VERSION_NUM}\": \"${URL}\"" >> "${TEMP_PATH}"
echo "}" >> "${TEMP_PATH}"

mv "${TEMP_PATH}" "${JSON_PATH}"

echo "*** ${MODULE_NAME} build process finished ***"
