-- Seed: 006_seed_articles.sql
-- 50 articles across 5 categories for infinity scroll testing
-- Requires: admin user with id=1 (update author_id if different)
-- Run: sudo -u postgres psql -d free_api_news -f migrations/006_seed_articles.sql

-- ─── Make sure we have an admin user for seeding ─────────────────────────────
-- UPDATE users SET role = 'admin' WHERE email = 'your@email.com';

DO $$
DECLARE
  author_id BIGINT;
  cat_tech    BIGINT;
  cat_finance BIGINT;
  cat_sports  BIGINT;
  cat_world   BIGINT;
  cat_science BIGINT;
BEGIN
  -- Get first user as author (adjust if needed)
  SELECT id INTO author_id FROM users ORDER BY id LIMIT 1;
  SELECT id INTO cat_tech    FROM categories WHERE slug = 'technology';
  SELECT id INTO cat_finance FROM categories WHERE slug = 'finance';
  SELECT id INTO cat_sports  FROM categories WHERE slug = 'sports';
  SELECT id INTO cat_world   FROM categories WHERE slug = 'world';
  SELECT id INTO cat_science FROM categories WHERE slug = 'science';

  -- ── TECHNOLOGY (10 articles) ─────────────────────────────────────────────
  INSERT INTO articles (category_id, author_id, title, slug, excerpt, content, image_url, thumbnail_url, read_time_minutes, status, published_at) VALUES
  (cat_tech, author_id,
   'Apple Intelligence Comes to iPhone 16 Pro: Everything You Need to Know',
   'apple-intelligence-iphone-16-pro',
   'Apple''s on-device AI suite is finally here, and it changes how you interact with your phone.',
   'Apple Intelligence represents the most significant software leap in iPhone history. Built directly into the A18 Pro chip, the suite runs entirely on-device, ensuring your data never leaves your phone. Features include Writing Tools that can rewrite emails in different tones, a supercharged Siri that understands context across apps, and Image Playground for generating custom images. Early benchmarks show the on-device LLM outperforms similarly-sized cloud models on most tasks, making this a genuine paradigm shift for mobile AI.',
   'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=1200', 'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=400',
   3, 'published', NOW() - INTERVAL '1 hour'),

  (cat_tech, author_id,
   'Google Unveils Gemini Ultra 2.0 with Multimodal Reasoning Breakthrough',
   'google-gemini-ultra-2-multimodal',
   'The new Gemini model can reason across text, images, video, and audio simultaneously.',
   'Google DeepMind has announced Gemini Ultra 2.0, a model that fundamentally changes what multimodal AI means. Unlike its predecessor, Ultra 2.0 can hold a continuous reasoning thread across different modalities. In demos, the model watched a cooking video, read a recipe from an image, and produced step-by-step corrections in real time. Developers can access the model via API starting next month, with a consumer release planned for Q3. The model runs at 1,000 tokens per second on Google''s TPU v5 infrastructure, making it the fastest large model available commercially.',
   'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=1200', 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=400',
   4, 'published', NOW() - INTERVAL '3 hours'),

  (cat_tech, author_id,
   'Nvidia H200 GPU Ships: Data Centers Race to Upgrade',
   'nvidia-h200-gpu-data-centers',
   'The H200 delivers double the memory bandwidth of H100, transforming large-model training.',
   'Nvidia began shipping its H200 Tensor Core GPU this week, and the impact on AI infrastructure is immediate. The chip features 141GB of HBM3e memory running at 4.8 TB/s — nearly twice the bandwidth of the H100. For training large language models, this means batch sizes can double without gradient checkpointing tricks. AWS, Azure, and Google Cloud have already announced H200 instance availability. Analysts estimate the global H200 supply will remain constrained through 2026, with priority going to hyperscalers under multi-billion dollar contracts.',
   'https://images.unsplash.com/photo-1591405351990-4726e331f141?w=1200', 'https://images.unsplash.com/photo-1591405351990-4726e331f141?w=400',
   3, 'published', NOW() - INTERVAL '5 hours'),

  (cat_tech, author_id,
   'Meta Llama 4 Open-Source Release Shakes Up the AI Landscape',
   'meta-llama-4-open-source-release',
   'Meta''s latest open-weight model matches GPT-4o on most benchmarks while running locally.',
   'Meta has released Llama 4, its most capable open-weight model to date, and the community reaction has been explosive. Available in 8B, 70B, and 400B parameter variants, the models are licensed for commercial use with fewer restrictions than previous versions. The 70B variant, in particular, matches or exceeds GPT-4o on the MMLU, HumanEval, and GSM8K benchmarks while running on a single A100 GPU. Hugging Face reported over 500,000 downloads within the first 24 hours. Fine-tuning recipes and GGUF quantizations are already appearing across the open-source community.',
   'https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=1200', 'https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=400',
   4, 'published', NOW() - INTERVAL '8 hours'),

  (cat_tech, author_id,
   'Starlink Direct-to-Cell Goes Live: No More Dead Zones',
   'starlink-direct-to-cell-live',
   'SpaceX''s satellite network now connects directly to standard smartphones without special hardware.',
   'SpaceX has activated Starlink Direct-to-Cell service across the continental United States, eliminating mobile dead zones for the first time. Standard LTE smartphones — no modifications required — can now connect to Starlink satellites when terrestrial towers are unavailable. Initial service supports SMS and low-bandwidth data; voice calls are expected by Q4. T-Mobile is the launch partner, with service included in select plans at no extra cost. Coverage maps show connectivity across 98% of previously dead-zone land area, including national parks and remote highways where emergency services have long struggled.',
   'https://images.unsplash.com/photo-1446776899648-aa78eefe8ed0?w=1200', 'https://images.unsplash.com/photo-1446776899648-aa78eefe8ed0?w=400',
   3, 'published', NOW() - INTERVAL '12 hours'),

  (cat_tech, author_id,
   'Python 3.14 Released: Free-Threaded Mode Now Default',
   'python-314-free-threaded-default',
   'The Global Interpreter Lock is finally gone by default, unlocking true CPU parallelism.',
   'Python 3.14 has landed, and the headline feature is what has been years in the making: free-threaded execution is now the default mode. The Global Interpreter Lock (GIL), long the bane of CPU-bound Python code, is disabled unless explicitly re-enabled with a compatibility flag. Early benchmarks on multi-core workloads show 4-8x speedups for CPU-intensive tasks. The Python core team warns that some C extensions may behave incorrectly without the GIL, and a compatibility shim is available for packages still in transition. NumPy, Pandas, and SQLAlchemy have all shipped GIL-free compatible releases.',
   'https://images.unsplash.com/photo-1526379095098-d400fd0bf935?w=1200', 'https://images.unsplash.com/photo-1526379095098-d400fd0bf935?w=400',
   4, 'published', NOW() - INTERVAL '1 day'),

  (cat_tech, author_id,
   'Sony PlayStation 6 Specs Leak: 36 TFLOPS and 3D Stacked RAM',
   'sony-ps6-specs-leak',
   'An industry insider has shared detailed specifications for the next PlayStation console.',
   'A credible hardware leaker has published what appear to be finalized specs for the PlayStation 6, set for a 2026 holiday launch. According to the leak, the console features a custom AMD GPU delivering 36 TFLOPS of compute — more than double the PS5 — paired with 32GB of 3D-stacked GDDR7 memory offering 1.5 TB/s bandwidth. The CPU is an 8-core Zen 5 variant running at up to 4.2 GHz. Sony reportedly targeted 4K/120fps as the baseline gaming experience, with 8K support for non-gaming applications. A new DualSense 2 controller features adaptive haptic panels across its entire grip surface.',
   'https://images.unsplash.com/photo-1607853202273-232359ba4dba?w=1200', 'https://images.unsplash.com/photo-1607853202273-232359ba4dba?w=400',
   3, 'published', NOW() - INTERVAL '1 day 4 hours'),

  (cat_tech, author_id,
   'Quantum Computing Hits 1,000 Qubit Milestone at IBM',
   'ibm-quantum-1000-qubit-milestone',
   'IBM''s Condor processor crosses a symbolic threshold on the path to practical quantum advantage.',
   'IBM has announced its Condor quantum processor, featuring 1,121 superconducting qubits — the first chip to exceed the 1,000 qubit barrier. While qubit count alone does not determine usefulness, Condor also improves error rates by 10x over its predecessor, moving the needle toward error-corrected computation. IBM researchers demonstrated a 127-qubit circuit simulation that would require more classical compute than exists on Earth to verify, marking what the company calls "quantum utility." Commercial access is available via IBM Quantum Network, with 60+ organizations already running research workloads.',
   'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=1200', 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=400',
   5, 'published', NOW() - INTERVAL '2 days'),

  (cat_tech, author_id,
   'Flutter 4.0 Launches with WebAssembly as First-Class Target',
   'flutter-4-webassembly-first-class',
   'Google''s UI framework now compiles to WASM natively, delivering near-native web performance.',
   'Google has released Flutter 4.0, and the most consequential change is WebAssembly compilation as a first-class compilation target. Previous Flutter web apps ran on a JavaScript bridge that introduced overhead; WASM Flutter apps run at speeds comparable to native desktop builds. In Google''s own benchmarks, complex animations that ran at 45fps on the JS renderer now hit 120fps on WASM. The release also includes a new Material 3 Expressive design system, improved hot reload for all platforms, and native inter-op with Rust libraries via dart:ffi improvements.',
   'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200', 'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=400',
   4, 'published', NOW() - INTERVAL '2 days 6 hours'),

  (cat_tech, author_id,
   'Arc Browser for Android Finally Arrives After Two-Year Wait',
   'arc-browser-android-launch',
   'The Browser Company brings its spatial browsing paradigm to Android with some surprises.',
   'After two years of iOS exclusivity, The Browser Company has launched Arc for Android, and it brings several features not available on iOS. The signature Spaces and Folders system is fully intact, but Android users get an additional "Live Folders" feature that automatically sorts bookmarks by site update frequency. Arc also integrates directly with Android''s share sheet and supports picture-in-picture for any tab. The app is built on a Chromium fork with custom renderer optimizations that The Browser Company claims reduces tab memory usage by 40% compared to Chrome on identical hardware.',
   'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=1200', 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400',
   3, 'published', NOW() - INTERVAL '3 days'),

  -- ── FINANCE (10 articles) ────────────────────────────────────────────────
  (cat_finance, author_id,
   'Federal Reserve Signals Three Rate Cuts in 2026 as Inflation Cools',
   'fed-three-rate-cuts-2026',
   'Minutes from the January FOMC meeting show growing consensus toward easing monetary policy.',
   'The Federal Reserve released minutes from its January meeting indicating that a majority of committee members now favor three 25-basis-point rate cuts in 2026, assuming inflation continues its downward trajectory. The core PCE index fell to 2.3% in December, the closest to the Fed''s 2% target since 2021. Markets reacted immediately, with the S&P 500 gaining 1.8% and the 10-year Treasury yield falling to 4.1%. Economists at Goldman Sachs moved their first cut expectation forward to March. Mortgage rates, which peaked above 8% in late 2023, have already fallen to 6.4% in anticipation.',
   'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=1200', 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=400',
   4, 'published', NOW() - INTERVAL '2 hours'),

  (cat_finance, author_id,
   'Bitcoin Surpasses $120,000 as Institutional Demand Overwhelms Supply',
   'bitcoin-120000-institutional-demand',
   'Spot ETF inflows hit a record $3.2 billion in a single week, driving the latest price surge.',
   'Bitcoin crossed $120,000 for the first time this week as the structural supply-demand imbalance created by spot ETFs continues to accelerate. BlackRock''s iShares Bitcoin Trust recorded $1.1 billion in single-day inflows — the largest since its January 2024 launch — while the total spot ETF market absorbed approximately 18,000 BTC against daily miner production of just 450 BTC post-halving. MicroStrategy announced an additional $2 billion purchase, bringing its total holdings above 500,000 BTC. Analysts at Standard Chartered maintain a year-end target of $200,000.',
   'https://images.unsplash.com/photo-1518546305927-5a555bb7020d?w=1200', 'https://images.unsplash.com/photo-1518546305927-5a555bb7020d?w=400',
   4, 'published', NOW() - INTERVAL '4 hours'),

  (cat_finance, author_id,
   'Nvidia Becomes First Company to Hit $4 Trillion Market Cap',
   'nvidia-4-trillion-market-cap',
   'The chipmaker''s relentless AI demand story pushes it past Apple and Microsoft.',
   'Nvidia briefly crossed the $4 trillion market capitalization threshold on Tuesday, becoming the first company in history to reach that milestone. The move was driven by better-than-expected datacenter revenue guidance and confirmation of accelerating Blackwell GPU shipments. Nvidia''s datacenter segment now generates more quarterly revenue than Intel''s entire annual revenue. CEO Jensen Huang, who controls less than 10% of shares, highlighted that the company is sold out of every GPU it can manufacture through at least 2026. Shares have returned over 2,000% since the ChatGPT launch in late 2022.',
   'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=1200', 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=400',
   3, 'published', NOW() - INTERVAL '6 hours'),

  (cat_finance, author_id,
   'Indonesia''s GDP Growth Hits 6.1% in Q4, Beating All Forecasts',
   'indonesia-gdp-growth-q4',
   'Strong domestic consumption and record nickel exports drove Southeast Asia''s largest economy.',
   'Indonesia''s Central Statistics Agency reported GDP growth of 6.1% in Q4 2025, the strongest quarterly figure in four years and well above the 5.4% consensus estimate. The outperformance was driven by record nickel processing revenues as Indonesia''s downstreaming policy bore fruit, with processed nickel exports rising 340% year-over-year. Domestic consumption also surprised to the upside, with retail sales growing 8.2%. The rupiah strengthened 1.3% against the dollar on the news. President Prabowo cited the figures as validation of his economic nationalism agenda. Bank Indonesia held rates steady at 6.0%.',
   'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=1200', 'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=400',
   3, 'published', NOW() - INTERVAL '10 hours'),

  (cat_finance, author_id,
   'Warren Buffett Steps Down as Berkshire CEO, Names Greg Abel Successor',
   'warren-buffett-retires-greg-abel',
   'After 60 years at the helm, the Oracle of Omaha transitions full authority to his chosen successor.',
   'Warren Buffett, 95, announced at Berkshire Hathaway''s annual meeting that he is stepping down as CEO, effective immediately, transferring authority to Greg Abel, who has served as vice chairman of non-insurance operations since 2018. Buffett will remain as chairman. The announcement, while long anticipated, sent Berkshire B shares down 4% before recovering. Abel, in his first statement as CEO, pledged continuity with Berkshire''s investment philosophy and said he has no intention of deploying the company''s $350 billion cash pile in ways that deviate from Buffett''s principles. Buffett called it "the right time" and expressed full confidence in Abel.',
   'https://images.unsplash.com/photo-1579621970588-a35d0e7ab9b6?w=1200', 'https://images.unsplash.com/photo-1579621970588-a35d0e7ab9b6?w=400',
   4, 'published', NOW() - INTERVAL '14 hours'),

  (cat_finance, author_id,
   'OpenAI Raises $10 Billion at $300 Billion Valuation in Largest Private Round Ever',
   'openai-10-billion-funding-300b-valuation',
   'The ChatGPT maker sets a new record for private technology financing.',
   'OpenAI has closed a $10 billion funding round led by SoftBank Vision Fund 3, with participation from Microsoft, Abu Dhabi''s MGX, and several sovereign wealth funds, valuing the company at $300 billion. The round surpasses Elon Musk''s xAI funding as the largest single private technology financing in history. OpenAI CEO Sam Altman said the capital will be used to accelerate supercomputer buildout under the Stargate initiative and fund development of GPT-6. The company disclosed annual recurring revenue of $12 billion, up from $3.4 billion at the start of 2024, with enterprise customers now comprising 60% of revenue.',
   'https://images.unsplash.com/photo-1591696205602-2f950c417cb9?w=1200', 'https://images.unsplash.com/photo-1591696205602-2f950c417cb9?w=400',
   4, 'published', NOW() - INTERVAL '1 day 2 hours'),

  (cat_finance, author_id,
   'Gold Hits $3,000 Per Ounce for First Time in History',
   'gold-hits-3000-per-ounce',
   'Central bank buying and geopolitical uncertainty push the precious metal to a historic milestone.',
   'Gold futures crossed $3,000 per troy ounce for the first time, capping a 40% rally over 18 months driven by unprecedented central bank buying, particularly from China, India, and Poland. Central banks collectively purchased 1,037 tonnes of gold in 2025, the third consecutive year above 1,000 tonnes. De-dollarization concerns and elevated geopolitical tensions have made the metal attractive as a reserve asset. Gold ETFs saw $8 billion in inflows over the past quarter. Analysts at JPMorgan set a $3,500 target by year-end, citing the structural shift away from dollar-denominated reserves among emerging market central banks.',
   'https://images.unsplash.com/photo-1610375461246-83df859d849d?w=1200', 'https://images.unsplash.com/photo-1610375461246-83df859d849d?w=400',
   3, 'published', NOW() - INTERVAL '1 day 8 hours'),

  (cat_finance, author_id,
   'Stripe Goes Public: IPO Values Payments Giant at $95 Billion',
   'stripe-ipo-95-billion',
   'After years of delays, the payments infrastructure company finally lists on the NYSE.',
   'Stripe priced its long-awaited IPO at $32 per share, valuing the company at $95 billion and making it the largest U.S. technology IPO since Snowflake. The offering raised $5 billion in primary proceeds, with founders Patrick and John Collison each selling a small portion of their stakes. Stripe reported $7.2 billion in 2025 revenue, up 28% year-over-year, with EBITDA margins expanding to 18% as the company''s infrastructure business scaled. The stock opened at $41 on its first day of trading, giving early employees and investors a significant return. Stripe processes over $1 trillion in annual payment volume.',
   'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=1200', 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400',
   4, 'published', NOW() - INTERVAL '2 days 3 hours'),

  (cat_finance, author_id,
   'ASEAN Free Trade Zone Expansion Adds Six New Members',
   'asean-free-trade-zone-expansion',
   'The bloc''s enlarged trade area will create the world''s largest free trade zone by population.',
   'ASEAN trade ministers announced the bloc''s most significant expansion in two decades, adding Bangladesh, Sri Lanka, Pakistan, Nepal, Mongolia, and Papua New Guinea to the ASEAN Free Trade Area framework. The expansion creates a trade zone covering 1.4 billion people, surpassing both the EU and USMCA in population. Tariffs on 90% of goods will be eliminated over a five-year phase-in period. Indonesia and Vietnam are expected to be the primary beneficiaries, as they serve as regional manufacturing hubs. The deal still requires ratification by all existing ASEAN members, with Thailand and the Philippines reportedly seeking additional concessions.',
   'https://images.unsplash.com/photo-1504868584819-f8e8b4b6d7e3?w=1200', 'https://images.unsplash.com/photo-1504868584819-f8e8b4b6d7e3?w=400',
   3, 'published', NOW() - INTERVAL '2 days 12 hours'),

  (cat_finance, author_id,
   'Tesla Cybertruck Reaches Profitability After 18 Months of Production Struggles',
   'tesla-cybertruck-profitability',
   'The polarizing stainless-steel pickup finally turns gross profit positive per unit.',
   'Tesla disclosed in its Q1 filing that the Cybertruck has reached positive gross margin per unit, a milestone that had eluded the company since the vehicle''s December 2023 launch. Manufacturing yield improvements at Gigafactory Texas and renegotiated supplier contracts drove the turnaround. Production has ramped to 2,500 units per week, still below the original 250,000 per year target, but Elon Musk said on the earnings call that the factory is on track to hit that rate by year-end. The Cybertruck remains the best-selling electric pickup in the U.S., outselling Rivian R1T and Ford F-150 Lightning combined.',
   'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=1200', 'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=400',
   3, 'published', NOW() - INTERVAL '3 days 6 hours'),

  -- ── SPORTS (10 articles) ─────────────────────────────────────────────────
  (cat_sports, author_id,
   'Carlos Alcaraz Wins Australian Open, Completes Career Grand Slam at 22',
   'alcaraz-australian-open-career-grand-slam',
   'The Spanish sensation becomes the youngest man to win all four majors.',
   'Carlos Alcaraz claimed his fourth Grand Slam title at Melbourne Park, defeating Jannik Sinner in a five-set classic that lasted four hours and forty-two minutes. The 22-year-old Spaniard becomes the youngest man in history to complete the Career Grand Slam, surpassing Rafael Nadal''s record by three years. Alcaraz saved three match points in the fourth set before running away with the fifth 6-2. "This is the dream I had since I was a child," Alcaraz said, visibly emotional, as his father embraced him on court. Sinner, who had held the world No. 1 ranking for the past eight months, remains winless against Alcaraz in Grand Slam finals.',
   'https://images.unsplash.com/photo-1622280227940-41ad9e8e9af4?w=1200', 'https://images.unsplash.com/photo-1622280227940-41ad9e8e9af4?w=400',
   4, 'published', NOW() - INTERVAL '3 hours'),

  (cat_sports, author_id,
   'Real Madrid Sign Endrick for €120 Million, Completing Brazilian''s Move',
   'real-madrid-endrick-signing',
   'The 18-year-old Brazilian sensation officially becomes a Galactico in a landmark transfer.',
   'Real Madrid have completed the signing of Endrick Felipe from Palmeiras for a fee of €120 million, making the 18-year-old one of the most expensive teenagers in football history. The Brazilian forward, who has already scored 7 goals in 12 senior international appearances, was presented at the Bernabeu to 60,000 fans in a ceremony reminiscent of Ronaldo''s unveiling. Endrick will wear the number 16 shirt and is expected to be eased into the squad rotation alongside Vinicius Jr and Kylian Mbappe. "I have been dreaming about this since I was five years old," Endrick said in fluent Spanish, having spent three months learning the language ahead of the move.',
   'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=1200', 'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=400',
   3, 'published', NOW() - INTERVAL '5 hours'),

  (cat_sports, author_id,
   'NBA: Stephen Curry Breaks All-Time Three-Point Record',
   'curry-breaks-three-point-record',
   'The Warriors guard surpasses his own record with a spectacular shot in the third quarter.',
   'Stephen Curry drained his 3,748th career three-pointer on Tuesday night, surpassing his own all-time record on a step-back from 27 feet that sent the Chase Center into pandemonium. The shot came in the third quarter against the Lakers, a fitting stage given the rivalry. Curry was mobbed by teammates and received a standing ovation from both sets of fans. NBA Commissioner Adam Silver was in attendance and presented Curry with a commemorative basketball. At 37, Curry is showing no signs of slowing down, averaging 26.4 points and 6.2 three-point attempts per game. The Warriors are two games back of the top seed in the Western Conference.',
   'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=1200', 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=400',
   3, 'published', NOW() - INTERVAL '9 hours'),

  (cat_sports, author_id,
   'Formula 1: Verstappen Eyes Fifth Consecutive Championship as Rivals Close In',
   'verstappen-fifth-championship',
   'Red Bull''s dominance is fading, setting up the most competitive season in a decade.',
   'Max Verstappen leads the 2026 F1 World Championship standings after five rounds, but the gap to his nearest rivals has never been smaller. Ferrari''s Charles Leclerc sits just 18 points behind following consecutive victories in Bahrain and Australia, while Mercedes'' George Russell has won two races on street circuits. Red Bull''s aerodynamic advantage has been neutralized by a mid-season regulation change that benefited low-rake car concepts. "Every race is a battle now," Verstappen acknowledged ahead of Monaco. The constructor''s championship is even tighter, with just 12 points separating the top three teams heading into the European swing.',
   'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=1200', 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=400',
   4, 'published', NOW() - INTERVAL '11 hours'),

  (cat_sports, author_id,
   'Indonesia Qualifies for 2026 FIFA World Cup for the First Time',
   'indonesia-qualifies-world-cup-2026',
   'The Garuda reaches football''s biggest stage after a historic qualifying campaign.',
   'Indonesia has officially qualified for the 2026 FIFA World Cup, securing their place in the expanded 48-team tournament with a 2-0 victory over Bahrain in the final AFC qualification round. Goals from Egy Maulana Vikri and naturalized striker Rafael Struick confirmed Indonesia''s historic achievement. Jakarta exploded in celebration as millions filled the streets. Head coach Shin Tae-yong, who has managed the squad since 2019, was carried off the pitch by players. Indonesia will be in the Asia group and could face Japan, South Korea, or Saudi Arabia in the group stage. The World Cup kicks off in the United States, Canada, and Mexico next summer.',
   'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=1200', 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=400',
   4, 'published', NOW() - INTERVAL '15 hours'),

  (cat_sports, author_id,
   'LeBron James and Bronny James Make NBA History as Father-Son Starters',
   'lebron-bronny-father-son-nba-starters',
   'For the first time in league history, a father and son start together in an NBA game.',
   'History was made at Crypto.com Arena when LeBron James and his son Bronny James started together for the Los Angeles Lakers, becoming the first father-son duo to share an NBA starting lineup. The Lakers fielded the historic pairing against the Golden State Warriors in a nationally televised game. Bronny, in his second season, contributed 14 points, 5 assists, and 3 steals in 32 minutes, while LeBron added a triple-double. "I''ve been dreaming about this since he was born," LeBron said post-game, his voice breaking. NBA executives confirmed multiple record-setting viewership numbers for the broadcast, making it the most-watched regular-season game in seven years.',
   'https://images.unsplash.com/photo-1504450758481-7338eba7524a?w=1200', 'https://images.unsplash.com/photo-1504450758481-7338eba7524a?w=400',
   4, 'published', NOW() - INTERVAL '1 day 1 hour'),

  (cat_sports, author_id,
   'Novak Djokovic Announces Retirement, Ending Greatest Tennis Career',
   'djokovic-retirement-announcement',
   'The 25-time Grand Slam champion calls time on a career that redefined the limits of tennis.',
   'Novak Djokovic announced his retirement from professional tennis at a press conference in Belgrade, bringing an end to the most decorated singles career in the history of the sport. The 38-year-old Serbian holds 25 Grand Slam titles, an all-time record he extended with his French Open victory last June. "My body has given me more than I could ever ask for," Djokovic said, composed but visibly emotional. The tennis world reacted with universal praise. Roger Federer flew to Belgrade for the announcement. Rafael Nadal posted a heartfelt tribute on social media. Djokovic will play one final exhibition match at the Srpska Open in April.',
   'https://images.unsplash.com/photo-1622280227940-41ad9e8e9af4?w=1200', 'https://images.unsplash.com/photo-1622280227940-41ad9e8e9af4?w=400',
   4, 'published', NOW() - INTERVAL '1 day 5 hours'),

  (cat_sports, author_id,
   'Manchester City Win Record Tenth Premier League Title',
   'man-city-tenth-premier-league',
   'Pep Guardiola''s men clinch the title with three games to spare in a dominant campaign.',
   'Manchester City have claimed a record-extending tenth Premier League title, mathematically confirmed by a 3-0 victory over Tottenham at the Etihad Stadium. Erling Haaland, who scored twice, has now notched 38 goals in all competitions this season. City finished the campaign with 94 points, losing only three matches all season. Pep Guardiola, who has now won seven Premier League titles, called this squad "the most complete I have ever managed." The title comes despite Liverpool pushing hard throughout the season, ultimately finishing second with 87 points. City''s league success sets up a potential Treble, with a Champions League final berth already secured.',
   'https://images.unsplash.com/photo-1517927033932-b3d18e61fb3a?w=1200', 'https://images.unsplash.com/photo-1517927033932-b3d18e61fb3a?w=400',
   3, 'published', NOW() - INTERVAL '2 days 2 hours'),

  (cat_sports, author_id,
   'Tour de France: Tadej Pogacar Wins Record Fifth Yellow Jersey',
   'pogacar-fifth-tour-de-france',
   'The Slovenian superstar cements his status as the greatest Tour rider of his generation.',
   'Tadej Pogacar claimed his fifth Tour de France title in Paris, cementing his status alongside Bernard Hinault and Eddy Merckx in the annals of cycling greatness. The UAE Emirates captain dominated the mountain stages with three solo victories in the Pyrenees and Alps, crushing his rivals'' spirits systematically. Jonas Vingegaard, who pushed Pogacar to the final stage in their previous duels, abandoned on Stage 14 due to a rib injury sustained in a crash. Pogacar finished 11 minutes 32 seconds ahead of second place, the largest winning margin since 1997. The 26-year-old has now won the Giro d''Italia, Vuelta a España, and Tour de France in the same calendar year.',
   'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=1200', 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
   4, 'published', NOW() - INTERVAL '3 days 4 hours'),

  (cat_sports, author_id,
   'Tokyo Olympics 2028: Japan Begins Venue Construction Ahead of Schedule',
   'tokyo-olympics-2028-construction',
   'Two years out, Japan''s preparations are drawing universal praise from the IOC.',
   'Japan broke ground on the final venue for the 2028 Summer Olympics in Tokyo — the expanded Ariake Arena — six months ahead of schedule, reinforcing Japan''s reputation for meticulous event management. IOC Coordination Commission Chair Jean-Christophe Rolland praised Japan''s preparations as "exemplary" following an inspection visit. The 2028 Games will feature five new sports: skateboarding, sport climbing, surfing, breakdancing (returning after Paris), and the first-ever inclusion of padel. Japan has committed to a carbon-neutral games, with all venues powered by renewable energy and the athletes'' village built to LEED Platinum standards.',
   'https://images.unsplash.com/photo-1569693621544-9eacacd7612d?w=1200', 'https://images.unsplash.com/photo-1569693621544-9eacacd7612d?w=400',
   3, 'published', NOW() - INTERVAL '4 days'),

  -- ── WORLD (10 articles) ──────────────────────────────────────────────────
  (cat_world, author_id,
   'UN Climate Summit Produces Historic $2 Trillion Green Transition Pledge',
   'un-climate-summit-2-trillion-pledge',
   'Nations agreed to the largest financial commitment in climate history at COP31 in Nairobi.',
   'The 31st UN Climate Change Conference concluded in Nairobi with a landmark agreement committing $2 trillion annually to the global green transition by 2030. The pledge, brokered over two weeks of intense negotiations, was signed by 142 countries including the United States, European Union, China, and India. The funding will flow through a new multilateral mechanism, the Global Climate Finance Facility, that bypasses traditional aid bureaucracy. Developing nations secured a provision ensuring 40% of funding goes directly to adaptation measures. Secretary-General Antonio Guterres called it "the beginning of the end of the fossil fuel era." Critics note that actual disbursement mechanisms remain vague.',
   'https://images.unsplash.com/photo-1552799446-159ba9523315?w=1200', 'https://images.unsplash.com/photo-1552799446-159ba9523315?w=400',
   5, 'published', NOW() - INTERVAL '4 hours'),

  (cat_world, author_id,
   'Japan Passes Historic Immigration Reform, Opening Doors to Skilled Workers',
   'japan-immigration-reform-skilled-workers',
   'Facing acute labor shortages, Japan overhauls its immigration system in a generational shift.',
   'Japan''s parliament passed sweeping immigration reforms that represent the most significant liberalization of the country''s historically restrictive immigration policy. The new framework creates a permanent residency pathway for skilled workers in 14 designated sectors — including technology, healthcare, and construction — after just three years, down from ten. Family reunification rights have been expanded, and spouses of skilled workers can now work unrestricted. The government projects the reforms will attract 500,000 additional skilled foreign workers by 2030. Critics from conservative parties argue the changes threaten Japan''s cultural homogeneity, while business groups welcomed the long-overdue reform.',
   'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=1200', 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400',
   4, 'published', NOW() - INTERVAL '7 hours'),

  (cat_world, author_id,
   'Ukraine and Russia Agree to Temporary Ceasefire Under EU Mediation',
   'ukraine-russia-ceasefire-eu',
   'A fragile 90-day pause in hostilities opens the door to the first formal peace talks.',
   'Ukraine and Russia have agreed to a 90-day ceasefire, brokered by EU High Representative for Foreign Affairs Kaja Kallas following months of behind-the-scenes negotiations. The ceasefire, which takes effect at midnight UTC on Friday, covers the entire front line and includes a prisoner-of-war exchange mechanism. Both sides have agreed to attend peace talks in Vienna next month, the first formal negotiations since the Istanbul talks collapsed in 2022. Ukrainian President Zelensky emphasized that the ceasefire does not constitute any recognition of territorial gains. NATO Secretary General expressed cautious optimism while maintaining alliance support commitments to Ukraine.',
   'https://images.unsplash.com/photo-1526406915894-7bcd65f60845?w=1200', 'https://images.unsplash.com/photo-1526406915894-7bcd65f60845?w=400',
   4, 'published', NOW() - INTERVAL '13 hours'),

  (cat_world, author_id,
   'India Overtakes Japan as World''s Third Largest Economy',
   'india-overtakes-japan-third-economy',
   'IMF data confirms India''s GDP has surpassed Japan''s in nominal dollar terms.',
   'The International Monetary Fund confirmed in its latest World Economic Outlook that India has overtaken Japan to become the world''s third largest economy in nominal GDP terms, with an economy valued at $4.9 trillion compared to Japan''s $4.7 trillion. India''s ascent has been driven by a demographic dividend, a booming services export sector, and significant manufacturing investment under the Production Linked Incentive scheme. The country is on track to surpass Germany''s number four ranking by 2027. Prime Minister Modi called the milestone "a testament to the aspirations of 1.4 billion Indians." The milestone was widely anticipated but arrived two years ahead of most projections.',
   'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=1200', 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=400',
   3, 'published', NOW() - INTERVAL '18 hours'),

  (cat_world, author_id,
   'Eiffel Tower Closes for Six-Month Renovation After Structural Concerns',
   'eiffel-tower-renovation-closure',
   'France''s most iconic landmark undergoes its most extensive restoration in a century.',
   'The Eiffel Tower has closed to visitors for a six-month renovation project, its most extensive structural restoration since the tower''s construction in 1889. French authorities cited corrosion in seven of the tower''s 41 pillars, exacerbated by record summer temperatures that caused the metal to expand and contract at unprecedented rates. The €300 million restoration project will replace affected sections, upgrade the elevator systems, add new LED lighting, and improve accessibility for visitors with disabilities. The closure affects 7 million annual visitors and is estimated to cost the Paris tourism economy €400 million. The tower is expected to reopen in time for the Bastille Day celebrations.',
   'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?w=1200', 'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?w=400',
   3, 'published', NOW() - INTERVAL '1 day 6 hours'),

  (cat_world, author_id,
   'China Launches Moon Base Construction Mission with Robotic Pioneers',
   'china-moon-base-construction',
   'Chang''e 9 delivers the first structural modules of China''s planned lunar research station.',
   'China successfully landed the Chang''e 9 mission near the lunar south pole, deploying two construction robots that will begin assembly of the International Lunar Research Station''s foundation modules. The robots, each weighing 240 kg, are designed to operate autonomously for up to 18 months, excavating regolith and positioning pre-fabricated structural elements. China plans to have a habitable lunar base ready for human occupation by 2035. The mission represents a significant escalation in the Artemis-ILRS rivalry, as NASA''s Artemis program has faced repeated delays. Russia, the UAE, and Pakistan have all signed bilateral agreements to participate in the ILRS program.',
   'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=1200', 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=400',
   5, 'published', NOW() - INTERVAL '2 days 1 hour'),

  (cat_world, author_id,
   'Amazon Rainforest Records First Net Regrowth in 15 Years',
   'amazon-rainforest-net-regrowth',
   'Stricter enforcement and reforestation programs have reversed a decade and a half of decline.',
   'Brazil''s National Institute for Space Research reported that the Amazon rainforest achieved net positive growth for the first time in 15 years in 2025, with regrowth exceeding deforestation by approximately 2,000 square kilometers. The turnaround is attributed to the Lula government''s aggressive enforcement of the Forest Code, which reduced illegal deforestation by 67% compared to the peak Bolsonaro era and to a coalition of reforestation programs funded by Norway, Germany, and major corporations under carbon credit frameworks. Scientists caution that a single year of net regrowth does not reverse the long-term trend, but call it a genuine inflection point.',
   'https://images.unsplash.com/photo-1519923218604-6f8d64d50dde?w=1200', 'https://images.unsplash.com/photo-1519923218604-6f8d64d50dde?w=400',
   4, 'published', NOW() - INTERVAL '2 days 8 hours'),

  (cat_world, author_id,
   'WHO Declares Mpox Emergency Over as Vaccine Coverage Reaches 80%',
   'who-mpox-emergency-over',
   'Global vaccination efforts have suppressed the outbreak that began in Central Africa.',
   'The World Health Organization has officially declared an end to the mpox Public Health Emergency of International Concern, citing an 89% reduction in weekly case counts globally and vaccine coverage exceeding 80% in all high-incidence countries. The emergency, declared in August 2024, spurred the fastest rollout of a newly approved vaccine in WHO history, with JYNNEOS distributed to 41 countries within six months. The Democratic Republic of Congo, which bore the heaviest burden with over 60% of cases, has now recorded fewer than 100 new weekly cases for eight consecutive weeks. WHO Director-General praised the response as a "model of international health coordination."',
   'https://images.unsplash.com/photo-1584036561566-baf8f5f1b144?w=1200', 'https://images.unsplash.com/photo-1584036561566-baf8f5f1b144?w=400',
   4, 'published', NOW() - INTERVAL '3 days 2 hours'),

  (cat_world, author_id,
   'Saudi Arabia Announces $1.5 Trillion NEOM City to Begin Resident Intake',
   'neom-city-resident-intake',
   'The Line''s first residential district opens, welcoming the megaproject''s first permanent residents.',
   'Saudi Arabia''s NEOM megaproject reached a symbolic milestone as the first residential district of The Line — the 170-kilometer linear city — began accepting permanent residents. The initial intake is limited to 20,000 people, mostly NEOM employees and their families, but the project envisions 9 million residents by 2045. The habitable section features a self-contained ecosystem with indoor farms, climate-controlled streets, and an AI-powered transit system with zero-carbon emissions. Independent observers who visited the development noted impressive infrastructure but raised questions about the feasibility of the full project given the harsh desert environment and continued construction timeline pressures.',
   'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=1200', 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=400',
   4, 'published', NOW() - INTERVAL '4 days 3 hours'),

  (cat_world, author_id,
   'Global Population Reaches 9 Billion, UN Report Highlights Growth Shifts',
   'global-population-9-billion',
   'The milestone arrives 12 years after 8 billion, with growth increasingly concentrated in Africa.',
   'The United Nations Population Fund confirmed that Earth''s human population has reached 9 billion, with the milestone baby born in Lagos, Nigeria — a symbolic choice reflecting Africa''s growing share of global population growth. Sub-Saharan Africa now accounts for 60% of global population growth annually, while Europe and East Asia are experiencing sustained population decline. India, now the world''s most populous country, is beginning to see its birth rate fall below replacement level, mirroring the trajectory China followed two decades earlier. The UN projects global population will peak at 10.4 billion around 2080 before beginning a gradual decline, driven by continued fertility rate declines in developing regions.',
   'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=1200', 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=400',
   4, 'published', NOW() - INTERVAL '5 days'),

  -- ── SCIENCE (10 articles) ────────────────────────────────────────────────
  (cat_science, author_id,
   'Scientists Achieve Room-Temperature Superconductivity in New Hydrogen-Rich Compound',
   'room-temperature-superconductivity-achieved',
   'A team at MIT has confirmed the most long-sought breakthrough in condensed matter physics.',
   'Researchers at MIT''s Francis Bitter Magnet Laboratory have confirmed room-temperature superconductivity in a new yttrium-hydrogen compound stabilized at ambient pressure — the most significant breakthrough in condensed matter physics in a century. Previous room-temperature superconductors required extreme pressures of millions of atmospheres, making them useless for practical applications. The new material maintains zero electrical resistance at 25°C and operates at pressures achievable with standard laboratory equipment. The peer-reviewed paper, published in Nature, has passed independent replication at three separate institutions. If scalable, the discovery could eliminate energy losses in power transmission, revolutionize MRI technology, and enable practical magnetic levitation.',
   'https://images.unsplash.com/photo-1532094349884-543559083c74?w=1200', 'https://images.unsplash.com/photo-1532094349884-543559083c74?w=400',
   6, 'published', NOW() - INTERVAL '6 hours'),

  (cat_science, author_id,
   'James Webb Telescope Discovers Oxygen in Exoplanet Atmosphere for First Time',
   'webb-discovers-oxygen-exoplanet',
   'The detection on TRAPPIST-1e marks a potential biosignature that will intensify study.',
   'NASA''s James Webb Space Telescope has detected molecular oxygen in the atmosphere of TRAPPIST-1e, a rocky exoplanet located 39 light-years from Earth in the habitable zone of its star, marking the first confirmed detection of oxygen outside our solar system. While oxygen is produced by biological processes on Earth, scientists caution that abiotic oxygen production is possible through photolysis of water vapor. The detection was made using transmission spectroscopy during 28 transit observations totaling 400 hours of observation time. A dedicated follow-up campaign using all available Webb observing time is being planned to search for additional biosignatures including methane and nitrous oxide.',
   'https://images.unsplash.com/photo-1462331940025-496dfbfc7564?w=1200', 'https://images.unsplash.com/photo-1462331940025-496dfbfc7564?w=400',
   5, 'published', NOW() - INTERVAL '11 hours'),

  (cat_science, author_id,
   'CERN Confirms Evidence of Fifth Fundamental Force of Nature',
   'cern-fifth-fundamental-force',
   'Anomalies in B-meson decay patterns at the LHC point to physics beyond the Standard Model.',
   'Physicists at CERN have announced evidence reaching the 5-sigma threshold — the gold standard for discovery in particle physics — for a new interaction that cannot be explained by the Standard Model''s four known fundamental forces. The signal emerges from a pattern of anomalies in B-meson decays in the LHCb detector that has been accumulating statistical significance for seven years. The potential new force appears to interact with leptons in a way that violates lepton universality, a cornerstone of the Standard Model. If confirmed, it would represent the first extension of the Standard Model in 50 years. Independent analysis by the Belle II experiment in Japan has seen a 3.8-sigma signal in the same decay channel.',
   'https://images.unsplash.com/photo-1518770660439-4636190af475?w=1200', 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=400',
   6, 'published', NOW() - INTERVAL '1 day 3 hours'),

  (cat_science, author_id,
   'AlphaFold 3 Predicts Protein-DNA Interaction Structures, Accelerating Drug Discovery',
   'alphafold-3-protein-dna-structures',
   'DeepMind''s latest model extends beyond proteins to the full machinery of cellular biology.',
   'DeepMind has released AlphaFold 3, capable of predicting the three-dimensional structures of protein interactions with DNA, RNA, and drug molecules — not just protein folding alone. The extension is scientifically significant because most diseases involve disruptions in how proteins interact with DNA rather than protein structure in isolation. In a benchmark study, AlphaFold 3 predicted protein-DNA complex structures with accuracy comparable to experimental crystallography in 87% of cases. The model has already been applied to identify 14 promising drug candidates for antibiotic-resistant bacterial infections, with three advancing to preclinical testing. Free access is available through the AlphaFold Server.',
   'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=1200', 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400',
   5, 'published', NOW() - INTERVAL '1 day 10 hours'),

  (cat_science, author_id,
   'Scientists Grow Complete Human Kidney in Lab Using Stem Cells',
   'scientists-grow-human-kidney-lab',
   'The organoid functions at 60% capacity compared to adult kidneys, opening transplant possibilities.',
   'A multi-institutional research team led by Massachusetts General Hospital has successfully grown the most complete human kidney organoid ever produced, achieving approximately 60% functional capacity compared to an adult kidney. The organ, grown from induced pluripotent stem cells in 120 days, filters waste products, produces erythropoietin, and maintains electrolyte balance in pig models. The kidney lacks a functional collecting duct, the remaining challenge before clinical trials can begin. The team estimates transplantable lab-grown kidneys could be available for clinical trials within seven years. With 850 million people worldwide suffering from chronic kidney disease, the implications for the transplant waiting list — currently over 90,000 patients in the U.S. alone — are profound.',
   'https://images.unsplash.com/photo-1576086213369-97a306d36557?w=1200', 'https://images.unsplash.com/photo-1576086213369-97a306d36557?w=400',
   5, 'published', NOW() - INTERVAL '2 days 4 hours'),

  (cat_science, author_id,
   'Voyager 1 Sends Clearest Signal in Years After NASA Engineering Fix',
   'voyager-1-clearest-signal',
   'Engineers repaired a corrupted memory chip 24 billion kilometers away using a creative workaround.',
   'NASA engineers have restored full scientific data transmission from Voyager 1, the most distant human-made object in existence at 24 billion kilometers from Earth, after a seven-month communication puzzle caused by a corrupted memory chip in the flight data subsystem. The solution involved reprogramming the spacecraft to store its code in a different memory location, a workaround that required commands taking 22.5 hours to reach the probe and another 22.5 hours for confirmation of receipt. All four scientific instruments are now transmitting data normally. Launched in 1977, Voyager 1 is traveling through interstellar space at 17 km per second and has enough power to operate until approximately 2025.',
   'https://images.unsplash.com/photo-1446776895870-e32e47de8516?w=1200', 'https://images.unsplash.com/photo-1446776895870-e32e47de8516?w=400',
   4, 'published', NOW() - INTERVAL '3 days 1 hour'),

  (cat_science, author_id,
   'New Malaria Vaccine Shows 95% Efficacy in Phase 3 Trial',
   'malaria-vaccine-95-percent-efficacy',
   'The R21/Matrix-M vaccine could save hundreds of thousands of lives annually in sub-Saharan Africa.',
   'Phase 3 clinical trials of the R21/Matrix-M malaria vaccine, conducted across four sub-Saharan African countries with 4,800 children, have demonstrated 95% efficacy against clinical malaria over a 30-month period — the highest ever recorded for a malaria vaccine. Previous vaccines, including the RTS,S approved in 2021, showed only 50-77% efficacy. The vaccine, developed by Oxford University and the Serum Institute of India, can be manufactured for under $3 per dose at scale, making it viable for widespread deployment in low-income settings. WHO has recommended accelerated safety review for emergency authorization. UNICEF has pre-ordered 100 million doses for deployment in countries with the highest malaria burden.',
   'https://images.unsplash.com/photo-1576765608535-5f04d1e3f289?w=1200', 'https://images.unsplash.com/photo-1576765608535-5f04d1e3f289?w=400',
   5, 'published', NOW() - INTERVAL '3 days 8 hours'),

  (cat_science, author_id,
   'Ancient 300,000-Year-Old Wooden Structure Found in Zambia Rewrites Human History',
   'ancient-wooden-structure-zambia',
   'The discovery challenges assumptions about the cognitive capabilities of early Homo sapiens.',
   'Archaeologists excavating at Kalambo Falls in Zambia have uncovered a remarkably preserved wooden structure dated to 300,000 years ago, predating Homo sapiens as a species by 100,000 years. The structure, made from two large logs joined at right angles using a notch-and-groove technique, indicates that our ancestors were capable of sophisticated engineering far earlier than previously believed. The exceptional preservation was possible due to the site''s waterlogged conditions, which excluded oxygen. The researchers suggest the structure may have been a platform or the base of a dwelling. Previous evidence of wood tool use dates to only 40,000 years ago, making this discovery a quantum leap in our understanding of early human cognition.',
   'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1200', 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
   5, 'published', NOW() - INTERVAL '4 days 6 hours'),

  (cat_science, author_id,
   'Fusion Energy Milestone: NIF Achieves Net Energy Gain for Fifth Consecutive Time',
   'nif-fusion-net-energy-fifth-time',
   'The California facility has now reliably reproduced the historic 2022 ignition breakthrough.',
   'The National Ignition Facility at Lawrence Livermore National Laboratory has achieved fusion ignition — producing more energy from fusion than the laser energy delivered to the fuel — for the fifth consecutive experimental campaign, establishing reproducibility of the 2022 breakthrough that skeptics had questioned. The most recent shot produced 3.88 MJ of fusion energy from 2.05 MJ of laser input, a gain ratio of 1.89. While the total system efficiency remains well below what a power plant would require, the consistent reproducibility is what investors and governments needed to see. Last month, Commonwealth Fusion Systems secured $4.5 billion to build its first commercial fusion pilot plant, citing the NIF results as a key confidence driver.',
   'https://images.unsplash.com/photo-1532187643603-ba119ca4109e?w=1200', 'https://images.unsplash.com/photo-1532187643603-ba119ca4109e?w=400',
   5, 'published', NOW() - INTERVAL '5 days 2 hours'),

  (cat_science, author_id,
   'Octopuses Found to Dream and Change Color During Sleep, Study Confirms',
   'octopuses-dream-change-color-sleep',
   'Neuroscientists document REM-like sleep cycles in cephalopods for the first time.',
   'A study published in Nature Neuroscience has confirmed that octopuses experience a form of REM-like sleep during which they appear to dream, evidenced by rapid color and texture changes across their skin synchronized with neural activity patterns resembling waking states. Researchers at the Marine Biological Laboratory in Woods Hole filmed and analyzed 14 octopuses over six months, documenting the sleep cycles with high-speed cameras and implanted neural probes. During the most active sleep phase, octopuses cycled through camouflage patterns that matched environments they had explored during the day. The finding extends REM-like sleep to invertebrates for the first time, suggesting dreaming may have evolved far earlier in animal history than previously believed.',
   'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=1200', 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400',
   4, 'published', NOW() - INTERVAL '6 days');

END $$;

-- Verify
SELECT c.name AS category, COUNT(a.id) AS article_count
FROM articles a JOIN categories c ON a.category_id = c.id
GROUP BY c.name ORDER BY c.name;
