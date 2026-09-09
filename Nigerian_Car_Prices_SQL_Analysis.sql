/* ============================================================================
   PROJECT:  Nigerian Used-Car Market Analysis (SQL)
   DATASET:  Nigerian_Car_Prices.csv  (4,095 car listings)
   AUTHOR:   Prepared for a beginner-friendly SQL learning project
   TOOL:     Written for SQLite (works with only tiny tweaks in MySQL/Postgres)

   WHAT THIS FILE DOES, STEP BY STEP:
     STEP 1 -> Look at the raw data exactly as it was imported (no changes yet)
     STEP 2 -> Clean the raw data using SQL and save it into a new, tidy table
     STEP 3 -> Run business-question queries against the CLEAN table only

   HOW TO READ THIS FILE:
     - Every query has a comment block ABOVE it explaining the business
       question in plain English.
     - Almost every single line ALSO has a short comment (--) explaining
       what that specific line is doing.
     - Comments starting with two dashes (--) are single-line comments in SQL.
     - Comments wrapped in slash-star ... star-slash are multi-line comments in SQL.
   ============================================================================ */


/* ============================================================================
   STEP 1: LOOK AT THE RAW (UNCLEANED) DATA
   ============================================================================
   The raw data was imported into a table called "raw_car_prices" exactly as
   it appears in the original CSV file. Nothing has been changed yet.
   Before cleaning anything, a beginner should always LOOK at the data first.
*/

-- Show the first 10 rows of the raw table so we can see what the data looks like
SELECT *                              -- select every column
FROM raw_car_prices                   -- from the raw (untouched) table
LIMIT 10;                             -- only show 10 rows, not all 4,095

-- Count how many total rows (car listings) are in the raw table
SELECT COUNT(*) AS total_raw_rows     -- COUNT(*) counts every row; rename the result "total_raw_rows"
FROM raw_car_prices;                  -- from the raw table

-- Check how many rows are missing a value in each important column
-- (this tells us how "dirty" the data is before we clean it)
SELECT
    SUM(CASE WHEN Year_of_Manufacture IS NULL THEN 1 ELSE 0 END) AS missing_year,   -- count blank years
    SUM(CASE WHEN Condition          IS NULL THEN 1 ELSE 0 END) AS missing_condition, -- count blank condition
    SUM(CASE WHEN Mileage            IS NULL THEN 1 ELSE 0 END) AS missing_mileage,   -- count blank mileage
    SUM(CASE WHEN Engine_Size        IS NULL THEN 1 ELSE 0 END) AS missing_engine,    -- count blank engine size
    SUM(CASE WHEN Fuel               IS NULL THEN 1 ELSE 0 END) AS missing_fuel,      -- count blank fuel type
    SUM(CASE WHEN Transmission       IS NULL THEN 1 ELSE 0 END) AS missing_transmission -- count blank transmission
FROM raw_car_prices;                  -- run this check on the raw table


/* ============================================================================
   STEP 2: CLEAN THE DATA WITH SQL AND BUILD A NEW "CLEANED" TABLE
   ============================================================================
   Problems found in the raw data that we need to fix:
     1) "Price" is stored as TEXT with commas in it, e.g. "3,120,000",
        so SQL treats it as words, not numbers. We must remove the commas
        and convert it into a real number.
     2) "Mileage" has some impossible values (e.g. almost 10,000,000 km),
        which are obvious data-entry mistakes. We will treat anything above
        500,000 km as invalid and turn it into NULL (blank/unknown).
     3) "Engine_Size" has some impossible values too (e.g. 371,000 cc, when
        a real car engine is roughly 600cc to 8,000cc). We will treat
        anything outside that normal range as invalid and turn it into NULL.
     4) "Condition", "Fuel", "Transmission" and "Build" have blank (NULL)
        values. Instead of leaving them blank, we label them clearly as
        'Not Specified' so they are easy to filter and understand later.
     5) We rename "Build" to "Body_Type" because that name describes the
        column (e.g. SUV) more clearly for a reader.
*/

