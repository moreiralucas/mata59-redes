import socket
import sys
import re
#import time
import select
import locale
import datetime

template = {

    'GET': """HTTP/1.1 200 OK
Date: @data
Server: serverHTTP.py
Last-Modified: @data
Content-Length: 30
Content-Type: text/plain
Connection: Closed

Hello World vindo do HTTP GET!""",

    'POST': """HTTP/1.1 200 OK
Date: @data
Server: serverHTTP.py
Last-Modified: @data
Content-Length: 31
Content-Type: text/plain
Connection: Closed

Hello World vindo do HTTP POST!""",
    
    'BAD': """HTTP/1.1 400 Bad Request
Date: @data
Server: serverHTTP.py
Content-Length: 0
Connection: Closed

"""
}


try:

    if len(sys.argv) < 3:
        print('Uso: python3 echoServer.py <IP> <PORTA>')
        sys.exit()

    IP = sys.argv[1]

    try:
        PORTA = int(sys.argv[2])

    except ValueError:
        print('Porta deve ser um número inteiro.')
        sys.exit()

    #locale.setlocale(locale.LC_TIME, 'pt_BR') #locale para as datas e horarios

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:

        s.bind((IP, PORTA))
        s.listen()

        while True:

            conexao, endCliente = s.accept() #bloqueia aguardando conexao

            conexao.setblocking(0) #tornar o socket de conexao nao bloqueante

            with conexao:

                print('Conexão de: ' + str(endCliente) + "\n") #debug

                stringDados = ''
                padrao = re.compile('\n\n') 

                while not re.search(padrao, stringDados): #esperando terminador do header HTTP

                    select.select([conexao], [], [], 5)

                    temp = conexao.recv(1024)

                    if not temp:
                        break
                    else:
                        stringDados = stringDados + temp.decode('ASCII')
                
                print('Recebido:\n\n' + stringDados) #debug

                padraoGET = re.compile('GET')
                padraoPOST = re.compile('POST')

                resposta = ''

                if re.match(padraoGET, stringDados): 
                    resposta = template['GET']

                elif re.match(padraoPOST, stringDados):
                    resposta = template['POST']

                else:
                    resposta = template['BAD']

                dataHora = datetime.datetime.now().strftime('%a, %d %b %Y %H:%M:%S GMT%z')
                resposta = resposta.replace('@data', dataHora)

                print("Enviado: \n\n" + resposta)

                conexao.sendall(resposta.encode('ASCII'))

except KeyboardInterrupt:
    sys.exit()