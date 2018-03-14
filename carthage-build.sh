#!/bin/bash

moduleName=${1}

WORKING_DIR=$(cd $(dirname $0) && pwd)/${moduleName}
PRODUCTS_DIR=${WORKING_DIR}/Products
CART_DIR=${WORKING_DIR}/Carthage
BUILD_NUM=1

cd ${PRODUCTS_DIR}

while [ -e "${PRODUCTS_DIR}/${BUILD_NUM}/framework.zip" ]
do
echo "${PRODUCTS_DIR}/${BUILD_NUM}/framework.zip exsits"
BUILD_NUM=$((++BUILD_NUM))
done

if [ ! -e "${PRODUCTS_DIR}/${BUILD_NUM}" ]; then
    mkdir "${PRODUCTS_DIR}/${BUILD_NUM}"
    echo "Create ${PRODUCTS_DIR}/${BUILD_NUM} directory"
fi

cd ${WORKING_DIR}

carthage build --platform iOS --no-skip-current ${moduleName}

echo ""
echo "*** Creating framework.zip from Carthage directory ***"
echo ""
zip -r "${WORKING_DIR}/Products/${BUILD_NUM}/framework.zip" "Carthage"

echo ""
echo "*** Removing Carthage directory ***"
rm -rf ${CART_DIR}

echo "*** ${moduleName} build process finished ***"
