OTT Wars — Content Strategy Intelligence System
Tools: PostgreSQL · Power BI  
Dataset: 22,998 titles · 4 platforms · 1920s–2021  
Platforms: Netflix (8,807) · Amazon Prime (9,668) · Disney+ (1,450) · Hulu (3,073)
---
Project Overview
Netflix, Amazon, Disney+, and Hulu are fighting for the same subscriber attention — but with fundamentally different content strategies. This project analyses what each platform actually bets on: which genres, which geographies, which formats, and how those bets have shifted over time.
The goal was not to describe what exists on each platform but to diagnose the strategic logic behind content decisions — and find where the data tells a different story than the public narrative.
The project is structured in two analytical layers, with a third Python NLP layer planned:
Layer 1 — Exploratory analysis: what each platform has, who made it, where it came from, how long it runs
Layer 2 — Strategic intelligence: how content strategy has shifted over time, which bets are being doubled down on, which are being quietly abandoned
Layer 3 (planned) — Python NLP: semantic clustering, topic modelling, sentiment analysis on descriptions
---
SQL Skills Demonstrated
Layer 1 — Exploratory Analysis
Skill	Query	Purpose
UNION ALL across 4 tables	All queries	Single unified view across platforms
REGEXP_SPLIT_TO_TABLE	Categories, cast, country, descriptions	Handle comma-separated multi-value fields
CASE WHEN pivot	Category, duration, platform comparison	Rotate rows into comparable columns
NULL and data quality checks	Every query	Explicit investigation before analysis
HAVING for post-aggregation filter	Platform overlap, category analysis	Filter after grouping
TO_DATE and EXTRACT	Seasonality, temporal queries	Parse string dates into usable format
SPLIT_PART and CAST	Duration analysis	Extract numeric values from mixed strings
Layer 2 — Strategic Intelligence
Skill	Query	Purpose
CTEs — single step	Category growth/decline	Separate transformation from aggregation
CTEs — chained (3+)	Overlap over time, text mining	Multi-step pipelines where each CTE feeds the next
Window functions — LAG	YoY growth percentage	Compare each year to previous without self-join
Window functions — RANK	Top words per platform per decade	Rank within partitions
PARTITION BY	Both window function queries	Reset window calculation per category or platform
Subquery optimisation	Text mining CTE Y	Filter before explosion to reduce row count from millions to thousands
NULLIF for division safety	All percentage calculations	Prevent division by zero errors
---
Dataset
Platform	Titles	Date Range	Notes
Netflix	8,807	2008–2021	Most complete date_added data
Amazon Prime	9,668	1920s–2021	98% missing date_added, 93% missing country
Disney+	1,450	1920s–2021	Smallest catalogue — owned IP and licensed content
Hulu	3,073	2000s–2021	99.9% missing director field
All datasets sourced from Kaggle. Data covers content available up to mid-2021 — 2020s figures are partial.
---
Data Quality Issues
Platform	Field	Issue	Impact on Analysis
Amazon	country	93% empty	Geographic analysis excludes Amazon entirely
Amazon	date_added	98% empty	All temporal and YoY analysis excludes Amazon
Amazon	director	Contains production companies ("Moonbug Entertainment", "Pinkfong")	Noted as data limitation in director analysis
Amazon	duration	124 movies with 0 minutes	Likely trailers or corrupted entries — filtered
Hulu	director	99.9% empty (3,070 of 3,073 titles)	Director analysis excludes Hulu — data collection gap, not content strategy
All platforms	listed_in, cast, country	Comma-separated multi-value fields	Required REGEXP_SPLIT_TO_TABLE for accurate counts
All platforms	cast, director	"1" appearing as name	Corrupted fields — filtered before analysis
Disney	duration	196 titles under 15 minutes	Correctly classified as animated shorts — not an error
---
Analytical Approach
Each query below reflects a business hypothesis tested against the data. Queries follow a consistent structure: data quality check → core logic → cross-platform extension.
---
Layer 1 — Exploratory Analysis
---
Q1. What type of content does each platform have?
Business question: Is each platform primarily a movie platform or a TV show platform?
SQL approach: UNION ALL across all 4 tables, grouped by type. CASE WHEN pivot to separate movie and series counts per platform.
Key findings:
Netflix and Amazon are ~70% movies
Hulu is near 50-50 — most balanced platform
Disney skews heavily toward movies driven by animation and Pixar catalogue
Amazon's 9,668 titles is the largest catalogue by volume — but volume does not equal focus
---
Q2. Which categories dominate each platform?
Business question: Does content data confirm each platform's stated identity?
SQL approach: REGEXP_SPLIT_TO_TABLE to explode comma-separated `listed_in` field into individual category rows. Subquery pattern to split before aggregating. CASE WHEN pivot for movie vs series counts. Combined UNION ALL for cross-platform comparison.
Key findings:
Drama and Comedy are universal — every platform's top 2 categories
The #1 category reveals each platform's true identity:
Netflix: International Movies — global reach strategy confirmed
Amazon: Drama — broadest content warehouse, no clear anchor
Disney: Family — exactly what the brand promises
Hulu: Drama — least differentiated platform
Disney has the clearest strategic identity. Hulu has the weakest.
Data quality note: Compound category names like "Arts, Entertainment and Culture" split incorrectly on commas. Results for compound categories should be treated cautiously.
---
Q3. Which actors appear most frequently per platform?
Business question: Is there evidence of exclusive talent deals, or do actors appear across platforms freely?
SQL approach: REGEXP_SPLIT_TO_TABLE on `cast` field. NULL check before aggregating. CASE WHEN pivot for movie vs series split.
Key findings:
Top actors by appearance are dominated by Indian cinema stars — Shah Rukh Khan, Anupam Kher, Akshay Kumar lead Netflix
Confirms Netflix's aggressive Bollywood licensing strategy — consistent with International Movies being their #1 category
Anupam Kher appears across Netflix (43), Amazon (16), Disney (1) — Bollywood licensing is non-exclusive; platforms share international content
TV series actor counts are lower — series credit showrunners, not individual episode directors
Data quality note: "1" appearing as an actor name — corrupted cast field requiring NULL filtering before analysis.
---
Q4. Which directors appear most per platform?
Business question: Do director-exclusive deals exist, or is director content freely licensed?
SQL approach: REGEXP_SPLIT_TO_TABLE on director field. Separate UNION ALL block to count NULL director entries per platform. Combined with main query using UNION ALL.
Key findings:
Martin Scorsese on Netflix: 12 movies — aggressive catalogue acquisition confirmed
John Lasseter on Disney: 16 movies — Pixar's chief creative officer; confirms animation-heavy catalogue
TV series directors appear less — pilot directors only; showrunners run series
Data quality notes:
Hulu director field: 99.9% empty — data collection gap, not a content insight
Amazon director field: contains production companies — fields not cleaned before dataset publication
---
Q5. Which countries produce the most content per platform?
Business question: Is Netflix actually a global platform, or is global positioning marketing language?
SQL approach: REGEXP_SPLIT_TO_TABLE on `country` field for co-productions. Separate UNION ALL block for NULL/empty country entries. Combined query across all platforms.
Key findings:
Netflix is the only genuinely global platform — sourcing from 70+ countries
US: 3,689 | India: 1,046 | UK: 804 | Canada, France, Japan, Spain, Germany all 200-400+
Disney is predominantly US-centric (1,184 US, everything else under 200)
Hulu: US and Japan focused — 281 Japanese titles, almost entirely anime series
South Korea on Netflix: 231 titles, 170 series vs 61 movies — K-dramas dominate
India on Netflix: 1,046 titles, 962 movies vs 84 series — Bollywood movie catalogue, very few Indian originals
Data quality note: Amazon: 8,996 titles (93%) have no country listed — geographic analysis excludes Amazon.
---
Q6. Which decades does each platform draw content from?
Business question: Is Netflix a current-content platform or does it invest in historical content?
SQL approach: Integer division on release_year for decade bucketing — `CONCAT(release_year/10, '0s')`. CASE WHEN pivot for movie vs series split. UNION ALL across all platforms.
Key findings:
Amazon uniquely holds significant pre-1960s content — 1930s: 137 titles, 1940s: 173, 1950s: 155. Heavy archive and classic film licensing
Disney's oldest content is 1920s — owned IP (Mickey Mouse shorts from 1928, Snow White 1937, Fantasia 1940), not licensed
Netflix focuses almost entirely on post-1990s — not an archive platform
Netflix 2020s appears lower than 2010s because dataset cuts off mid-2021 (1.5 years vs 10 years of data)
---
Q7. When do platforms add content — is there a seasonal strategy?
Business question: Does Netflix time content releases? Did Disney launch gradually or all at once?
SQL approach: TO_DATE conversion on `date_added` string field (stored as "Month DD, YYYY"). EXTRACT for year and month. NULL filter before date conversion.
Key findings:
Disney November 2019: 730 titles in one month — Disney+ launch date (November 12, 2019). Entire catalogue uploaded simultaneously
Netflix: no seasonal spike. Consistent 100-200 additions per month year-round — deliberate strategy to maintain subscriber engagement regardless of season
Amazon: 98% of date_added field empty — temporal analysis excludes Amazon entirely
---
Q8. How long are movies and how many seasons do TV shows run?
Business question: Is the mini-series format becoming dominant? Are streaming platforms changing movie length norms?
SQL approach: SPLIT_PART on `duration` field to extract numeric value before "min" or "Season". CAST to INTEGER. CASE WHEN to separate movie duration from series season count. Bucket pivots using CASE WHEN ranges for movie minutes and series season counts.
Key findings — Movies:
Majority fall between 60-135 minutes across all platforms
Amazon has highest proportion of sub-60 minute content — archive of short films and pre-1960s content
Disney: 196 titles under 15 minutes — original animated shorts and Pixar short films
Amazon: 124 movies with 0-minute duration — likely trailers or corrupted entries
Key findings — Series:
1-season shows dominate every platform
Netflix's 1-season dominance is most extreme — mini-series strategy confirmed
Hulu has the longest tail of multi-season shows — anime series (Naruto, One Piece) drive this
---
Q9. Which titles appear on multiple platforms?
Business question: Are platforms becoming more exclusive, or is content sharing still common?
SQL approach: Title-matching UNION ALL across all 4 platforms. GROUP BY title with HAVING COUNT(*) > 1. CASE WHEN pivot to show which platforms each shared title appears on. Separate queries for Movies and TV Shows. STRING_AGG as an alternate method.
Key findings — Movies:
No title appears on all 4 platforms — maximum overlap is 3 titles
Netflix + Disney overlaps: almost entirely pre-2019 Disney IP (Mary Poppins Returns, The Little Mermaid, Bolt) — content licensed to Netflix before Disney+ launched, now being pulled back
Netflix + Amazon overlaps: heavily Bollywood — Kabhi Khushi Kabhie Gham, Kal Ho Naa Ho — Bollywood licensing is non-exclusive
Key findings — TV Shows:
Netflix + Hulu anime overlap is massive — Attack on Titan, Naruto, Bleach — anime licensing is completely non-exclusive
Disney + Hulu overlap includes Disney-owned IP (The Simpsons, Marvel's Runaways) — Disney owns a significant stake in Hulu; corporate structure visible in content data
---
Layer 2 — Strategic Intelligence
---
Q1. Are Netflix content categories growing or declining over time?
Business question: Which genres is Netflix betting on? Which are being quietly abandoned?
SQL approach: CTE to split categories and extract year from date_added. CASE WHEN pivot for year columns 2017-2021. Second CTE to calculate YoY growth percentages using arithmetic on pivoted columns. Same output also implemented using LAG window function (PARTITION BY category, ORDER BY year) — demonstrating both approaches for the same business question.
Key findings:
Documentaries (movies) declined 52% from 2017-2021 — Docuseries held stable. Netflix shifted from standalone documentary films to serialised formats (Tiger King, Making a Murderer, The Last Dance). Same appetite, different format
Stand-Up Comedy collapsed: 89 additions (2018) → 17 (2021). Sharpest proportional decline of any major category. High production cost, low rewatch value
International Movies and International TV Shows are #1 by volume every year — global licensing strategy consistent throughout
Korean TV Shows: +271% in 2018-2019, then -42% and -63%. Volatile acquisition timing, not strategic withdrawal — Squid Game launched September 2021, outside this dataset
Spanish-Language TV Shows: +35% in 2020-2021 — only category growing against universal declining trend
---
Q2. Which categories is Netflix actively investing in vs those built historically?
Business question: Where is Netflix still placing bets right now?
SQL approach: CTE to split categories and extract year. CASE WHEN to bucket pre-2019 vs post-2019. ROUND with NULLIF for percentage calculation.
Key findings:
High recency + large catalogue = active strategic investment:
Romantic Movies: 70.9% post-2019 (616 total)
Children & Family: 68.5% post-2019 (641 total)
Comedies: 67.8% post-2019 (1,674 total)
Low recency + large catalogue = early investment now slowing:
Stand-Up Comedy: 38.2% recent — 62% of catalogue built pre-2019
Documentaries: 46.6% recent
International Movies: 57.9% recent — bulk Bollywood acquisition slowing
Teen TV, Reality TV, TV Horror: 70%+ recency despite small catalogues — deliberate gap-filling in underserved genres
---
Q3. Which countries is Netflix adding content from — and how has that shifted?
Business question: Is Netflix's international strategy sustained investment or bulk acquisition followed by pullback?
SQL approach: Pivot with CASE WHEN for years 2017-2021. REGEXP_SPLIT_TO_TABLE on country field. Netflix-only (Amazon date_added 98% empty).
Key findings:
India: peaked at 332 movie additions in 2018, collapsed to 88 by 2021 — Netflix exhausted Bollywood licensing catalogue and pivoted toward Indian original series. Indian TV shows stayed flat at 14-18 per year throughout
Egypt, Philippines, Hong Kong: near-zero → spike → collapse. Same bulk acquisition pattern across all three
Nigeria: sustained growth from 1 title (2017) to 28 (2021) — Nollywood investment still in expansion phase
Pattern: Netflix enters new markets through bulk catalogue deals, then shifts to original production
---
Q4. Are movies getting longer or shorter over time?
Business question: Is Netflix acquiring longer, more cinematic content as it matures? How does Netflix's acquisition trend compare to global production trends?
SQL approach: Two separate queries — one using date_added year (acquisition strategy), one using release_year (global production trend). AVG duration grouped by platform and year. TO_DATE conversion for date_added.
Key findings:
Global production trend: Movie durations peaked in the 1960s at 110-130 minutes. Gradual decline post-2005 — streaming consumption habits, mobile viewing, indie content
Netflix acquisition trend: 81 mins (2008) → 102 mins (2021). Counter to global trend — Netflix deliberately acquiring longer, more cinematic content as a premium differentiation strategy
Disney: decreasing trend in recent years (73 mins 2019 → 67 mins 2021) — consistent with animation shorts strategy
Disney pre-1940: 7-9 minute average — original Mickey Mouse animated shorts
---
Q5. Is the mini-series format accelerating?
Business question: Netflix pioneered the limited series format. Is 1-season now the dominant form across all platforms?
SQL approach: SPLIT_PART on duration field to extract season count. CASE WHEN season buckets. Filtered to TV Shows only. Grouped by platform and year_added.
Key findings:
Netflix: 1-season shows outnumber 2-season shows 4:1 consistently from 2016-2021. Peak: 414 one-season additions in 2019
Disney followed the trend post-2019 launch
Hulu: more balanced — maintains long-running shows alongside mini-series
Amazon: only 2021 data available. 20 one-season vs 58 two-season — suggests preference for acquiring established multi-season shows
---
Q6. Is platform overlap increasing or decreasing over time?
Business question: Are streaming platforms becoming more exclusive? Is shared licensing dying?
SQL approach: 3-CTE structure. CTE X: UNION ALL of Netflix, Disney, Hulu with year extracted (Amazon excluded — 98% missing date_added). CTE Y: titles appearing on 2+ platforms in the same year using HAVING COUNT(DISTINCT platform) > 1. CTE Z: total titles per year. Final SELECT: LEFT JOIN Y to Z for overlap percentage calculation.
Key findings:
Less than 1% of annual additions appear simultaneously on multiple platforms — 4-13 titles per year vs 400-600+ annual additions per platform
Movie overlap: 0.1%-0.7% per year. TV Show overlap: 0.2%-0.7%
Combined with Disney's post-2019 content pullback from Netflix — confirms the streaming industry's accelerating shift toward platform exclusivity
---
Q7. What themes appear in content descriptions — and do they reveal platform identity?
Business question: Can you read a platform's strategic identity from how it describes its own content?
SQL approach: REGEXP_SPLIT_TO_TABLE on description field to tokenise into individual words. REGEXP_REPLACE with [^a-z] pattern to clean non-alphabetic characters. Stopword filtering via NOT IN list. RANK() window function (PARTITION BY platform and decade, ORDER BY word_count DESC) to identify top 10 words per platform per decade. Separate query for Disney run independently as their smaller catalogue was buried in the combined top 200.
Key findings:
Platform	Identity	Signature vocabulary
Netflix	Youth & Drama	young, documentary, teen, school, woman
Amazon	Volume & Variety	songs, classic, film, history — no clear anchor
Disney	Magic & Heroes	magical, heroes, rescue, mickey, donald, christmas
Hulu	Series-Forward	"series" is #3 word — higher than any other platform
Disney has the clearest content identity — brand vocabulary is embedded in how content is described
Amazon is the only platform where "songs" features prominently — Bollywood musical strategy invisible in category analysis alone
---
Q8. Which vocabulary is unique to specific decades — and what cultural moments does this reveal?
Business question: Can you see cultural shifts in how content is described across decades?
SQL approach: Multi-CTE pipeline. CTE X: UNION ALL all platforms. CTE Y: REGEXP_SPLIT_TO_TABLE wrapped in a subquery to apply length filter and stopword exclusion before aggregation — this optimisation reduced rows entering CTE Z from millions to thousands, cutting execution time by ~40%. CTE Z: word counts per platform per decade. Pivoted CTE: CASE WHEN to rotate platforms into columns with total count. decade_count CTE: COUNT(DISTINCT decade) per word. Final SELECT: filter for words appearing in only 1 decade with total > 5.
Performance note: Full 4-platform text mining across 22,998 title descriptions exceeded 75 minutes execution time. This query identifies the performance boundary of SQL regex for corpus-scale NLP — production text analysis at this scale requires dedicated frameworks (spaCy, NLTK). The subquery optimisation in CTE Y is documented in the query comments. Gap analysis between decade appearances (detecting vocabulary that disappeared then revived) was scoped for Python Layer 3 where execution time is not a constraint.
Key findings:
2020s: "covid" appears as a unique descriptor — first time a real-world pandemic appears explicitly in streaming content descriptions. Accompanying themes: caregiving, nonverbal communication, social isolation, TikTok
2010s: First decade where LGBTQ themes ("homosexuality", "closeted") and mental health ("bipolar") appear as explicit content descriptors — mainstream cultural normalisation visible in content data
2010s: South Indian cinema vocabulary ("rajinikanth", "kaala", "narasimha", "vaseegaran") exclusively in Netflix — distinguishing South Indian acquisition strategy from broader Bollywood focus
Pre-1960s: Dominated by character names from Amazon's archive Western serials — confirms Amazon's unique archive content strategy
---
Layer 3 — Planned (Python NLP)
The SQL text mining work in this project identified the performance boundary of regex-based analysis on large text corpora. Layer 3 will implement equivalent and extended analysis using Python:
Sentiment analysis on description tone by platform using pre-trained models
Semantic clustering of content descriptions using sentence transformers
Topic modelling across decades using LDA
Platform content strategy classification — can a model predict which platform a title belongs to from its description alone?
Gap analysis for decade-unique vocabulary — detecting words that disappeared for multiple decades then revived (scoped out of SQL due to execution time constraints)
The stopword lists, tokenisation approach, and decade bucketing logic developed in SQL carry forward directly into the Python implementation.
---
Business Recommendations
Netflix's premium cinematic positioning is data-confirmed — longer films, serialised formats, reduced stand-up. Requires sustained original production investment as licensed content dries up
International content follows a predictable pattern — bulk acquisition for market entry, original production for sustained presence. Nigeria is the next market in active expansion
Underserved genre gaps are active Netflix bets — Teen TV (79.7% recency), Reality TV (76.1%), TV Horror (72%) show highest recent investment ratios
British content is structurally constrained — BBC and ITV rights protection limits Netflix's UK expansion regardless of demand signals
Amazon's archive strategy is genuinely differentiated — the only platform investing in pre-1960s content; unique positioning not replicated by any competitor
---
Analysis by Aman Vyas · LinkedIn · GitHub Profile · This Repository
