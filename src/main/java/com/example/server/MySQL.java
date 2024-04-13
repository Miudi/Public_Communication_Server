package com.example.server;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Klasa obsługująca połączenie i zapytania do bazy danych MySQL.
 */
public class MySQL {
    private static final Logger logger = LogManager.getLogger(MySQL.class);
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    String json = null;

    /**
     * Metoda otwierająca połączenie z bazą danych i wykonująca zapytanie.
     *
     * @param Query     Zapytanie SQL.
     * @param username  Nazwa użytkownika do logowania.
     * @param password  Hasło użytkownika do logowania.
     * @return Zwraca wynik zapytania w formacie JSON.
     */
    public String open_connection(String Query, String username, String password) {
        try {
            // Step 1: Load the MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Step 2: Establish the connection to the database
            String url = "jdbc:mysql://localhost:3306/rozklad_jazdy";
            String user = null;
            String pass = null;

            if (username.equals("admin") && password.equals("admin")) {
                // Użyj pełnych uprawnień dla konta "admin"
                user = "admin";
                pass = "admin";
            } else {
                // Użyj konta "projekt" z uprawnieniami tylko do SELECT
                user = "projekt";
                pass = "";
            }
            conn = DriverManager.getConnection(url, user, pass);
            logger.warn("Access to DataBase granted!");

            String[] parts = Query.split(" ");
            if (parts[0].equalsIgnoreCase("update") || Query.startsWith("CALL AddRoute") || parts[0].equalsIgnoreCase("delete")) {
                Statement statement = conn.createStatement();
                int rowsAffected = statement.executeUpdate(Query);
                json = String.valueOf(rowsAffected);
            } else {
                stmt = conn.createStatement();
                rs = stmt.executeQuery(Query);
                logger.warn("Query to database sent! - " + Query);

                ObjectMapper objectMapper = new ObjectMapper();
                List<Map<String, Object>> rows = new ArrayList<>();
                ResultSetMetaData metaData = rs.getMetaData();
                int columnCount = metaData.getColumnCount();

                // Step 4: Process the result set
                while (rs.next()) {
                    Map<String, Object> columns = new HashMap<>();
                    for (int i = 1; i <= columnCount; i++) {
                        columns.put(metaData.getColumnLabel(i), rs.getObject(i));
                    }
                    rows.add(columns);
                }
                json = objectMapper.writeValueAsString(rows);
            }
        } catch (SQLException ex) {
            logger.error("SQLException: {}", ex.getMessage());
            ex.printStackTrace();
        } catch (ClassNotFoundException ex) {
            logger.error("ClassNotFoundException: {}", ex.getMessage());
            ex.printStackTrace();
        } catch (JsonProcessingException e) {
            logger.error("JsonProcessingException: {}", e.getMessage());
            throw new RuntimeException(e);
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException ex) {
                logger.error("SQLException during closing connection: {}", ex.getMessage());
                ex.printStackTrace();
            }
        }
        logger.info("Returning JSON file - " + json);
        return json;
    }
}