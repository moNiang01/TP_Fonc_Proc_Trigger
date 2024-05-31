-- Fonction GET_NB_WORKERS
CREATE OR REPLACE FUNCTION GET_NB_WORKERS(FACTORY NUMBER) RETURN NUMBER IS
    nb_workers NUMBER;
BEGIN
    SELECT COUNT(*) INTO nb_workers
    FROM (
        SELECT worker_id FROM WORKERS_FACTORY_1 WHERE id = FACTORY
        UNION ALL
        SELECT worker_id FROM WORKERS_FACTORY_2 WHERE id = FACTORY
    );
    RETURN nb_workers;
END GET_NB_WORKERS;
/


-- Fonction GET_NB_BIG_ROBOTS
CREATE OR REPLACE FUNCTION GET_NB_BIG_ROBOTS RETURN NUMBER IS
    nb_big_robots NUMBER;
BEGIN
    SELECT COUNT(DISTINCT robot_id) INTO nb_big_robots
    FROM ROBOTS_HAS_SPARE_PARTS
    GROUP BY robot_id
    HAVING COUNT(spare_part_id) > 3;
    RETURN nb_big_robots;
END GET_NB_BIG_ROBOTS;
/

-- Fonction GET_BEST_SUPPLIER
CREATE OR REPLACE FUNCTION GET_BEST_SUPPLIER RETURN VARCHAR2 IS
    best_supplier VARCHAR2(100);
BEGIN
    SELECT name INTO best_supplier
    FROM BEST_SUPPLIERS
    WHERE ROWNUM = 1
    ORDER BY performance DESC;
    RETURN best_supplier;
END GET_BEST_SUPPLIER;
/

-- Fonction GET_OLDEST_WORKER
CREATE OR REPLACE FUNCTION GET_OLDEST_WORKER RETURN NUMBER IS
    oldest_worker_id NUMBER;
BEGIN
    SELECT id INTO oldest_worker_id
    FROM (
        SELECT id, first_day FROM WORKERS_FACTORY_1
        UNION ALL
        SELECT worker_id AS id, start_date AS first_day FROM WORKERS_FACTORY_2
    )
    ORDER BY first_day
    FETCH FIRST 1 ROW ONLY;
    RETURN oldest_worker_id;
END GET_OLDEST_WORKER;
/

-- Procédure SEED_DATA_WORKERS
CREATE OR REPLACE PROCEDURE SEED_DATA_WORKERS(NB_WORKERS NUMBER, FACTORY_ID NUMBER) IS
BEGIN
    FOR i IN 1..NB_WORKERS LOOP
        INSERT INTO WORKERS_FACTORY_1 (first_name, last_name, age, first_day, last_day)
        VALUES (
            'worker_f_' || i,
            'worker_l_' || i,
            TRUNC(DBMS_RANDOM.VALUE(18, 65)),
            TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE '2065-01-01', 'J'), TO_CHAR(DATE '2070-01-01', 'J'))), 'J'),
            NULL
        );
    END LOOP;
END SEED_DATA_WORKERS;
/

-- Procédure ADD_NEW_ROBOT
CREATE OR REPLACE PROCEDURE ADD_NEW_ROBOT(MODEL_NAME VARCHAR2) IS
BEGIN
    INSERT INTO ROBOTS (model)
    VALUES (MODEL_NAME);
END ADD_NEW_ROBOT;
/

-- Procédure SEED_DATA_SPARE_PARTS
CREATE OR REPLACE PROCEDURE SEED_DATA_SPARE_PARTS(NB_SPARE_PARTS NUMBER) IS
BEGIN
    FOR i IN 1..NB_SPARE_PARTS LOOP
        INSERT INTO SPARE_PARTS (color, name)
        VALUES (
            CASE TRUNC(DBMS_RANDOM.VALUE(1, 6))
                WHEN 1 THEN 'red'
                WHEN 2 THEN 'gray'
                WHEN 3 THEN 'black'
                WHEN 4 THEN 'blue'
                WHEN 5 THEN 'silver'
            END,
            'part_' || i
        );
    END LOOP;
END SEED_DATA_SPARE_PARTS;
/

