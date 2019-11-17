package redes;

import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;

public class ClienteHTTP {

    private static final int BUFFER_SIZE = 4096;

    //nesse template a aplicação finge ser um browser,
    //requer preferencialmente por HTML, seguido de texto claro e XML,
    //requer preferencialmente português ou inglês,
    //não mantem conexão aberta
    private String[] template = {"@metodo @elemento HTTP/1.1\n",
                                 "Host: @host:80\n",
                                 "User-Agent: Mozilla/5.0 (compatible; MSIE 9.0; Windows Phone OS 7.5; Trident/5.0; IEMobile/9.0)\n",
                                 "Accept: text/html,text/plain;q=0.9,application/xhtml+xml;q=0.5,application/xml;q=0.4\n",
                                 "Accept-Language: pt-BR,pt-PT;q=0.9,en-US;q=0.5,en;q=0.4\n",
                                 "Connection: close\n",
                                 "\n"};

    public static int PORTA_HTTP;

    private String host;

    private String elemento;

    private String metodo;

    private int indiceBuffer;

    private Socket socketClienteTCP;

    private InputStream entrada;

    private OutputStream saida;

    private byte[] buffer;

    private boolean bemCriado;

    public ClienteHTTP(String metodo, String url, int porta) throws IOException, SecurityException {

        try {

            this.bemCriado = true;

            PORTA_HTTP = porta;

            this.metodo = metodo;

            //remover seção inicial caso o usuário digite http:// ou https://
            //e mais ajustes
            String url2 = url;
            url2 = url2.replace("http://", "");
            url2 = url2.replace("https://", "");
            if(url2.contains("/")) {

                this.elemento = url2.substring(url2.indexOf("/"));
                this.host = url2.substring(0, url2.indexOf("/"));

            } else {

                this.elemento = "/";
                this.host = url2;
            }

            System.out.println("Host: " + this.host + "\n" + "Elemento: " + this.elemento);

            //essa linha vai checar a validade do endereço caso venha no formato 000.000.000.000
            //se vier em representação textual, ela faz uso do DNS para recuperar IP
            InetAddress ip = InetAddress.getByName(this.host);

            //abrir socket cliente TCP
            this.socketClienteTCP = new Socket(ip, PORTA_HTTP);

            //recuperar obejetos para entrada e saída
            this.entrada = this.socketClienteTCP.getInputStream();
            this.saida = this.socketClienteTCP.getOutputStream();

            //inicialização do buffer de recebimento
            this.indiceBuffer = 0;
            this.buffer = new byte[BUFFER_SIZE];
            this.limparBuffer();

            for (int i = 0; i < this.template.length; i++) {

                this.template[i] = this.template[i].replace("@host", this.host);
                this.template[i] = this.template[i].replace("@elemento", this.elemento);
                this.template[i] = this.template[i].replace("@metodo", this.metodo);
                
            }

        } catch (UnknownHostException e) {

            //Ocorre se não for possível encontrar o IP via DNS
            this.bemCriado = false;

        }

    }

    public boolean isBemCriado() {

        return this.bemCriado;
    }

    @Override
    public String toString() {

        return new String(this.buffer);
    }

    public void limparBuffer() {

        this.indiceBuffer = 0;

        for (int i = 0; i < BUFFER_SIZE; i++)
            buffer[i] = '\0';
    }

    public int receber() throws IOException {

        int retorno = -1;

        //leitura bloqueante do socket
        do {

            retorno = entrada.read(this.buffer, this.indiceBuffer, BUFFER_SIZE - this.indiceBuffer);

            if (retorno > 0)
                this.indiceBuffer += retorno;
            else
                break;

        } while(this.entrada.available() > 0);

        return retorno;
    }

    public void enviar(String payload) throws IOException {

        //faz envio no socket convertendo a string para ASCII 7bits
        this.saida.write(payload.getBytes(StandardCharsets.US_ASCII));

    }

    public String getTemplate(String body) {

        String payload = "";

        for (String str : this.template) 
            payload = payload.concat(str);

        payload = payload.concat(body);

        return payload;
    }

    public String request(String body) throws IOException {

        //envia a request GET, fica esperando resposta e retorna string

        String resposta = "";
        String payload = this.getTemplate(body);

        this.limparBuffer();

        this.enviar(payload);

        do {

            this.receber();
            resposta = resposta.concat(this.toString());
            this.limparBuffer();

        } while(this.entrada.available() > 0);

        return resposta;
    }

    public void fecharSocket() throws IOException {

        //finalizar as comunicações
        this.entrada.close();
        this.saida.close();
        this.socketClienteTCP.close();
    } 

}