


--Update Proc: Procedure that changes the passenger id on a booking
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE CHANGE_PASSENGER (
    OLD_ID IN NUMBER, 
    FLIGHT IN VARCHAR2, 
    NEW_ID IN NUMBER) IS
    
    ROW_COUNT   NUMBER;
BEGIN
SELECT COUNT(*) INTO ROW_COUNT FROM BOOKINGS WHERE PASSENGER_ID=OLD_ID AND FLIGHT_NUMBER=FLIGHT;
IF ROW_COUNT > 0 THEN
    SELECT COUNT(*) INTO ROW_COUNT FROM PASSENGERS WHERE ID=NEW_ID;
    IF ROW_COUNT > 0 THEN
        UPDATE BOOKINGS SET PASSENGER_ID=NEW_ID WHERE PASSENGER_ID=OLD_ID AND FLIGHT_NUMBER=FLIGHT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('There is no passenger with the supplied id number.');
    END IF;  
ELSE
    DBMS_OUTPUT.PUT_LINE('There is no booking in the Database for this passenger and flight.');
END IF;
END;


--Tests
EXECUTE CHANGE_PASSENGER (47331569, '12345', 902380);
EXECUTE CHANGE_PASSENGER (902380, '12345', 77777);
EXECUTE CHANGE_PASSENGER (902380, 'qwer12345', 47331569);
EXECUTE CHANGE_PASSENGER (151632, 'KL237', 445478);





--Add Proc: Procedure that adds a flight booking 

CREATE OR REPLACE PROCEDURE BOOK_FLIGHT (
    PASSENGER IN BOOKINGS.PASSENGER_ID%TYPE,
    FLIGHT IN BOOKINGS.FLIGHT_NUMBER%TYPE,
    DISC_TITLE IN DISCOUNTS.DISC_ID%TYPE )
    IS
    PASSENGER_FOUND NUMBER := 0;
    FLIGHT_FOUND NUMBER := 0;
    BEGIN
        SELECT COUNT(*) INTO PASSENGER_FOUND
        FROM PASSENGERS WHERE ID = PASSENGER;
        SELECT COUNT(*) INTO FLIGHT_FOUND
        FROM FLIGHTS WHERE FLIGHT_NO = FLIGHT;
        
        IF PASSENGER_FOUND + FLIGHT_FOUND = 2 THEN
            INSERT INTO BOOKINGS 
            VALUES (PASSENGER, 
                    FLIGHT, 
                    GET_REDUCED_PRICE(FLIGHT, DISC_TITLE),
                    ROUND(DBMS_RANDOM.VALUE() * 100)); --random seat no.
        ELSIF PASSENGER_FOUND  = 0 THEN
            DBMS_OUTPUT.PUT_LINE('User with ID = ' || PASSENGER || ' does not exist.');
        ELSIF FLIGHT_FOUND = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Flight with number = ' || FLIGHT || ' does not exist.');
        END IF;
    END;

--Tests
EXECUTE BOOK_FLIGHT(902380, 'RY900', 'STUDENT');
EXECUTE BOOK_FLIGHT(48666411, 'ET340', '-');
EXECUTE BOOK_FLIGHT(41155478, 'FR210', 'STUDENT');
EXECUTE BOOK_FLIGHT(3326448, 'FR210', 'STUDENT');
EXECUTE BOOK_FLIGHT(47331569, 'IB887', 'STUDENT');
EXECUTE BOOK_FLIGHT(902380, 'KL237', 'CHILD');
EXECUTE BOOK_FLIGHT(151632, 'KL237', 'W-VETERAN');
EXECUTE BOOK_FLIGHT(4411556, 'ES922', 'CHILD');
EXECUTE BOOK_FLIGHT(4411556, 'KL237', 'STUDENT');
EXECUTE BOOK_FLIGHT(47331569, 'KL237', '-');
EXECUTE BOOK_FLIGHT(902380, 'IB887', '-');
EXECUTE BOOK_FLIGHT(4225448, 'RY900', '-');
EXECUTE BOOK_FLIGHT(47331569, '12345', '-');




--Get Proc: Procedure that retrieves a cursor to the flights of a passenger

CREATE OR REPLACE PROCEDURE GETCLIENTSOFFLIGHTCURSOR (
    F_NO IN BOOKINGS.FLIGHT_NUMBER%TYPE,
    CUR_CLIENTS OUT SYS_REFCURSOR )
    IS 
    BEGIN
    OPEN CUR_CLIENTS FOR
    SELECT * FROM BOOKINGS WHERE FLIGHT_NUMBER = F_NO;
    
    END;
    
   
   --Procedure to update nationalities table after initial setup
   
   CREATE OR REPLACE PROCEDURE INITIALIZE_NATIONALITIES_COUNTER
    IS 
    CURSOR CUR_NATS IS
    SELECT COUNT(*) AS COUNT, NATIONALITY 
    FROM PASSENGERS
    GROUP BY NATIONALITY;
    TMP_NATIONS CUR_NATS%ROWTYPE;
    BEGIN
    OPEN CUR_NATS;
    LOOP
            FETCH CUR_NATS INTO TMP_NATIONS;
            EXIT WHEN CUR_NATS%NOTFOUND;
            UPDATE NATIONALITIES 
            SET COUNT = TMP_NATIONS.COUNT
            WHERE SHORT_NAME = TMP_NATIONS.NATIONALITY;
    END LOOP;
    CLOSE CUR_NATS;
END;


EXECUTE INITIALIZE_NATIONALITIES_COUNTER;