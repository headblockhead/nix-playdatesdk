# Create the standard environment.
source $stdenv/setup
# Extract the source code.
tar xvfz $sdksrc
# Store the SDK in a place where it is accessible and writeable
mkdir -p $out/opt/playdate_sdk-1.12.3
# Create place to store the binaries.
mkdir -p $out/bin
# Copy the bin directory to the output binary directory.
cp -r PlaydateSDK-1.12.3/* $out/opt/playdate_sdk-1.12.3
# Make symlinks to the binaries.
ln -s $out/opt/playdate_sdk-1.12.3/bin/PlaydateSimulator $out/bin/PlaydateSimulatorFromSDK
ln -s $out/opt/playdate_sdk-1.12.3/bin/pdc $out/bin/pdcFromSDK
ln -s $out/opt/playdate_sdk-1.12.3/bin/pdutil $out/bin/pdutilFromSDK
# Patch the SDK to use the proper binaries and not the binaries from the SDK itself.
patch -i $patch1src $out/opt/playdate_sdk-1.12.3/C_API/buildsupport/common.mk
patch -i $patch2src $out/opt/playdate_sdk-1.12.3/C_API/buildsupport/playdate.cmake
