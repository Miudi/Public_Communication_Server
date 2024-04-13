package com.example.server;

import java.io.*;
import java.net.*;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * Klasa reprezentująca serwer aplikacji.
 */
public class SERVER {
    private static final Logger logger = LogManager.getLogger(SERVER.class);

    /**
     * Metoda główna, uruchamiająca serwer i nasłuchująca przychodzące dane na porcie 5555, dla każdego nowego klienta tworzy osobny wątek.
     *
     * @param args Argumenty wiersza poleceń.
     */
    public static void main(String[] args) {
        try {
            ServerSocket serverSocket = new ServerSocket(5555);
            logger.info("Server started.");
            System.out.println("Server started.");

            while (true) {
                Socket clientSocket = serverSocket.accept();
                logger.info("Client connected: {}", clientSocket.getRemoteSocketAddress());
                System.out.println("Client connected: " + clientSocket.getRemoteSocketAddress());

                Thread thread = new Thread(new ClientHandler(clientSocket));
                thread.start();
            }
        } catch (IOException e) {
            logger.error("IOException: {}", e.getMessage());
            System.err.println("IOException: " + e.getMessage());
        } catch (SecurityException e) {
            logger.error("SecurityException: {}", e.getMessage());
            System.err.println("SecurityException: " + e.getMessage());
        } catch (IllegalArgumentException e) {
            logger.error("IllegalArgumentException: {}", e.getMessage());
            System.err.println("IllegalArgumentException: " + e.getMessage());
        }
    }
}