CREATE OR REPLACE PROCEDURE IMPORTFROMXMLFILE (
  filename in varchar2
)
is
XML_FILE BFILE;
CLOB_DATA CLOB;
XML_DATA XMLTYPE;

COUNT_INSERTED INTEGER := 0;

TYPE REC_SONG IS RECORD (
        URI VARCHAR2(100),
        XML_ELEMENT XMLTYPE
    );
 
TYPE TYPE_SONGLIST IS TABLE OF REC_SONG;
l_song_list type_songlist;

l_dest_offset   INTEGER := 1;
l_src_offset    INTEGER := 1;
l_bfile_csid    NUMBER  := 0;
L_LANG_CONTEXT  INTEGER := 0;
L_WARNING       INTEGER := 0;
  
BEGIN
XML_FILE := BFILENAME ('XML_DIR', FILENAME);
DBMS_LOB.createtemporary (clob_data, TRUE, DBMS_LOB.SESSION);
DBMS_LOB.FILEOPEN (XML_FILE, DBMS_LOB.FILE_READONLY);

DBMS_LOB.LOADCLOBFROMFILE (
    DEST_LOB      => CLOB_DATA,
    src_bfile     => xml_file,
    AMOUNT        => DBMS_LOB.LOBMAXSIZE,
    DEST_OFFSET   => L_DEST_OFFSET,
    SRC_OFFSET    => L_SRC_OFFSET,
    BFILE_CSID    => L_BFILE_CSID,
    LANG_CONTEXT  => L_LANG_CONTEXT,
    WARNING       => L_WARNING);
    
DBMS_LOB.fileclose (xml_file);

XML_DATA := XMLTYPE.CREATEXML(CLOB_DATA);

SELECT XML_LIST.EXTRACT('//SpotifyURI').getStringVal() AS URI,
       XML_LIST.EXTRACT('//song') AS XML_ELEMENT
BULK COLLECT
INTO L_SONG_LIST
FROM TABLE(XMLSEQUENCE(EXTRACT(XML_DATA, '/playlist/song'))) XML_LIST;
IF l_song_list.COUNT > 0 THEN

    FOR I IN L_SONG_LIST.FIRST..L_SONG_LIST.LAST LOOP
        IF TRY_INSERT_SONG(L_SONG_LIST(I).URI, L_SONG_LIST(I).XML_ELEMENT) = 1 THEN
          COUNT_INSERTED := COUNT_INSERTED + 1;
        end if;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Total inserted: ' || count_inserted);
END IF;

END;

execute importfromxmlfile('vinacar.xml');

CREATE OR REPLACE FUNCTION TRY_INSERT_SONG (
  URI IN VARCHAR2,
  XML_ELEM XMLTYPE
  ) RETURN INTEGER
  is
  
  BEGIN
    INSERT INTO SONGS VALUES (ID_SEQ.NEXTVAL, URI, XML_ELEM);
    IF SQL%ROWCOUNT > 0 THEN
      RETURN 1;
    end if;
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        RETURN 0;
  END;
  


CREATE OR REPLACE PROCEDURE PRINTINFOSONG (
  SONG_ID IN INTEGER
  ) IS
    SONG_INFO XMLTYPE;
  BEGIN
    SELECT INFO INTO SONG_INFO FROM SONGS WHERE ID = SONG_ID;
    IF SQL%FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Song with ID: ' || SONG_ID);
      DBMS_OUTPUT.PUT_LINE(SONG_INFO.GETSTRINGVAL());
    END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('There is no song with this ID in the system.');
    
  end;
  
execute PRINTINFOSONG(300);


