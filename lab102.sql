--PRACTICAL TASKS
--TASK 3
--3.1
DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    balance DECIMAL(10, 2) DEFAULT 0.00
);

DROP TABLE IF EXISTS  products;
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    shop VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

INSERT INTO accounts (name, balance) VALUES
 ('Alice', 1000.00),
 ('Bob', 500.00),
 ('Wally', 750.00);

INSERT INTO products (shop, product, price) VALUES
 ('Joe''s Shop', 'Coke', 2.50),
 ('Joe''s Shop', 'Pepsi', 3.00);

--3.2

BEGIN;
UPDATE accounts SET balance = balance - 100.00
 WHERE name = 'Alice';

UPDATE accounts SET balance = balance + 100.00
 WHERE name = 'Bob';
COMMIT;
--a) What are the balances of Alice and Bob after the transaction?
    --Alice = 900.00
    --Bob = 600.00
-- b) Why is it important to group these two UPDATE statements in a single transaction?
    --Because transferring money is one logical operation.Both updates must succeed together.

--  c) What would happen if the system crashed between the two UPDATE statements without a
-- transaction?
    --he first UPDATE runs (Alice loses 100)
    -- The system crashes
    -- The second UPDATE never runs (Bob does not receive money)

--3,3
BEGIN;
UPDATE accounts SET balance = balance - 500.00
 WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';
-- Oops! Wrong amount, let's undo
ROLLBACK;
SELECT * FROM accounts WHERE name = 'Alice';

-- a) What was Alice's balance after the UPDATE but before ROLLBACK?
-- Alice's initial balance was 1000.00.
-- After the UPDATE (balance - 500):
-- Alice = 500.00.
-- This updated value is visible inside the transaction before ROLLBACK.

-- b) What is Alice's balance after ROLLBACK?
-- After ROLLBACK, all changes made in the transaction are undone.
-- Therefore, Alice returns to her original balance:
-- Alice = 1000.00.

-- c) In what situations would you use ROLLBACK in a real application?
-- ROLLBACK is used when a mistake happens during a transaction,
-- such as updating the wrong record, inserting incorrect data,
-- failing a validation check, or any unexpected error.
-- It safely restores the database to its previous consistent state.

--3.4

BEGIN;
UPDATE accounts SET balance = balance - 100.00
WHERE name = 'Alice';
SAVEPOINT my_savepoint;

UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Bob';

ROLLBACK TO my_savepoint;

UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Wally';
COMMIT;

-- a) Final balances after COMMIT:
-- Alice = 900.00
-- Bob = 500.00
-- Wally = 850.00
-- Alice lost 100, Bob's temporary credit was undone, and Wally received the final transfer.

-- b) Was Bob's account ever credited?
-- Yes, Bob was temporarily credited with +100.
-- But this change was rolled back after the command:
-- ROLLBACK TO my_savepoint;
-- Therefore, in the final state Bob returned to his original balance (500.00).

-- c) Advantage of using SAVEPOINT:
-- SAVEPOINT allows you to undo only part of a transaction
-- without canceling the entire transaction.
-- This saves time and keeps valid work untouched,
-- unlike a full ROLLBACK which resets everything.

--3,5
--terminal 1
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to make changes and COMMIT
-- Then re-run:
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT

--terminal 2
BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, product, price)
 VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;


-- a) In Scenario A (READ COMMITTED), what data does Terminal 1 see?
-- Before Terminal 2 commits:
-- Terminal 1 sees the original rows from Joe's Shop:
-- Coke (2.50) and Pepsi (3.00).
-- After Terminal 2 commits:
-- Terminal 1 sees the new updated data: Fanta (3.50).
-- Explanation: READ COMMITTED always displays the latest committed data.

-- b) In Scenario B (SERIALIZABLE), what data does Terminal 1 see?
-- Terminal 1 continues to see the same original data (Coke and Pepsi),
-- even after Terminal 2 deletes these rows and inserts Fanta.
-- Explanation: SERIALIZABLE uses a completely isolated snapshot,
-- so Terminal 1 does NOT see any changes made by Terminal 2
-- until Terminal 1 finishes its own transaction.

-- c) Explain the difference between READ COMMITTED and SERIALIZABLE.
-- READ COMMITTED:
-- Terminal 1 immediately sees new committed changes from other transactions.
-- It allows non-repeatable reads and phantoms.

-- SERIALIZABLE:
-- Terminal 1 is fully isolated and works as if transactions run one-by-one.
-- It does NOT see other transactions’ changes during its execution.
-- It prevents non-repeatable reads and phantom reads,
-- providing the highest level of isolation.

