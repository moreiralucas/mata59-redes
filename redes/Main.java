package redes;

import java.io.IOException;
import java.rmi.ConnectException;

import redes.ClienteHTTP;

public class Main {

    private static ClienteHTTP cliente;

    public static void main(String[] args) {

        try {
    
            cliente = new ClienteHTTP(args[0] ,args[1], Integer.parseInt(args[2]));

            if(cliente.isBemCriado()) {

                System.out.println("Host encontrado: " + args[1]);

                System.out.println("\n" + cliente.getTemplate("") + "\n" + cliente.request(""));

                cliente.fecharSocket();

            } else System.out.println("Host não encontrado: " + args[1]);
    
        } catch (java.net.ConnectException e) {

            System.out.println("Problema de conexão.");
            e.printStackTrace();
            
        } catch (ArrayIndexOutOfBoundsException e) {

            System.out.println("Uso: java redes/Main <GET OU POST> <IP OU hostname> <porta>");

        } catch (IOException e) {
    
            e.printStackTrace();

        }
    
    }

}