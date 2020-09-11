-- TASK:

IF Object_id('tempdb..#test_table') IS NOT NULL 
  DROP TABLE #test_table 

DROP TABLE IF EXISTS dbo.#test_table

CREATE TABLE #test_table 
  ( 
     id INT 
  ) 

GO 

INSERT INTO #test_table 
VALUES (1), (2), (8), (4), (9), (7), (3), (10) --<-- Отсутствуют числа 5 и 6
GO

SELECT *
FROM #test_table;


-- SOLUTION:

-- Define block with all numbers from "#test_table" table from MIN to MAX, including the missing ones
WITH numbers AS
(
    SELECT MIN(id) AS num
    FROM #test_table
    UNION ALL
    SELECT num + 1
    FROM numbers
    WHERE num < ANY(SELECT id FROM #test_table)
)

-- Select those numbers from "numbers" block that are not presented in "#test_table" table
SELECT n.num
FROM #test_table AS t
RIGHT JOIN numbers AS n ON t.id = n.num
WHERE t.id is null;