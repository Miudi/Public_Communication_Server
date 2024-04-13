package com.example.server;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.time.LocalDate;

/**
 * Klasa obsługująca zapisywanie logów do pliku.
 */
public class FileHandler {

    /**
     * Metoda tworząca logi i zapisująca je do pliku.
     *
     * @param conInfo  Informacje dotyczące połączenia.
     * @param logInfo  Informacje do zapisania jako log.
     */
    public static void makeLogs(String conInfo, String logInfo) {
        try {
            FileWriter fileWriter = new FileWriter("logs.txt", true); // drugi parametr 'true' oznacza, że plik będzie otwarty w trybie dopisywania
            BufferedWriter bufferedWriter = new BufferedWriter(fileWriter);

            String data = LocalDate.now().toString();
            String log = "[" + conInfo + "]" + "-[" + data + "]" + " - " + logInfo;
            bufferedWriter.write(log); // zapisywanie informacji
            bufferedWriter.newLine(); // dodanie nowej linii

            bufferedWriter.close(); // zamykanie BufferedWriter
            fileWriter.close(); // zamykanie FileWriter

            System.out.println("Log został dodany do pliku.");
        } catch (IOException e) {
            System.out.println("Wystąpił błąd podczas zapisu do pliku: " + e.getMessage());
        }
    }

}