#!/bin/bash

if [ "${1}" = "" ]; then
    echo "Must set module name"
    exit 1
fi

MODULE_NAME=${1}
PROJ_DIR="$(cd $(dirname $0) && pwd)"
WORKING_DIR="${PROJ_DIR}/${MODULE_NAME}"
VERSION_NUM="$(cat ${PROJ_DIR}/versions | grep ${MODULE_NAME} | grep -oe '\d.\d.\d')"
PRODUCTS_DIR="${WORKING_DIR}/Products"
CART_DIR="${WORKING_DIR}/Carthage"
ZIP_DIR="${PRODUCTS_DIR}/${VERSION_NUM}"
ZIP_PATH="${ZIP_DIR}/framework.zip"

cd ${PRODUCTS_DIR}

if [ ! -e "${ZIP_DIR}" ]; then
    mkdir "${ZIP_DIR}"
    echo "Create ${ZIP_DIR} directory"
fi

cd ${WORKING_DIR}

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
TMEP_PATH="${WORKING_DIR}/temp.json"

echo ""
echo "*** Creating ${MODULE_NAME}.json ***"
echo ""

if [ -a "${TMEP_PATH}" ]; then
    rm -f "${TMEP_PATH}"
fi

touch "${TMEP_PATH}"

if [ -f "${JSON_PATH}" ]; then
    while read line
    do
        # Ignore last line
        if [ "${line}" != "}" ]; then

            # If line has VERSION_NUM, not added
            if [ "$(echo ${line} | grep ${VERSION_NUM})" = "" ]; then

                if [ "${line}" = "{" ]; then
                    echo "${line}" >> "${TMEP_PATH}"
                else

                    # If line does not have ',',  add to tail
                    if [ "$(echo ${line} | grep ,)" = "" ]; then
                        echo -e "\t${line}," >> "${TMEP_PATH}"
                    else
                        echo -e "\t${line}" >> "${TMEP_PATH}"
                    fi
                fi
            fi
        fi
    done < "${JSON_PATH}"
else
    echo "{" >> "${TMEP_PATH}"
fi

echo -e "\t\"${VERSION_NUM}\": \"${URL}\"" >> "${TMEP_PATH}"
echo "}" >> "${TMEP_PATH}"

mv "${TMEP_PATH}" "${JSON_PATH}"

echo "*** ${MODULE_NAME} build process finished ***"
