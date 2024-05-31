-- Trigger pour insertion dans ALL_WORKERS_ELAPSED
CREATE OR REPLACE TRIGGER trg_all_workers_elapsed
INSTEAD OF INSERT ON ALL_WORKERS_ELAPSED
FOR EACH ROW
BEGIN
    INSERT INTO WORKERS_FACTORY_1 (id, first_name, last_name, age, first_day, last_day)
    VALUES (:NEW.id, :NEW.first_name, :NEW.last_name, :NEW.age, :NEW.first_day, :NEW.last_day);
END;
/

-- Trigger pour enregistrer la date d’ajout de robot
CREATE OR REPLACE TRIGGER trg_audit_robot
AFTER INSERT ON ROBOTS
FOR EACH ROW
BEGIN
    INSERT INTO AUDIT_ROBOT (robot_id, created_at)
    VALUES (:NEW.id, SYSDATE);
END;
/

-- Trigger pour empêcher modification si nombre d'usines ≠ nombre de tables
CREATE OR REPLACE TRIGGER trg_check_factories
BEFORE INSERT OR UPDATE OR DELETE ON ROBOTS_FACTORIES
DECLARE
    v_factories_count NUMBER;
    v_tables_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_factories_count FROM FACTORIES;
    SELECT COUNT(*) INTO v_tables_count FROM all_tables WHERE table_name LIKE 'WORKERS_FACTORY_%';
    
    IF v_factories_count <> v_tables_count THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nombre d’usines et de tables ne correspondent pas.');
    END IF;
END;
/

-- Trigger pour calculer la durée de travail
ALTER TABLE WORKERS_FACTORY_1 ADD (duration NUMBER);

CREATE OR REPLACE TRIGGER trg_calculate_duration
BEFORE UPDATE OF last_day ON WORKERS_FACTORY_1
FOR EACH ROW
BEGIN
    :NEW.duration := :NEW.last_day - :OLD.first_day;
END;
/
