# XML_MDB
## Taks 3 - XML Documents Database
##### Design and implement a database for XML documents storage as columns of XML type.

### Setting up
In order to emulate exact system behavior, next steps must be completed in the specified order. Also the file structure should be maintained for the DBMS to locate the files.

1. Run **init.sql** script as sysdba.
2. Run **table_creation.sql** script.
3. In file **data_initialization.sql**, run until the CREATE INDEX command (included).
4. In file **functionalities.sql**, compile all functions and stored procedures in the same order they are written.
5. Run the rest of the script in **data_initialization.sql** (from EXECUTE IMPORTFROMXMLFILE until the end).
6. Now the system is ready to be tested. Run stored procedures to:
    * Import songs from XML files.
    * Create playlists
    * Export playlists to XML files.
    * Find all songs from an artist and its collaborations
    * Find all songs longer than a specified duration
    * Find all songs with a longer name than length specified
    * Find all songs with a specified number of different artists 
