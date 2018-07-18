#
# Usage:
#  build TwitterCore and TwitterKit
#
# Note:
#  Build products are put into ./Products
#  Please manually upload TwitterCore.zip and TwitterKit.zip to Github releases page

build:
	./carthage-build.sh TwitterCore
	./carthage-build.sh TwitterKit
