#!/bin/sh

# Runs a test which verifies that all dependencies inside ip-bom's <dependencyManagement> are available (downloadable).
#
# Test copies current ip-bom, removes the <dependencyManagement> XML elements and tries to resolve all the dependencies using
# "clean dependency:tree" Maven build. In case one of the dependencies is not available the build fails.


# Determine and use the current script dir, so that the script can be called from any working directory and still work correctly
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

rm -f ${SCRIPT_DIR}/pom.xml
cp ${SCRIPT_DIR}/pom-template.xml ${SCRIPT_DIR}/pom.xml

# Extract dependencies from the ip-bom, remove <version> tags and <import> scope tags
TMP_DEPS_FILE=${SCRIPT_DIR}/target/tmp-ip-bom-deps.txt
mkdir -p ${SCRIPT_DIR}/target
IP_BOM_POM_XML="${SCRIPT_DIR}/../ip-bom/pom.xml"

# Replace marker with actual version
VERSION=`sed -e '/<parent>/,/<\/parent>/!d' ${IP_BOM_POM_XML} | grep "<version>" | sed -e 's/.*<version>//g' | sed -e 's/<\/version>.*//g'`
sed -i -e "s/@VERSION@/${VERSION}/g" ${SCRIPT_DIR}/pom.xml

# Effective pom needs to be created to make sure all the dependencies from imported BOMs are properly extracted
mvn help:effective-pom -f ${IP_BOM_POM_XML} | sed -n '/<dependencyManagement>/,/<\/dependencyManagement>/p' | sed -n '/<dependencies>/,/<\/dependencies>/p' | grep -v "<version>" > ${TMP_DEPS_FILE}
# Replace marker with the actual dependencies
sed -i -e "/<!--@DEPS@-->/{r ${TMP_DEPS_FILE}" -e 'd}' ${SCRIPT_DIR}/pom.xml

# Dependency:resolve will resolve and download all direct dependencies (and their transitive dependencies as well)
mvn -U -f ${SCRIPT_DIR}/pom.xml -B -e clean dependency:resolve -s ${SCRIPT_DIR}/ip-bom-deps-available-test-settings.xml $@
