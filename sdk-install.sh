# Create the standard environment.
source $stdenv/setup
# Extract the source code.
tar xvfz $src
# Store the libraries and extracted code.
mkdir -p $out/opt/playdate_sdk
# Create place to store the binaries.
mkdir -p $out/bin
# Copy the pact/bin directory to the output binary directory.
cp -r PlaydateSDK-1.12.3/* $out/opt/playdate_sdk
# Make symlinks to the binaries.
ln -s $out/opt/playdate_sdk/bin/PlaydateSimulator $out/bin/PlaydateSimulator
ln -s $out/opt/playdate_sdk/bin/pdc $out/bin/pdc
ln -s $out/opt/playdate_sdk/bin/pdutil $out/bin/pdutil
