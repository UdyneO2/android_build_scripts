#!/bin/bash
set -e
#Credit to Meghthedev for the initial script 

export PROJECTFOLDER="crdroid"
export PROJECTID="85"
export REPO_INIT="repo init -u https://github.com/crdroidandroid/android.git -b 11.0 --git-lfs --depth=1"
export BUILD_DIFFERENT_ROM="$REPO_INIT" # Change this if you'd like to build something else

craveclone(){
# Destroy Old Clones
if (grep -q "$PROJECTFOLDER" <(crave clone list --json | jq -r '.clones[]."Cloned At"')) || [ "${DCDEVSPACE}" == "1" ]; then   
   crave clone destroy -y /crave-devspaces/$PROJECTFOLDER || echo "Error removing $PROJECTFOLDER"
else
   rm -rf $PROJECTFOLDER || true
fi

# Create New clone
if [ "${DCDEVSPACE}" == "1" ]; then
   crave clone create --projectID $PROJECTID /crave-devspaces/$PROJECTFOLDER || echo "Crave clone create failed!"
   cd /crave-devspaces/$PROJECTFOLDER
else
   mkdir $PROJECTFOLDER
   cd $PROJECTFOLDER
   echo "Running $REPO_INIT"
   $REPO_INIT
fi
}

#craveclone

# Run inside foss.crave.io devspace
# Remove existing local_manifests
cd $PROJECTFOLDER
crave run --no-patch -- "rm -rf .repo/local_manifests && \

# Init Manifest
$BUILD_DIFFERENT_ROM && \

# clone source
rm -rf device/oppo/A37 vendor/oppo/A37 kernel/oppo/msm8939
git clone https://github.com/udyneos-prjkt/android_device_oppo_A37 -b lineage-18.1 device/oppo/A37
git clone https://github.com/UdyneO2/rb-vendor_oppo vendor/oppo
git clone https://github.com/UdyneO2/kernel_oppo_A37-old kernel/oppo/msm8939 --depth=1

 # Sync the repositories
 /opt/crave/resync.sh && \ 

# Set up build environment
source build/envsetup.sh && \

# Build the ROM
lunch lineage_A37-userdebug
mka bacon"

# cd ..

# # Clean up
# if grep -q "$PROJECTFOLDER" <(crave clone list --json | jq -r '.clones[]."Cloned At"') || [ "${DCDEVSPACE}" == "1" ]; then
  # crave clone destroy -y /crave-devspaces/$PROJECTFOLDER || echo "Error removing $PROJECTFOLDER"
# else  
  # rm -rf $PROJECTFOLDER || true
# fi
# Upload zips to Telegram
/opt/crave/telegram/upload.sh
