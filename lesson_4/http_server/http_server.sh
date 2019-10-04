#!/bin/bash

function server () {
  while true
  do
    message_arr=()
    check=true
    while $check
    do
      read line
      >&2 "Line: $line. Line length: ${#line}"
      message_arr+=($line)
      if [[ "${#line}" -eq 1 ]]
      then
        check=false
      fi
    done
    method=${message_arr[0]}
    path=${message_arr[1]}
    if [[ $method = 'GET' ]]
    then
      if [[ -f "./www/$path" ]]
      then
        echo -ne 'HTTP/1.1 200 OK\r\n'
        echo -ne 'Content-Type: text/html; charset=utf-8\r\n'
        content_length=$(wc -c < "./www/$path")
        echo -ne "Content-Length: $content_length\r\n\r\n"
        cat "./www/$path"
      else
        echo -ne 'HTTP/1.1 404 Not Found\r\n'
        echo -ne 'Content-Length: 0\r\n\r\n'
      fi
    else
      echo -ne 'HTTP/1.1 400 Bad Request\r\n'
      echo -ne 'Content-Length: 0\r\n\r\n'
    fi
    # echo "Your message: ${message_arr[*]}"
    # echo "Size of message: ${#message_arr[@]}"
  done
}

coproc SERVER_PROCESS { server; }

netcat -lkv 2345 <&${SERVER_PROCESS[0]} >&${SERVER_PROCESS[1]}