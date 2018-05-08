INSERT INTO USERS VALUES('msk1416', 'Sergi', 'Mascaro');
INSERT INTO USERS VALUES('bstinson', 'Barney', 'Stinson');
INSERT INTO USERS VALUES('user2204', 'Commonname', 'Commonlastname');

CREATE SEQUENCE id_seq
  START WITH 1
  INCREMENT BY 1;
  
  
CREATE INDEX XMLINDEX ON SONGS(INFO) 
INDEXTYPE IS CTXSYS.CONTEXT;
       
/* run following commands after compiling stored procedures */

EXECUTE IMPORTFROMXMLFILE('vinacar.xml');
EXECUTE IMPORTFROMXMLFILE('randomgold.xml');
/* there are 2 more xml files with songs to import: rockcatala.xml and fapyrt.xml */



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
EXECUTE ADDTOPLAYLIST('msk1416', 32, 'Mega mix');



EXECUTE EXPORTPLAYLIST('bstinson', 'Mega mix');
EXECUTE EXPORTPLAYLIST('msk1416', 'Happy songs');
