#!/bin/env sh

# Runs a test which verifies that all dependencies inside ip-bom's <dependencyManagement> are available (downloadable).
#
# Test copies current ip-bom, removes the <dependencyManagement> XML elements and tries to resolve all the dependencies using
# "clean dependency:tree" Maven build. In case one of the dependencies is not available the build fails.


# Determine and use the current script dir, so that the script can be called from any working directroy and still work correctly
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

rm -f ${SCRIPT_DIR}/pom.xml
cp  ${SCRIPT_DIR}/../ip-bom/pom.xml ${SCRIPT_DIR}/pom.xml

sed -i 's/jboss-integration-platform-bom/jboss-integration-platform-bom-deps-available-test/g' ${SCRIPT_DIR}/pom.xml
sed -i 's/Platform BOM/Platform BOM - Dependencies Available Test/g' ${SCRIPT_DIR}/pom.xml
# Remove  dependencyManagement XML elements
sed -i 's/<dependencyManagement>//g' ${SCRIPT_DIR}/pom.xml
sed -i 's/<\/dependencyManagement>//g' ${SCRIPT_DIR}/pom.xml
# Remove 'import' scope from the imported BOMs to avoid Maven warnings ('import' scope is only valid inside depMgmt section)
sed -i 's/<scope>import<\/scope>//g' ${SCRIPT_DIR}/pom.xml

# Run the build with disabled enforcer to avoid failures for 'no-managed-deps' rule (versions of dependencies in this test POM
# are not managed)
mvn -f ${SCRIPT_DIR}/pom.xml -B -e clean dependency:tree -Denforcer.skip=true -s ${SCRIPT_DIR}/ip-bom-deps-available-test-settings.xml $@