-- If this script is re-run, delete any old cleaned table first so we don't get duplicates
DROP TABLE IF EXISTS cleaned_car_prices;   -- IF EXISTS means "only delete it if it's actually there"

-- Build a brand-new, clean table directly from the raw table using SELECT
CREATE TABLE cleaned_car_prices AS        -- create a new table named cleaned_car_prices...
SELECT
    Make,                                                        -- car brand, e.g. Toyota (no cleaning needed)

    Year_of_Manufacture,                                         -- keep the manufacture year as-is (NULL stays NULL)

    CAST(
        REPLACE(Price, ',', '') AS INTEGER                       -- REPLACE removes every comma, then CAST turns the text into a whole number
    ) AS Price,                                                  -- store the result in a column called Price (in Naira)

    COALESCE(Condition, 'Not Specified') AS Condition,           -- COALESCE fills blank Condition values with 'Not Specified'

    CASE
        WHEN Mileage BETWEEN 1 AND 500000 THEN Mileage           -- keep mileage only if it's a believable value (1 to 500,000 km)
        ELSE NULL                                                -- otherwise treat it as unknown/invalid data
    END AS Mileage,                                              -- store the cleaned result as Mileage

    CASE
        WHEN Engine_Size BETWEEN 600 AND 8000 THEN Engine_Size   -- keep engine size only if it's a believable value (600cc to 8,000cc)
        ELSE NULL                                                -- otherwise treat it as unknown/invalid data
    END AS Engine_Size,                                          -- store the cleaned result as Engine_Size

    COALESCE(Fuel, 'Not Specified') AS Fuel,                     -- fill blank Fuel values with 'Not Specified'

    COALESCE(Transmission, 'Not Specified') AS Transmission,     -- fill blank Transmission values with 'Not Specified'

    COALESCE(Build, 'Not Specified') AS Body_Type                -- fill blank Build values and rename the column to Body_Type

FROM raw_car_prices;                                             -- pull all of this from the original raw table

-- Quickly confirm the new cleaned table was created and has the same row count as the raw table
SELECT COUNT(*) AS total_cleaned_rows    -- count every row in the new table
FROM cleaned_car_prices;                 -- from the cleaned table

-- Preview the first 10 rows of the cleaned table to visually confirm the fixes worked
SELECT *                                 -- select every column
FROM cleaned_car_prices                  -- from the cleaned table
LIMIT 10;                                -- only show 10 rows


/* ============================================================================
   STEP 3: BUSINESS-QUESTION ANALYSIS
   ============================================================================
   From this point forward, EVERY query below runs against the CLEANED table
   (cleaned_car_prices), never the raw one, because we want accurate numbers.
   Each block below starts with the plain-English business question we are
   trying to answer.
*/


-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION 1: Overall, how big is this market, and what does a
-- typical car cost (cheapest, most expensive, and average price)?
-- ----------------------------------------------------------------------------
SELECT
    COUNT(*)          AS total_cars_listed,   -- COUNT(*) = how many car listings exist in total
    MIN(Price)         AS cheapest_price,      -- MIN() finds the smallest price in the whole table
    MAX(Price)         AS most_expensive_price,-- MAX() finds the largest price in the whole table
    ROUND(AVG(Price),0) AS average_price       -- AVG() finds the mean price; ROUND(...,0) removes decimal points
FROM cleaned_car_prices;                       -- looking across the entire cleaned dataset


-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION 2: Which 10 car brands (Makes) are listed the most often?
-- This tells us which brands dominate the Nigerian used-car market.
-- ----------------------------------------------------------------------------
SELECT
    Make,                            -- the car brand name
    COUNT(*) AS number_of_listings   -- how many times that brand appears in the dataset
FROM cleaned_car_prices              -- look at the cleaned data
GROUP BY Make                        -- put all rows with the same Make into one group
ORDER BY number_of_listings DESC     -- sort so the brand with the MOST listings appears first
LIMIT 10;                            -- only show the top 10 brands


