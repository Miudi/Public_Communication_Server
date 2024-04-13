package com.example.server;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;

/**
 * Klasa obsługująca wątek klienta.
 */
public class ClientHandler implements Runnable {
    private static final Logger logger = LogManager.getLogger(ClientHandler.class);
    private final Socket clientSocket;

    /**
     * Konstruktor klasy ClientHandler, obsługuje on komunikację klient>server>klient.
     *
     * @param clientSocket Gniazdo klienta.
     */
    public ClientHandler(Socket clientSocket) {
        this.clientSocket = clientSocket;
    }

    /**
     * Metoda run, która uruchamia wątek klienta i przydziela mu zadanie, wątek ten obsługuje dane przychodzące od klienta i zależnie od nich wysyła odpowiednie zapytanie do bazy danych.
     */
    @Override
    public void run() {
        try {
            logger.warn("Utworzono wątek");
            PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
            BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));

            String inputLine;
            String query = null, ans = null;
            String user = "";
            String pass = "";
            MySQL polaczenie = new MySQL();

            while ((inputLine = in.readLine()) != null) {
                logger.warn("Client: {}", inputLine);
                System.out.println("Client: " + inputLine);

                String[] parts = inputLine.split(","); //Podzielenie wiadomości na czesci
                if (parts[0].equals("pokaz_numery_linii")) {
                    //wyswietli numery lini jakie sa w bazie danych
                    query = "select linia_id,czas_calosc from linia";
                    ans = polaczenie.open_connection(query, user, pass);
                    out.println(ans);
                } else if (parts[0].equals("pokaz_przystanki")) {
                    query = "select nazwa,minuty_nast_przyst from przystanek where linia_id = " + parts[1];
                    ans = polaczenie.open_connection(query, user, pass);
                    out.println(ans);
                } else if (parts[0].equals("pokaz_godziny")) {
                    query = "select kierowca.godzina_startu*60 + kierowca.minuta_startu + COALESCE((SELECT SUM(minuty_nast_przyst) AS czas\n" +
                            "FROM przystanek\n" +
                            "WHERE przystanek_nr BETWEEN 0 AND (SELECT przystanek_nr - 1 FROM przystanek WHERE nazwa LIKE '" + parts[2] + "' AND linia_id = " + parts[1] + ")\n" +
                            "AND linia_id = " + parts[1] + "),0)\n" +
                            "as czas from kierowca where linia_id = " + parts[1] + ";";
                    System.out.println(query);
                    ans = polaczenie.open_connection(query, user, pass);
                    out.println(ans);
                } else if (parts[0].equals("unikalne")) {
                    query = "SELECT distinct(nazwa) as przystanek FROM `przystanek`";
                    ans = polaczenie.open_connection(query, user, pass);
                    out.println(ans);
                } else if (parts[0].equals("polaczenie")) {
                    query = "CALL FindRoutes('" + parts[1] + "', '" + parts[2] + "'," + parts[3] + "," + parts[4] + ");";
                    System.out.println(query);
                    ans = polaczenie.open_connection(query, user, pass);
                    out.println(ans);
                } else if (parts[0].equals("opoznienie")) {
                    query = "UPDATE kierowca SET czas_do_przyj = 0 WHERE godzina_startu < (" + parts[2] + "-2) AND godzina_startu > (" + parts[2] + "+2)";
                    ans = polaczenie.open_connection(query, user, pass);
                    query = "UPDATE kierowca SET czas_do_przyj = " + parts[3] + " WHERE linia_id = " + parts[1] + " AND godzina_startu > (" + parts[2] + "-2) AND godzina_startu < (" + parts[2] + "+2)";
                    System.out.println(query);
                    ans = polaczenie.open_connection(query, user, pass);
                    out.println(ans);
                } else if (parts[0].equals("dodaj")) {
                    query = "CALL AddRoute(" + parts[1] + ", '" + parts[2] + "', '" + parts[3] + "'," + parts[4] + "," + parts[5] + ");";
                    ans = polaczenie.open_connection(query, user, pass);
                    out.println(ans);
                } else if (parts[0].equals("usun")) {
                    query = "DELETE FROM kierowca WHERE linia_id = " + parts[1] + ";";
                    ans = polaczenie.open_connection(query, user, pass);
                    query = "DELETE FROM przystanek WHERE linia_id =" + parts[1] + ";";
                    ans = polaczenie.open_connection(query, user, pass);
                    query = "DELETE FROM linia WHERE linia_id =" + parts[1] + ";";
                    ans = polaczenie.open_connection(query, user, pass);
                    out.println(ans);
                } else if (parts[0].equals("test")) {
                    out.println("test");
                }
                logger.warn("Sended query : " + query);
                logger.warn("Response from Database : " + ans);
                FileHandler.makeLogs(clientSocket.getRemoteSocketAddress().toString(), inputLine);
                if (parts[0].equals("Bye."))
                    break;
            }

            // Obsługa odłączenia klienta
            System.out.println("Client disconnected: " + clientSocket.getRemoteSocketAddress());
            clientSocket.close();
        } catch (IOException e) {
            logger.error("IOException: {}", e.getMessage());
            System.err.println("IOException: " + e.getMessage());
        } catch (NullPointerException e) {
            logger.error("NullPointerException: {}", e.getMessage());
            System.err.println("NullPointerException: " + e.getMessage());
        } catch (SecurityException e) {
            logger.error("SecurityException: {}", e.getMessage());
            System.err.println("SecurityException: " + e.getMessage());
        }
    }
}