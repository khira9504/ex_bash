#!/bin/bash

printf "\e[?25l"

esc_reset() {
  printf "\e[2J\e[H\e[?25h"
  exit 1
}
trap "esc_reset" INT QUIT TERM

random_card() {
  cards=(7 \$ ?)
  card="${cards[$((RANDOM % 3))]}"
  printf "%s" $card
}

slot_init() {
  printf "\e[2J\e[H"
  slot_flame="***********"
  show_cards="*[|$(random_card)|$(random_card)|$(random_card)|]*"
  printf "%s\n" "${slot_flame}"
  printf "%s\n" "${show_cards}"
  printf "%s\n" "${slot_flame}"
}

slot_init

game_start_end() {
  while :
  do
    read -p "$1" key
    case "$key" in
      [Yy]*)
        break
        ;;
      [Nn]*)
        printf "\e[?25h"
        exit 0
        ;;
      *)
        echo "y または n を入力してください!"
        ;;
    esac
  done
}
printf "\e[5;1H"
msg="ゲームを始めますか？ [y/n]: "
game_start_end "$msg"

trapped() {
  enter_count=$((enter_count + 1))
}

slot_judge() {
  c1="\e[32m"; c2="\e[30;46m"; ce="\e[m"
  case "$enter_count" in
    0)
      card_1=$(random_card)
      card_2=$(random_card)
      card_3=$(random_card)
      show_cards="*[|${card_1}|${card_2}|${card_3}|]*"
      printf "\e[2;1H%s\e[1G" "${show_cards}"
      ;;
    1)
      card_2=$(random_card)
      card_3=$(random_card)
      printf "\e[2;1H*[|$c1%s$ce|%s|%s|]*\e[1G" ${card_1} ${card_2} ${card_3}
      ;;
    2)
      card_3=$(random_card)
      if [[ "$card_1" == "$card_2" ]]; then
        printf "\e[2;1H*[|$c2%s$ce|$c2%s$ce|%s|]*\e[1G" ${card_1} ${card_2} ${card_3}
      else
        printf "\e[2;1H*[|$c1%s$ce|$c1%s$ce|%s|]*\e[1G" ${card_1} ${card_2} ${card_3}
      fi
      ;;
    3)
      if [[ "$card_1" == "$card_2" && "$card_1" == "$card_3" ]]; then
        success_show
        return
      fi
      if [[ "$card_1" == "$card_2" ]]; then
        printf "\e[2;1H*[|$c2%s$ce|$c2%s$ce|$c1%s$ce|]*\e[1G" ${card_1} ${card_2} ${card_3}
      elif [[ "$card_1" == "$card_3" ]]; then
        printf "\e[2;1H*[|$c2%s$ce|$c1%s$ce|$c2%s$ce|]*\e[1G" ${card_1} ${card_2} ${card_3}
      elif [[ "$card_2" == "$card_3" ]]; then
        printf "\e[2;1H*[|$c1%s$ce|$c2%s$ce|$c2%s$ce|]*\e[1G" ${card_1} ${card_2} ${card_3}
      else
        printf "\e[2;1H*[|$c1%s$ce|$c1%s$ce|$c1%s$ce|]*\e[1G" ${card_1} ${card_2} ${card_3}
      fi
      printf "\e[5;1H\e[K残念でした!\n"
      return
      ;;
    *)
      printf "\e[5;1H\e[?25hAn unexpected error has occurred..." >&2
      kill -KILL $$
      exit 1
      ;;
  esac
}

display_slot() {
  c1="\e[31m"; c2="\e[30;46m"; ce="\e[m";
  for i in $(seq 8); do
    printf "\e[2J\e[H"
    if ((i % 2 == 0)); then
      printf "\e[1;1H$c1%s$ce" "${slot_flame}"
      printf "\e[3;1H$c1%s$ce" "${slot_flame}"
    fi
    printf "\e[2;1H$c1*$ce[|$c2%s$ce|$c2%s$ce|$c2%s$ce|]$c1*$ce" ${card_1} ${card_2} ${card_3}
    sleep 0.1
  done
  printf "\e[1;1H%s" "${slot_flame}"
  printf "\e[2;1H*[|$c2%s$ce|$c2%s$ce|$c2%s$ce|]*" ${card_1} ${card_2} ${card_3}
  printf "\e[3;1H%s" "${slot_flame}"
}

success_show() {
  display_slot
  printf "\e[5;1Hおめでとうございます!\n"
}

slot_machine() {
  enter_count=0
  trap "trapped" USR1 USR2
  trap "slot_init" CONT

  while :
  do
    slot_judge
    if ((enter_count == 3)); then
      return
    fi
    sleep 0.2
  done
}

esc_bg_reset() {
  if [[ ${PID:=0} -gt 0 ]]; then
    kill $PID
  fi
  esc_reset
}
trap "esc_bg_reset" QUIT

usr_num=1
first=true
while :
do
  if "$first"; then
    first=false
  else
    printf "\e[5;1H\e[J"
  fi
  slot_machine &
  PID=$!

  for ((i=0; i<3; i++)); do
    while :
    do
      read -s -n 1 key
      if [[ -z $key && ${PID:=0} -gt 0 ]]; then
        if ((usr_num == 1)); then
          kill -USR1 $PID
        else
          kill -USR2 $PID
        fi 
        usr_num=$((usr_num * -1))
        break
      else
        printf "\e[5;1H何も入力せずに、Enterキーを押してください!"
      fi
    done
  done

  wait

  printf "\e[7;1H"
  msg="もう一度チャレンジしますか？ [y/n]: "
  game_start_end "$msg"
done