-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION 3: Which 10 car brands are the MOST expensive on average?
-- Useful for identifying "premium" or luxury brands in this market.
-- ----------------------------------------------------------------------------
SELECT
    Make,                             -- the car brand name
    COUNT(*) AS number_of_listings,   -- how many listings that brand has (for context)
    ROUND(AVG(Price),0) AS average_price -- the average price for that brand, rounded to a whole number
FROM cleaned_car_prices               -- look at the cleaned data
GROUP BY Make                         -- group all rows by brand
HAVING COUNT(*) >= 5                  -- HAVING filters GROUPS; only keep brands with at least 5 listings (so 1 lucky car doesn't skew results)
ORDER BY average_price DESC           -- sort so the highest average price appears first
LIMIT 10;                             -- only show the top 10 most expensive brands


-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION 4: Which 10 car brands are the MOST affordable on average?
-- Useful for identifying budget-friendly brands for price-conscious buyers.
-- ----------------------------------------------------------------------------
SELECT
    Make,                              -- the car brand name
    COUNT(*) AS number_of_listings,    -- how many listings that brand has (for context)
    ROUND(AVG(Price),0) AS average_price  -- the average price for that brand
FROM cleaned_car_prices                -- look at the cleaned data
GROUP BY Make                          -- group all rows by brand
HAVING COUNT(*) >= 5                   -- only keep brands with at least 5 listings, for a fair average
ORDER BY average_price ASC             -- sort so the LOWEST average price appears first (ASC = ascending)
LIMIT 10;                              -- only show the 10 cheapest brands on average


-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION 5: Does a car's "Condition" (Brand New, Foreign Used, or
-- Nigerian Used) affect its price, and how many cars fall into each group?
-- ----------------------------------------------------------------------------
SELECT
    Condition,                          -- the condition category (e.g. Foreign Used)
    COUNT(*) AS number_of_listings,     -- how many cars are in this condition group
    ROUND(AVG(Price),0) AS average_price, -- the average price within that group
    MIN(Price) AS cheapest_in_group,    -- the cheapest price found in that group
    MAX(Price) AS most_expensive_in_group -- the most expensive price found in that group
FROM cleaned_car_prices                 -- look at the cleaned data
GROUP BY Condition                      -- group rows by their Condition value
ORDER BY average_price DESC;            -- sort so the most expensive condition group appears first


-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION 6: What share (percentage) of the market does each
-- Condition category represent? (e.g. what % of listings are Foreign Used?)
-- ----------------------------------------------------------------------------
SELECT
    Condition,                                                     -- the condition category
    COUNT(*) AS number_of_listings,                                -- how many cars are in this group
    ROUND(
        COUNT(*) * 100.0 /                                         -- this group's count, turned into a percentage...
        (SELECT COUNT(*) FROM cleaned_car_prices),                 -- ...divided by the TOTAL number of cars (a subquery)
    1) AS percentage_of_market                                     -- rounded to 1 decimal place, e.g. 61.5%
FROM cleaned_car_prices                                            -- look at the cleaned data
GROUP BY Condition                                                 -- group rows by Condition
ORDER BY percentage_of_market DESC;                                -- show the biggest share of the market first


-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION 7: Does the type of Transmission (Automatic vs Manual,
-- etc.) affect the average price of a car?
-- ----------------------------------------------------------------------------
SELECT
    Transmission,                        -- the transmission type
    COUNT(*) AS number_of_listings,      -- how many cars have this transmission type
    ROUND(AVG(Price),0) AS average_price -- the average price for that transmission type
FROM cleaned_car_prices                  -- look at the cleaned data
GROUP BY Transmission                    -- group rows by Transmission
ORDER BY average_price DESC;             -- show the most expensive transmission type first