CREATE OR REPLACE PROCEDURE ADDTOPLAYLIST (
    USERNAME IN VARCHAR2,
    SONG_ID IN INTEGER,
    PL_NAME IN VARCHAR2
  ) IS
    PL_EXISTS INTEGER := 0;
    INTEGRITY_CONSTRAINT_VIOLATED EXCEPTION;
    PRAGMA EXCEPTION_INIT(INTEGRITY_CONSTRAINT_VIOLATED, -2291);
  BEGIN
    SELECT COUNT(*) INTO PL_EXISTS FROM PLAYLISTS WHERE OWNER = USERNAME AND NAME = PL_NAME;
    INSERT INTO PLAYLISTS VALUES (USERNAME, SONG_ID, PL_NAME);
    IF PL_EXISTS > 0 THEN
      DBMS_OUTPUT.PUT_LINE('Song added to existing playlist ' || PL_NAME || '.');
    ELSE
      DBMS_OUTPUT.PUT_LINE('New playlist ' || PL_NAME || ' was created.');
    END IF;
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Looks like this song is already in this playlist.');
      WHEN INTEGRITY_CONSTRAINT_VIOLATED THEN
        DBMS_OUTPUT.PUT_LINE('Either the song or the username does not exist in the system.');
  END;
  
execute addtoplaylist('msk1416', 3, 'Happy songs');
execute addtoplaylist('msk1416', 5, 'Happy songs');
EXECUTE ADDTOPLAYLIST('msk1416', 78, 'Happy songs');
EXECUTE ADDTOPLAYLIST('msk1416', 211, 'Happy songs');

EXECUTE ADDTOPLAYLIST('bstinson', 32, 'Mega mix');
EXECUTE ADDTOPLAYLIST('bstinson', 21, 'Mega mix');
EXECUTE ADDTOPLAYLIST('bstinson', 312, 'Mega mix');
EXECUTE ADDTOPLAYLIST('bstinson', 300, 'Mega mix');
EXECUTE ADDTOPLAYLIST('bstinson', 209, 'Mega mix');
EXECUTE ADDTOPLAYLIST('bstinson', 168, 'Mega mix');
EXECUTE ADDTOPLAYLIST('bstinson', 166, 'Mega mix');
EXECUTE ADDTOPLAYLIST('bstinson', 9, 'Mega mix');
EXECUTE ADDTOPLAYLIST('bstinson', 76, 'Mega mix');
EXECUTE ADDTOPLAYLIST('bstinson', 198, 'Mega mix');
EXECUTE ADDTOPLAYLIST('bstinson', 213, 'Mega mix');
EXECUTE ADDTOPLAYLIST('bstinson', 316, 'Mega mix');
EXECUTE ADDTOPLAYLIST('bstinson', 56, 'Mega mix');
execute ADDTOPLAYLIST('bstinson', 100, 'Mega mix');

EXECUTE ADDTOPLAYLIST('msk1416', 321, 'Mega mix');
execute ADDTOPLAYLIST('msk1416', 32, 'Mega mix');



