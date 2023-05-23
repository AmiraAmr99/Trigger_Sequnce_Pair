CREATE OR REPLACE PROCEDURE TRG_SEQ_PAIR
IS 
    
    Cursor Colums_Tables_Names is 
            SELECT distinct cc.column_name as column_name, cc.table_name as table_name 
            FROM all_cons_columns cc
            JOIN user_tab_columns ut
            ON cc.column_name = ut.column_name
            WHERE Data_type = 'NUMBER'
            AND cc.POSITION = 1
            AND cc.constraint_name in (SELECT constraint_name 
                                                    FROM user_constraints 
                                                    WHERE CONSTRAINT_TYPE = 'P');

    v_trg_name VARCHAR2(25);
    v_seq_name VARCHAR2(25);
    v_col_name VARCHAR2(25);
    v_tab_name VARCHAR2(25);
    v_max Number(9);

BEGIN

    for rec_col in Colums_Tables_Names loop
    
        v_trg_name := rec_col.table_name||'_TRG';
        v_seq_name := rec_col.table_name||'_SEQ';
        v_col_name := rec_col.column_name;
        v_tab_name := rec_col.table_name;
        
        EXECUTE IMMEDIATE 'select NVL(Max( '||v_col_name|| '),0)+1  from '|| v_tab_name into v_max; 
        
            --drop all sequences 
                EXECUTE IMMEDIATE  'DROP SEQUENCE '||v_seq_name;
           
           --create new Sequences
               EXECUTE IMMEDIATE 'CREATE SEQUENCE '||v_seq_name||
                ' START WITH ' ||v_max|| 
                 ' INCREMENT BY 1
                  MAXVALUE  999999999999999999999999999
                  MINVALUE 1
                  NOCYCLE
                  CACHE 20
                  NOORDER';
                  
               --craete trigger
               EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER '||v_trg_name||
                ' BEFORE INSERT
                 ON '|| v_tab_name||
                ' FOR EACH ROW
                 BEGIN 
                         :new.'||v_col_name||' :=' ||v_seq_name||'.nextval;
                 END;';
    
    end loop;
END;


--PROCEDURE CALL
BEGIN
TRG_SEQ_PAIR
END;

