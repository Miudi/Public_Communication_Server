package com.example.server;

import org.junit.jupiter.api.Test;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;
class FileHandlerTest {

    @Test
    public void test_makeLogs() {
        String conInfo = "ConnectionInfo";
        String logInfo = "LogInfo";

        // Wywołanie metody makeLogs
        FileHandler.makeLogs(conInfo, logInfo);

        // Odczyt pliku logs.txt i sprawdzenie, czy wpis został dodany poprawnie
        try {
            BufferedReader reader = new BufferedReader(new FileReader("logs.txt"));
            String line;
            boolean logFound = false;
            while ((line = reader.readLine()) != null) {
                if (line.contains(conInfo) && line.contains(LocalDate.now().toString()) && line.contains(logInfo)) {
                    logFound = true;
                    break;
                }
            }
            reader.close();

            // Sprawdzenie, czy wpis został znaleziony w pliku
            assertTrue(logFound, "Wpis nie został znaleziony w pliku.");
        } catch (IOException e) {
            fail("Wystąpił błąd podczas odczytu pliku: " + e.getMessage());
        }
    }
}