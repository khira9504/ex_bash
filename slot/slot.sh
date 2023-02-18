# !/bin/bash

printf "\e[?25l"

esc_reset() {
  printf "\e[2J\e[H\e[?25h]]]"
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
  slot_frame="***********"
  slot_cards="*[|$(random_card)|$(random_card)|$(random_card)|]*"
  printf "%s\n" "${slot_frame}"
  printf "%s\n" "${slot_cards}"
  printf "%s\n" "${slot_frame}"
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
        echo "Please input y or n"
        ;;
    esac
  done
}
printf "\e[5;1H"
msg="Would you like to play a game? [y/n]: "
game_start_end "msg"

trapped() {
  enter_count=$((enter_count + 1))
}

slot_judge() {
  c1="\e[32m"
  c2="\e[30;46m"
  ce="\e[m"
  case "$enter_count" in
    0)
      card_1=$(random_card)
      card_2=$(random_card)
      card_3=$(random_card)
      show_cards="*[|${card_1}|${card_2}|${card_3}|]*]"
      printf "\e2[;1H%s\e[1G" "${show_cards}"
      ;;
    1)
      card_2=$(random_card)
      card_3=$(random_card)
      show_cards="*[|${card_1}|${card_2}|${card_3}|]*]"
      printf "\e2[;1H*[|$c1%s$ce|%s|%s|*\e[1G" ${card_1} ${card_2} ${card_3}
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
}