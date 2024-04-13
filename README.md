# Application Server

## Project Description
This project contains Java code for an application server. The server handles communication with clients via network sockets, allowing data transmission and database querying.

## Project Structure
The project consists of three main classes:
1. **SERVER**: The main class representing the application server. It listens for incoming connections on a specified port and creates separate threads to handle each connection.
2. **ClientHandler**: A class handling client requests. Each client connection is managed by a separate thread, which receives data from the client, performs database queries, and sends responses back.
3. **FileHandler**: A class handling log file writing. It is used to log information about connections and server actions.

## How to Run
To run the server, execute the `main` method in the `SERVER` class. The server will listen for connections on port 5555.

## Dependencies
The project uses the Log4j library for event logging. Make sure you have the dependencies properly configured in your project.
