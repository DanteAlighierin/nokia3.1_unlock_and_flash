# Install mtkclient

cd mtkclient
pip install -r requirements.txt



#Unlock bootloader

python mtk xflash seccfg unlock


# Install Treble(GSI)

fastboot erase userdata
fastboot flash system system-arm64-ab.img
fastboot reboot