CREATE OR REPLACE PROCEDURE EXPORTPLAYLIST (
  U_NAME USERS.USERNAME%TYPE,
  PL_NAME PLAYLISTS.NAME%TYPE
  )
  IS
    CURSOR CUR_SONGS IS SELECT SONG 
      FROM PLAYLISTS 
      WHERE OWNER = U_NAME AND name = PL_NAME;
    EXP_FILE UTL_FILE.FILE_TYPE;
    FILENAME VARCHAR(100);
    SONG SONGS.ID%TYPE;
    SONGROW SONGS%ROWTYPE;
    XML_SONG XMLTYPE;
    EXISTS_PLAYLIST NUMBER;
  BEGIN
    SELECT COUNT(*) INTO EXISTS_PLAYLIST FROM PLAYLISTS WHERE owner = U_NAME AND name = PL_NAME;
    IF EXISTS_PLAYLIST > 0 THEN 
      FILENAME := 'export_' || PL_NAME || '_' || U_NAME || '.xml';
      EXP_FILE := UTL_FILE.FOPEN('EXPORTS_DIR',FILENAME,'W');
      UTL_FILE.PUT_LINE(EXP_FILE, '<?xml version="1.0" encoding="UTF-8"?>');
      UTL_FILE.PUT_LINE(EXP_FILE, '<Playlist name='''|| PL_NAME ||''' owner='''|| U_NAME ||'''>');
      OPEN CUR_SONGS;
      LOOP
        FETCH CUR_SONGS
        INTO SONG;
        EXIT WHEN CUR_SONGS%NOTFOUND;
        
        SELECT INFO INTO XML_SONG FROM SONGS WHERE ID = SONG;
        UTL_FILE.PUT_LINE(EXP_FILE, XML_SONG.getStringVal());        
      END LOOP;
      UTL_FILE.PUT_LINE(EXP_FILE, '</Playlist>');
      UTL_FILE.FCLOSE(EXP_FILE);
    ELSE
      DBMS_OUTPUT.PUT_LINE('No export has been done as this playlist does not exist for this user.');
    END IF;
  END;
  
EXECUTE EXPORTPLAYLIST('bstinson', 'Mega mix');
  
  /* //song/Artist[text() = 'Piperrak']/.. xpath that returns all songs from Piperrak */
  
CREATE OR REPLACE PROCEDURE SEARCHBYARTIST (
  ARTIST IN VARCHAR2
  ) is
  counter integer := 1;
  BEGIN
    FOR R IN (
    SELECT S.ID AS TMP_SID, S.INFO.EXTRACT('//Track/text()').GETSTRINGVAL() AS TMP_TRACK, S.INFO.EXTRACT('//Artist/text()').GETSTRINGVAL() AS TMP_ARTIST FROM SONGS S 
    WHERE s.info.EXTRACT('//Artist[text()[contains(.,''' || artist ||''')]]/..') is not null ) 
    LOOP
      DBMS_OUTPUT.PUT_LINE('[' || counter || '] id: ' || R.TMP_SID || ', ' || R.TMP_TRACK || ' by ' || R.TMP_ARTIST);
      COUNTER := COUNTER + 1;
    end loop;
  end;
  
EXECUTE SEARCHBYARTIST('Lágrimas');



CREATE OR REPLACE PROCEDURE SEARCHBYDURATION (
  duration IN integer
  ) is
  counter integer := 1;
  BEGIN
    FOR R IN (
    SELECT S.ID AS TMP_SID, S.INFO.EXTRACT('//Track/text()').GETSTRINGVAL() AS TMP_TRACK, S.INFO.EXTRACT('//Artist/text()').GETSTRINGVAL() AS TMP_ARTIST, S.INFO.EXTRACT('//TrackDuration/text()').GETSTRINGVAL() AS TMP_DURATION FROM SONGS S 
    WHERE s.info.EXTRACT('//song/TrackDuration[. > ' || duration || ']/..') is not null) 
    LOOP
      DBMS_OUTPUT.PUT_LINE('[' || counter || '] id: ' || R.TMP_SID || ', duration: ' || R.TMP_DURATION ||', ' || R.TMP_TRACK || ' by ' || R.TMP_ARTIST);
      COUNTER := COUNTER + 1;
    end loop;
  end;
  
EXECUTE SEARCHBYDURATION(400000);



DECLARE
  counter integer := 1;
BEGIN
FOR R IN (
  SELECT S.ID AS TMP_SID, S.INFO.EXTRACT('//Artist/text()').GETSTRINGVAL() AS TMP_ARTIST FROM SONGS S 
  WHERE s.info.EXTRACT('//Artist[text()[contains(.,''' || 'Lágrimas' ||''')]]/..') is not null ) 
  LOOP
    DBMS_OUTPUT.PUT_LINE('[' || COUNTER || '] id: ' || R.TMP_SID || ', artist: ' || R.TMP_ARTIST);
    counter := counter + 1;
  end loop;
END;

CREATE INDEX xmlIndex ON SONGS(INFO) 
       INDEXTYPE IS CTXSYS.CONTEXT;
