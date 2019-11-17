# mata59-redes
Roteador IPv4 e Firewall TCP/UDP

## Como iniciar repositório:
Em um terminal na pasta `router_ipv4` da VM, execute:
```shell
git init
git remote add origin https://github.com/moreiralucas/mata59-redes.git
git fetch
git checkout origin/master -ft
```
Os arquivos administrados pelo repo serão modificados enquanto todos os outros serão mantidos como estiverem.

Para incluir novos arquivos no repositório, basta criar exceção no arquivo `.gitignore`.

## A fazer:
1. **Desenvolvimento e Teste do Roteador**
    - [x] Descrever campos do cabeçalho IP
    - [x] Descrever campos TCP e UPD
2. **Desenvolvimento do Firewall UDP/TCP**
    - [x] Modificar portas bloqueadas pelo firewall
3. **Desenvolvimento de um Servidor HTTP**
    - [x] Desenvolver o servidor
    - [ ] Adequar cliente ao projeto
4. **Parte Teórica**
    - [ ] Relatório respondendo às 11 perguntas especificadas