--3,6
--t1
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products
 WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2
SELECT MAX(price), MIN(price) FROM products
 WHERE shop = 'Joe''s Shop';
COMMIT;
--t2
BEGIN;
INSERT INTO products (shop, product, price)
 VALUES ('Joe''s Shop', 'Sprite', 4.00);
COMMIT;

-- a) Does Terminal 1 see the new product?
-- No, Terminal 1 does NOT see Sprite.

-- b) What is a phantom read?
-- When new rows appear that were not visible in the first read.

-- c) Which isolation level prevents phantom reads?
-- SERIALIZABLE.

--3.7

--Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to UPDATE but NOT commit
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to ROLLBACK
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;
--Terminal 2:
BEGIN;
UPDATE products SET price = 99.99
 WHERE product = 'Fanta';
-- Wait here (don't commit yet)
-- Then:
ROLLBACK;

-- a) Did Terminal 1 see the price 99.99? Why is this problematic?
-- Yes, Terminal 1 saw 99.99.
-- Problem: that value was never committed.

-- b) What is a dirty read?
-- Reading uncommitted (temporary) data from another transaction.

-- c) Why avoid READ UNCOMMITTED?
-- Because it can show incorrect and unsafe data.


--Independent Exercises
-- Exercise 1
BEGIN;

-- Check Bob has enough money
DO $$
BEGIN
    IF (SELECT balance FROM accounts WHERE name='Bob') < 200 THEN
        RAISE EXCEPTION 'Insufficient funds';
    END IF;
END $$;

-- Transfer
UPDATE accounts SET balance = balance - 200 WHERE name='Bob';
UPDATE accounts SET balance = balance + 200 WHERE name='Wally';

COMMIT;

-- Final: Bob = Bob-200, Wally = Wally+200

-- Exercise 2
BEGIN;
-- Insert product
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Tea', 2.00);
SAVEPOINT s1;
-- Update price
UPDATE products SET price = 3.00 WHERE product='Tea';
SAVEPOINT s2;
-- Delete product
DELETE FROM products WHERE product='Tea';
-- Roll back to first savepoint
ROLLBACK TO s1;
COMMIT;
-- Final state: product 'Tea' exists with price = 2.00

-- Exercise 3
-- Terminal 1
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT balance FROM accounts WHERE name='Alice';
UPDATE accounts SET balance = balance - 100 WHERE name='Alice';
-- Terminal 2
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT balance FROM accounts WHERE name='Alice';
UPDATE accounts SET balance = balance - 100 WHERE name='Alice';
COMMIT;

-- Explanation
-- READ COMMITTED may allow double-withdraw.
-- SERIALIZABLE prevents it by blocking or failing one transaction.

-- Exercise 4
-- Without transactions (problem):
SELECT MAX(price), MIN(price) FROM Sells;
-- Meanwhile another user deletes/updates rows
-- Sally can see MAX < MIN because data changes mid-query.

-- Correct version :
BEGIN;
SELECT MAX(price), MIN(price) FROM Sells;
COMMIT;
-- SERIALIZABLE ensures consistent results.



-- 1. Explain each ACID property with a practical example.
-- Atomic: whole transfer succeeds or fails as one.
-- Consistent: rules stay valid (no negative balance).
-- Isolated: other users don't see partial changes.
-- Durable: committed data survives crashes.

-- 2. COMMIT vs ROLLBACK?
-- COMMIT saves changes.
-- ROLLBACK cancels changes.

-- 3. When use SAVEPOINT instead of full ROLLBACK?
-- When you want to undo only part of a transaction.

-- 4. Compare the four SQL isolation levels.
-- Read Uncommitted: dirty reads allowed.
-- Read Committed: sees only committed data.
-- Repeatable Read: same rows on re-read.
-- Serializable: full isolation, safest.

-- 5. What is a dirty read and which level allows it?
-- Reading uncommitted data.
-- Allowed by READ UNCOMMITTED.

-- 6. What is a non-repeatable read?
-- Same row gives different values on re-read.

-- 7. What is a phantom read? Which levels prevent it?
-- New rows appear on second read.
-- Prevented by SERIALIZABLE.

-- 8. Why choose READ COMMITTED over SERIALIZABLE?
-- Faster and better performance in high traffic.

-- 9. How do transactions maintain consistency?
-- They ensure operations are atomic and isolated.

-- 10. What happens to uncommitted changes after crash?
-- They are lost; only committed data persists.
