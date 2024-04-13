module com.example.server {
    requires javafx.controls;
    requires javafx.fxml;

    requires org.controlsfx.controls;
    requires java.sql;
    requires com.fasterxml.jackson.databind;
    requires org.apache.logging.log4j;

    opens com.example.server to javafx.fxml;
    exports com.example.server;
}