-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION 8: Does Fuel type (Petrol, Diesel, Hybrid, Electric)
-- affect the average price of a car?
-- ----------------------------------------------------------------------------
SELECT
    Fuel,                                 -- the fuel type
    COUNT(*) AS number_of_listings,       -- how many cars use this fuel type
    ROUND(AVG(Price),0) AS average_price  -- the average price for that fuel type
FROM cleaned_car_prices                   -- look at the cleaned data
GROUP BY Fuel                             -- group rows by Fuel
ORDER BY average_price DESC;              -- show the most expensive fuel type first


-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION 9: How does the AGE of a car (how many years old it is)
-- relate to its price? Older cars are usually cheaper - let's prove it.
-- Note: we treat 2021 as "today" since that is the newest year in this data.
-- ----------------------------------------------------------------------------
SELECT
    CASE
        WHEN (2021 - Year_of_Manufacture) <= 5  THEN '0-5 years old'    -- newest cars
        WHEN (2021 - Year_of_Manufacture) <= 10 THEN '6-10 years old'   -- mid-age cars
        WHEN (2021 - Year_of_Manufacture) <= 15 THEN '11-15 years old'  -- older cars
        ELSE 'Over 15 years old'                                        -- oldest cars
    END AS car_age_group,                        -- label each row with an age bucket
    COUNT(*) AS number_of_listings,               -- how many cars fall into this age bucket
    ROUND(AVG(Price),0) AS average_price          -- the average price within this age bucket
FROM cleaned_car_prices                           -- look at the cleaned data
WHERE Year_of_Manufacture IS NOT NULL             -- ignore rows where we don't know the manufacture year
GROUP BY car_age_group                            -- group rows by the age bucket we just created
ORDER BY average_price DESC;                      -- show the most expensive age group first


-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION 10: How does MILEAGE (how far the car has been driven)
-- relate to price? We expect low-mileage cars to be more expensive.
-- ----------------------------------------------------------------------------
SELECT
    CASE
        WHEN Mileage <= 50000  THEN 'Low mileage (0 - 50,000 km)'         -- barely-used cars
        WHEN Mileage <= 150000 THEN 'Medium mileage (50,001 - 150,000 km)' -- moderately-used cars
        WHEN Mileage <= 300000 THEN 'High mileage (150,001 - 300,000 km)'  -- heavily-used cars
        ELSE 'Very high mileage (300,000+ km)'                             -- extremely-used cars
    END AS mileage_group,                          -- label each row with a mileage bucket
    COUNT(*) AS number_of_listings,                -- how many cars fall into this mileage bucket
    ROUND(AVG(Price),0) AS average_price           -- the average price within this mileage bucket
FROM cleaned_car_prices                            -- look at the cleaned data
WHERE Mileage IS NOT NULL                          -- ignore rows where mileage is unknown/invalid
GROUP BY mileage_group                             -- group rows by the mileage bucket we just created
ORDER BY average_price DESC;                       -- show the most expensive mileage group first


-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION 11: What are the 10 most expensive individual car
-- listings in the entire dataset, and what are their key details?
-- ----------------------------------------------------------------------------
SELECT
    Make,               -- the brand of the car
    Year_of_Manufacture, -- what year it was made
    Condition,           -- Brand New / Foreign Used / Nigerian Used
    Mileage,             -- how far it has been driven
    Price                -- the listed price
FROM cleaned_car_prices  -- look at the cleaned data
ORDER BY Price DESC      -- sort so the highest price appears first
LIMIT 10;                 -- only show the top 10 most expensive listings


-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION 12: What are the 10 most affordable individual car
-- listings in the entire dataset, and what are their key details?
-- ----------------------------------------------------------------------------
SELECT
    Make,                -- the brand of the car
    Year_of_Manufacture,  -- what year it was made
    Condition,            -- Brand New / Foreign Used / Nigerian Used
    Mileage,              -- how far it has been driven
    Price                 -- the listed price
FROM cleaned_car_prices   -- look at the cleaned data
ORDER BY Price ASC        -- sort so the lowest price appears first (ASC = ascending, low to high)
LIMIT 10;                  -- only show the 10 cheapest listings


