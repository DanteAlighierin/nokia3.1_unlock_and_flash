#!/bin/bash

function checkMtkclient
{
  echo "[*] Checking installation of mtkclient"

  if ! [ -d mtkclient ]
  then
    echo '[!] Mtkclient not found, trying to install...'
    installMtkclient
  fi

  echo "[*] Mtkclient detected"
}

function checkMagisk
{
  echo "[*] Checking installation of magisk"

  if ! [ -d magisk ]
  then
    echo '[!] Magisk not found, trying to install...'
    installMagisk
  fi
}

function installMtkclient
{
  if ! command -v git &> /dev/null
  then
      echo "[!] Git not found, exiting..."
      exit 1
  fi

  git clone -b main https://github.com/bkerler/mtkclient

  if ! command -v pip3 &> /dev/null || ! command -v python &> /dev/null
  then
      echo "[!] Python or pip not found, exiting..."
      exit 1
  fi

  cd mtkclient

  pip3 install -r requirements.txt
  python3 setup.py build
  sudo python3 setup.py install

  echo "[*] Mtkclient has been sucessfully installed!"
}

function confirmation
{
  read -p "Continue? (press \"y\" or \"n\") " CONFIRM
  if [ "$CONFIRM" == "y" ]
  then
    echo 1
  else
    echo 0
  fi
}

function mainMenu
{
  clear
  
  echo "What do you want to do?"
  echo "1. Unlock bootloader"
  echo "2. Lock bootloader"
  echo "3. Install Treble (GSI)"
  #echo "4. Root the phone"
  echo "4. Quit"

  printf "\n"
  
  read -p "Enter a number: " TODO
  
  case $TODO in
    1)
      bootloader unlock
      ;;
    
    2)
      bootloader lock
      ;;
      
    3)
      installTreble
      printf "\n\n"
      ;;
      
    #4)
      #installMagisk
      #;;
      
    4)
      exit 0
      ;;
    
    *)
      echo "[!] Unknown number.. Press [ENTER] for return to main menu"
      read
      mainMenu
      ;;
  esac
}

function bootloader
{
  checkMtkclient
  sudo mtk xflash seccfg $1
  printf "\n\n"
  read -p "[?] Bootloader unlocked! Press [ENTER] for return to main menu"
  mainMenu
}

function installTreble
{
  if ! command -v fastboot &> /dev/null
  then
      echo "[!] Fastboot not found, exiting..."
      exit 1
  fi
  
  if ! [ -f system.img ]
  then
    read -p "[?] System.img not found, please put it on this directory, and press [ENTER] for refresh or [Q] for quit" TODO
    case $TODO in
      q)
        mainMenu
        ;;
      
      *)
        installTreble
        ;;
        
    esac
  fi
  
  echo "THIS ACTION WILL WIPE YOUR DATA"
  if [ $(confirmation) -eq 0 ]
  then
    mainMenu
  fi

  printf "\n\n"
  
  echo "[?] Please connect device in FASTBOOT mode"
  
  fastboot erase userdata
  fastboot flash system system.img
  fastboot reboot

  printf "\n\n"
  
  read -p "[?] Press [ENTER] for return to main menu"
  mainMenu
}

function installMagisk
{
  checkMtkclient
  checkMagisk

  #TODO
}

mainMenu
