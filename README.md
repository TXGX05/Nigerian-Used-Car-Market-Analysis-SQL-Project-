# Nigerian-Used-Car-Market-Analysis-SQL-Project-

# Nigerian Used-Car Market Price Analysis (SQL Project)

## Introduction
Nigeria's used-car market is large, fast-moving, and highly informal, with prices shaped by brand reputation, import condition, age, mileage, and buyer purchasing power. For most buyers and small dealers, understanding "fair value" means comparing a listing against dozens of similar ones by eye — a slow and error-prone process.

This project analyzes a dataset of **4,095 car listings** from the Nigerian used-car market, covering brand (Make), year of manufacture, condition (Brand New / Foreign Used / Nigerian Used), mileage, engine size, fuel type, transmission, and price (in Naira).

The raw data required cleaning before it could be trusted: prices were stored as text with comma separators (e.g. `"3,120,000"`), a number of mileage and engine-size entries were impossible outliers (one listing showed nearly 10 million kilometres), and several categorical fields (condition, fuel, transmission) had blank entries. All of this was cleaned directly in **SQL**, with every step commented in the accompanying `.sql` script.

The cleaned dataset was then used to answer 15 beginner-level business questions using core SQL techniques: `SELECT`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`, `LIMIT`, aggregate functions (`COUNT`, `AVG`, `MIN`, `MAX`), `CASE WHEN` bucketing, and a simple subquery.

## Problem Statement
Car listings in Nigeria are rarely benchmarked against structured market data. Buyers often cannot tell whether a price is fair for a car's brand, age, and mileage; sellers and dealers similarly lack a simple, data-backed way to price their stock competitively.

At the same time, raw scraped listing data is not usable out of the box — inconsistent formatting (prices as text), unrealistic outlier values, and missing fields all stand between the raw file and a trustworthy answer to even a simple question like *"what does a Toyota typically cost?"*

This project addresses that gap by using SQL to clean the dataset and then answer a set of concrete, beginner-friendly business questions that mirror how a real buyer, seller, or analyst would actually interrogate this market.

## Objectives
1. Clean the raw car-listing data using SQL — converting text-formatted prices into real numbers, removing impossible mileage/engine-size outliers, and labelling missing categorical values clearly.
2. Write a single, well-structured `.sql` script that is thorough yet simple enough for a SQL beginner to read and learn from, with a comment on virtually every line.
3. Answer 15 concrete business questions covering market structure, brand pricing, condition, transmission, fuel type, car age, and mileage.
4. Demonstrate a range of beginner-to-early-intermediate SQL techniques (aggregate functions, `GROUP BY`, `HAVING`, `CASE WHEN`, subqueries, multi-condition `WHERE` filters) within realistic business contexts.
5. Translate the SQL query results into clear insights and practical recommendations for buyers, sellers, and dealers in the Nigerian used-car market.

## Insights

### Headline Market Snapshot
| Metric | Value |
|---|---|
| Total Listings | 4,095 |
| Average Price | ₦4.27M |
| Price Range | ₦458K – ₦58.8M |

The market spans an enormous range — from a ₦458,000 budget Honda to a ₦58.8 million Foreign Used Mercedes-Benz — confirming that "the used-car market" is really several very different markets bundled together.

### Brand Popularity
| Make | Listings |
|---|---|
| Toyota | 1,469 |
| Lexus | 464 |
| Mercedes-Benz | 436 |
| Honda | 428 |
| Ford | 197 |

Toyota alone accounts for roughly 36% of all listings, reflecting its reputation for reliability and parts availability.

### Priciest vs Most Affordable Brands (avg., min. 5 listings)
| Rank | Priciest | Most Affordable |
|---|---|---|
| 1 | Land Rover — ₦10.21M | Opel — ₦1.46M |
| 2 | Jeep — ₦9.58M | Renault — ₦1.56M |
| 3 | GMC — ₦8.78M | Peugeot — ₦1.70M |
| 4 | Porsche — ₦7.66M | Mitsubishi — ₦1.92M |
| 5 | Mercedes-Benz — ₦6.27M | Volvo — ₦2.37M |

### Condition
| Condition | Listings | % of Market | Avg. Price |
|---|---|---|---|
| Nigerian Used | 2,521 | 61.6% | ₦3.12M |
| Foreign Used | 1,090 | 26.6% | ₦6.09M |
| Not Specified | 479 | 11.7% | ₦6.01M |
| Brand New | 5 | 0.1% | ₦24.57M |

"Nigerian Used" vehicles dominate the market by volume but are priced roughly half that of "Foreign Used" imports on average.

### Age & Mileage Both Strongly Predict Price
| Car Age | Listings | Avg. Price |
|---|---|---|
| 0–5 years | 143 | ₦16.05M |
| 6–10 years | 815 | ₦6.03M |
| 11–15 years | 1,633 | ₦3.29M |
| 15+ years | 1,026 | ₦1.98M |

| Mileage Band | Listings | Avg. Price |
|---|---|---|
| Low (0–50,000 km) | 280 | ₦10.33M |
| Medium (50,001–150,000 km) | 1,542 | ₦4.85M |
| High (150,001–300,000 km) | 1,758 | ₦3.20M |
| Very High (300,000+ km) | 410 | ₦2.54M |

A 0–5 year-old car is priced roughly **8x** higher on average than one over 15 years old; low-mileage cars are priced about **4x** higher than very-high-mileage cars.

### Transmission & Fuel
- **Automatic** dominates listings (3,810 of 4,095) and is priced well above **Manual** on average (₦4.36M vs ₦2.51M).
- **Petrol** is overwhelmingly the primary fuel type (3,535 listings); **Diesel** carries the highest average price (₦5.87M) among fuel types with meaningful counts.

### Price Segments
| Segment | Listings | Avg. Price |
|---|---|---|
| Budget (< ₦2M) | 1,146 | ₦1.42M |
| Mid-Range (₦2M–₦5M) | 2,017 | ₦3.21M |
| Premium (₦5M–₦10M) | 658 | ₦6.76M |
| Luxury (₦10M+) | 274 | ₦18.00M |

Nearly half the market (49.3%) falls into the Mid-Range segment.

### Widest Price Range by Brand
**Mercedes-Benz** has the widest spread of any brand (₦630,000 – ₦58.8M, a ₦58M+ range), followed by Nissan and Toyota — showing these brand names alone say little about expected price without also knowing condition, age, and mileage.

## Recommendations
1. **For buyers on a budget:** prioritize Nigerian Used vehicles from affordable brands (Honda, Peugeot, Mitsubishi, Mazda).
2. **For buyers prioritizing value retention:** favor lower-mileage, newer vehicles — age and mileage are the two strongest single predictors of price.
3. **For sellers and dealers:** price using brand + condition + age-band + mileage-band together, not brand alone.
4. **For dealers stocking inventory:** the Mid-Range segment (₦2M–₦5M) represents roughly half of all market activity — prioritize stock here.
5. **For platforms collecting this kind of data:** enforce numeric-only price fields at entry and add range validation on mileage/engine size to prevent extreme outliers.
6. **For further analysis:** extend this SQL project with year-over-year trend queries or a join against a brand country-of-origin/import-duty reference table to explain price gaps in terms of cost structure rather than brand prestige alone.

## Conclusions
This project turned a raw, inconsistently formatted CSV of 4,095 Nigerian car listings into a clean SQL table and answered 15 practical business questions using beginner-friendly, heavily commented SQL. The analysis confirms that **condition, car age, and mileage** are the dominant, intuitive drivers of price, that Toyota's market dominance is driven by both volume and mid-range affordability, and that the market is heavily concentrated in the Mid-Range price segment.

Beyond the specific findings, the accompanying `.sql` script is itself a learning resource: it demonstrates real-world SQL data cleaning (`REPLACE`, `CAST`, `COALESCE`, `CASE WHEN` for outlier handling) alongside a full suite of beginner analytical patterns (`GROUP BY`, `HAVING`, `ORDER BY`, `LIMIT`, subqueries, multi-condition filtering) — all applied to a single, realistic Nigerian dataset from start to finish.
