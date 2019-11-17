#!/usr/bin/env python3
import socket
import sys
import re
import select

template = """@metodo @elemento HTTP/1.1
Host: @host\r\n\r\n"""

if len(sys.argv) < 3:
    print('Uso: python3 clientHTTP.py <IP> <PORTA>')
    sys.exit()

metodoGET = "GET"
metodoPOST = "POST"

url = sys.argv[1]
url = url.replace("http://", "")
url = url.replace("https://", "")
if "/" in url:
    elemento = url[url.index("/"):]
    host = url[0:url.index("/")]
else:
    elemento = "/"
    host = url

try:
    porta = int(sys.argv[2])
except ValueError:
    print('Porta deve ser um número inteiro.')
    sys.exit()

print("Conectando ao servidor " + host + " na porta " + str(porta) + " ...\n")

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:

    s.connect((host, porta))

    pedido = template

    pedido = pedido.replace('@metodo', metodoGET)
    pedido = pedido.replace('@elemento', elemento)
    pedido = pedido.replace('@host', host)
    pedido = pedido.replace('@porta', str(porta))

    s.sendall(pedido.encode('ASCII'))
    print("Enviado:\n" + pedido)

    resposta = s.recv(1024)
    print("Recebido:\n" + repr(resposta))

s.close()