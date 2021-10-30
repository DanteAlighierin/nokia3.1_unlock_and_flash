#!/bin/bash
e="\x1b[";
c=$e"39;49;00m";
y=$e"93;01m";
cy=$e"96;01m";
r=$e"1;91m";
g=$e"92;01m";
m=$e"95;01m";

function checkMtkclient
{
  echo -e "$y[*]$c Checking for mtkclient"

  if ! command -v mtk &> /dev/null
  then
    echo -e "$r[!]$c Mtkclient not found!"
    installMtkclient
  fi

  echo -e "$y[*]$c Mtkclient detected"
}

function checkMagisk
{
  echo -e "$y[*]$c Checking for Magisk"

  if ! [ -d magisk ]
  then
    echo -e "$r[!]$c Magisk not found, trying to install..."
    installMagisk
  fi
}

function installMtkclient
{
  if ! command -v git &> /dev/null
  then
      echo -e "$r[!]$c Git not found, exiting..."
      exit 1
  fi

  echo -e "$y[*]$c Clonning mtkclient..."

  git clone -b main https://github.com/bkerler/mtkclient &> /dev/null

  if ! command -v pip3 &> /dev/null || ! command -v python3 &> /dev/null
  then
      echo -e "$r[!]$c Python or pip not found, exiting..."
      exit 1
  fi

  cd mtkclient

  echo -e "$y[*]$c Installing dependencies..."
  pip3 install -r requirements.txt &> /dev/null

  echo -e "$y[*]$c Building..."
  python3 setup.py build &> /dev/null

  echo -e "$y[*]$c Installing..."
  sudo bash -c "python3 setup.py install &> /dev/null"

  echo -e "$y[*]$c Removing installation files..."
  sudo rm -rf mtkclient

  echo -e "$g[*]$c Mtkclient has been sucessfully installed!"
}

function confirmation
{
  read -p "Continue? (press \"y\" or \"n\"): " CONFIRM
  if [ "$CONFIRM" == "y" ]
  then
    echo 1
  else
    echo 0
  fi
}

function logo
{
  echo -e "
****************************************************
*                                                  *
*     $cy       Nokia 3.1 Unlock and flash          $c  *
* $c  Unlock bootloader and flash treble gsi rom     *
*         including support for$y Nokia 5.1$c          *
*                   $g LiNUX x64$c                     *
*                                                  *
*                                     $r by belkaliz$c *
****************************************************"
}

function mainMenu
{
  clear
  logo
  printf "\n"

  echo "===================================================="
  
  echo "What do you want to do?"
  echo -e "1.$g Unlock bootloader$c"
  echo -e "2.$r Lock bootloader$c"
  echo -e "3.$y Install Treble (GSI)$c"
  #echo "4. Root the phone"
  echo -e "4.$cy Quit$c"

  echo "===================================================="
  
  read -p "Make your choice (1,2,3,4), then press [ENTER]: " TODO
  
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
      echo -e "$r[!]$c Unknown number.. Press [ENTER] for return to main menu"
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
  printf "$cy[?]$c""$g"" Bootloader unlocked!$c Press [ENTER] for return to main menu"
  read
  mainMenu
}

function installTreble
{
  if ! command -v fastboot &> /dev/null
  then
      echo -e "$r[!]$c Fastboot not found, exiting..."
      exit 1
  fi
  
  if ! [ -f system.img ]
  then
    printf "$r[!]$c System.img not found, please put it on this directory, and press [ENTER] for refresh or [Q] for quit"
    read TODO
    case $TODO in
      q)
        mainMenu
        ;;
      
      *)
        installTreble
        ;;
        
    esac
  fi
  
  echo -e "$r""THIS ACTION WILL WIPE YOUR DATA$c"
  if [ $(confirmation) -eq 0 ]
  then
    mainMenu
  fi

  printf "\n\n"
  
  echo -e "$cy[?]$c Please connect device in FASTBOOT mode"
  
  fastboot erase userdata
  fastboot flash system system.img
  fastboot reboot

  printf "\n\n"
  
  printf "$cy[?]$c Press [ENTER] for return to main menu"
  read
  mainMenu
}

function installMagisk
{
  checkMtkclient
  checkMagisk

  #TODO
}

mainMenu