-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION 13: Which car brand has the WIDEST price range (the
-- biggest gap between its cheapest and most expensive listing)? A wide
-- range can mean the brand covers everything from budget to luxury models.
-- ----------------------------------------------------------------------------
SELECT
    Make,                                  -- the car brand
    COUNT(*) AS number_of_listings,        -- how many listings that brand has (for context)
    MIN(Price) AS cheapest_price,          -- the cheapest listing for that brand
    MAX(Price) AS most_expensive_price,    -- the most expensive listing for that brand
    (MAX(Price) - MIN(Price)) AS price_range -- the size of the gap between cheapest and priciest
FROM cleaned_car_prices                    -- look at the cleaned data
GROUP BY Make                              -- group rows by brand
HAVING COUNT(*) >= 5                       -- only consider brands with at least 5 listings, for a meaningful range
ORDER BY price_range DESC                  -- sort so the widest price range appears first
LIMIT 10;                                  -- only show the top 10 brands with the widest range


-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION 14: A practical buyer's search - find affordable, low-
-- mileage Toyota cars (Toyota is the most-listed brand) that are Foreign
-- Used and cost under 3,000,000 Naira. This shows how SQL filters answer
-- a real shopping question, combining several conditions at once.
-- ----------------------------------------------------------------------------
SELECT
    Make,               -- confirm the brand (will always say Toyota here)
    Year_of_Manufacture, -- how old the car is
    Condition,           -- confirms it is Foreign Used
    Mileage,             -- how far it has been driven
    Price                -- the listed price
FROM cleaned_car_prices  -- look at the cleaned data
WHERE Make = 'Toyota'                 -- only Toyota cars
  AND Condition = 'Foreign Used'      -- AND only cars that are Foreign Used
  AND Price < 3000000                 -- AND only cars priced under 3,000,000 Naira
  AND Mileage IS NOT NULL             -- AND only cars where we actually know the mileage
ORDER BY Mileage ASC                  -- sort so the lowest-mileage (least driven) cars appear first
LIMIT 15;                             -- only show the top 15 matching cars


-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION 15: If we split the whole market into simple price
-- "segments" (Budget, Mid-Range, Premium, Luxury), how many cars fall into
-- each segment, and what does each segment's average price look like?
-- This gives a quick snapshot of how the overall market is structured.
-- ----------------------------------------------------------------------------
SELECT
    CASE
        WHEN Price < 2000000                    THEN '1. Budget (under 2,000,000)'          -- cheapest segment
        WHEN Price BETWEEN 2000000 AND 4999999   THEN '2. Mid-Range (2,000,000 - 4,999,999)' -- middle segment
        WHEN Price BETWEEN 5000000 AND 9999999   THEN '3. Premium (5,000,000 - 9,999,999)'   -- upper segment
        ELSE '4. Luxury (10,000,000 and above)'                                              -- top segment
    END AS price_segment,                    -- label each row with its price segment
    COUNT(*) AS number_of_listings,          -- how many cars fall into this segment
    ROUND(AVG(Price),0) AS average_price_in_segment -- the average price within this segment
FROM cleaned_car_prices                      -- look at the cleaned data
GROUP BY price_segment                       -- group rows by the price segment we just created
ORDER BY price_segment ASC;                  -- show segments in order from Budget to Luxury


/* ============================================================================
   END OF SCRIPT
   ============================================================================
   Summary of what we did:
     1. Inspected the raw data and counted missing values.
     2. Cleaned Price, Mileage and Engine_Size, and labelled blank text
        fields as 'Not Specified', saving the result into cleaned_car_prices.
     3. Answered 15 beginner-level business questions using simple SQL:
        SELECT, WHERE, GROUP BY, HAVING, ORDER BY, LIMIT, aggregate
        functions (COUNT, AVG, MIN, MAX, SUM), CASE WHEN for bucketing,
        and one small subquery for a percentage calculation.
   ============================================================================ */
