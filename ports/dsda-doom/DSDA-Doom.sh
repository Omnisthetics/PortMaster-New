#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt

get_controls

GAMEDIR=/$directory/ports/dsda-doom
CONFDIR="$GAMEDIR/conf"

mkdir -p "$CONFDIR"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO rm -rf ~/.dsda-doom
ln -sfv $CONFDIR ~/.dsda-doom

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ "$CFW_NAME" == "muOS" ]; then
  rm -f "./libs.${DEVICE_ARCH}/libzip.so.5"
  rm -f "./libs.${DEVICE_ARCH}/libmad.so.0"
  rm -f "./libs.${DEVICE_ARCH}/libreadline.so.8"
  rm -f "./libs.${DEVICE_ARCH}/libtinfo.so.6"
elif [ "$CFW_NAME" == "ArkOS" || [ "$CFW_NAME" == "ArkOS wuMMLe"]; then
  rm -f "./libs.${DEVICE_ARCH}/libmad.so.0"
  rm -f "./libs.${DEVICE_ARCH}/libreadline.so.8"
  rm -f "./libs.${DEVICE_ARCH}/libtinfo.so.6"
fi

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "dsda-doom" &
./dsda-doom

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
