-- Seed: 007_seed_more_articles.sql
-- Tambah ~150 artikel lagi (30 per kategori) via generate_series
-- Total akan jadi ~200 artikel = 20 halaman infinity scroll

DO $$
DECLARE
  author_id   BIGINT;
  cat_tech    BIGINT;
  cat_finance BIGINT;
  cat_sports  BIGINT;
  cat_world   BIGINT;
  cat_science BIGINT;
  i           INT;
BEGIN
  SELECT id INTO author_id FROM users ORDER BY id LIMIT 1;
  SELECT id INTO cat_tech    FROM categories WHERE slug = 'technology';
  SELECT id INTO cat_finance FROM categories WHERE slug = 'finance';
  SELECT id INTO cat_sports  FROM categories WHERE slug = 'sports';
  SELECT id INTO cat_world   FROM categories WHERE slug = 'world';
  SELECT id INTO cat_science FROM categories WHERE slug = 'science';

  -- ── TECHNOLOGY ─────────────────────────────────────────────────────────────
  FOR i IN 1..30 LOOP
    INSERT INTO articles
      (category_id, author_id, title, slug, excerpt, content, image_url,
       thumbnail_url, read_time_minutes, status, published_at)
    VALUES (
      cat_tech, author_id,
      format('Tech Story #%s: %s', i + 10, (ARRAY[
        'How AI Is Reshaping the Software Development Lifecycle',
        'Rust Programming Language Overtakes Go in Systems Development Surveys',
        'Edge Computing Meets AI: The Next Infrastructure Revolution',
        'OpenAI Releases GPT-5 API with 1M Token Context Window',
        'USB4 Version 2 Doubles Bandwidth to 80 Gbps',
        'Linux Kernel 7.0 Released with Native GPU Unified Memory',
        'Apple Silicon M4 Ultra Benchmarks Smash Workstation Records',
        'Amazon AWS Unveils Graviton 5 Chip for Cloud Workloads',
        'Android 16 Features Live Translation in Every App',
        'GitHub Copilot Workspace Turns Issues into Pull Requests Automatically',
        'DeepSeek R2 Tops Every Coding Benchmark at a Fraction of the Cost',
        'CrowdStrike Releases Zero-Trust Architecture SDK for Developers',
        'Arc Search Replaces Full Browsing Sessions with Instant AI Answers',
        'Microsoft Integrates Copilot into Every Windows API Surface',
        'RISC-V Gains Momentum as ARM Alternative in Mobile Chips',
        'Cloudflare Announces Global AI Inference Network at Edge Nodes',
        'Docker Desktop 5.0 Rewrites Runtime in Rust for 3x Speed Gain',
        'PostgreSQL 18 Ships with Native Column-Level Encryption',
        'React 20 Drops Class Components Entirely',
        'Tailwind CSS v5 Uses CSS Custom Properties for Everything',
        'Vercel Acquires Turbopack Team, Ships 10x Faster Builds',
        'Deno 3.0 Fully Supports npm with Zero Configuration',
        'Bun 2.0 Becomes the Fastest JavaScript Runtime by Every Metric',
        'Redis Goes Open Source Again After Fork Pressure',
        'ClickHouse Launches Managed Cloud with Sub-Second Query SLAs',
        'Kubernetes 2.0 Simplifies Networking with Built-In Service Mesh',
        'Terraform 2.0 Adopts OpenTofu as Community-Driven Upstream',
        'Grafana Acquires k6 and Doubles Down on Performance Testing',
        '1Password Launches Developer Platform for Secrets Management',
        'Homebrew 5.0 Ships with Native Apple Silicon Package Resolution'
      ])[i]),
      format('tech-story-%s-%s', i + 10, lower(regexp_replace(
        (ARRAY[
          'how-ai-reshaping-sdlc', 'rust-overtakes-go-systems', 'edge-computing-ai-infrastructure',
          'openai-gpt5-1m-context', 'usb4-v2-80gbps', 'linux-kernel-7-gpu-memory',
          'apple-m4-ultra-benchmarks', 'aws-graviton5-chip', 'android-16-live-translation',
          'github-copilot-workspace', 'deepseek-r2-coding-benchmarks', 'crowdstrike-zero-trust-sdk',
          'arc-search-instant-answers', 'microsoft-copilot-windows-api', 'riscv-arm-alternative-mobile',
          'cloudflare-ai-inference-edge', 'docker-desktop-5-rust', 'postgresql-18-column-encryption',
          'react-20-drops-class-components', 'tailwind-v5-css-properties', 'vercel-turbopack-acquisition',
          'deno-3-npm-zero-config', 'bun-2-fastest-runtime', 'redis-open-source-again',
          'clickhouse-cloud-sub-second', 'kubernetes-2-service-mesh', 'terraform-2-opentofu',
          'grafana-k6-performance', '1password-developer-platform', 'homebrew-5-apple-silicon'
        ])[i],
        '\s+', '-', 'g'
      ))),
      format('A deep dive into how %s is changing the technology landscape in 2026.',
        lower((ARRAY[
          'AI', 'Rust', 'edge computing', 'GPT-5', 'USB4', 'Linux 7.0', 'Apple M4',
          'Graviton 5', 'Android 16', 'GitHub Copilot', 'DeepSeek R2', 'zero-trust',
          'Arc Search', 'Microsoft Copilot', 'RISC-V', 'Cloudflare AI', 'Docker',
          'PostgreSQL 18', 'React 20', 'Tailwind v5', 'Vercel Turbopack', 'Deno 3',
          'Bun 2.0', 'Redis', 'ClickHouse Cloud', 'Kubernetes 2.0', 'Terraform 2.0',
          'Grafana k6', '1Password', 'Homebrew 5'
        ])[i])
      ),
      repeat(format('This is a detailed exploration of %s and its implications for developers and engineers worldwide. ',
        (ARRAY[
          'AI in software development', 'Rust systems programming', 'edge AI infrastructure',
          'GPT-5 capabilities', 'USB4 performance gains', 'Linux GPU memory management',
          'Apple Silicon performance', 'AWS custom silicon', 'Android translation features',
          'GitHub AI workflows', 'DeepSeek cost efficiency', 'zero-trust security',
          'AI-powered search', 'Windows AI integration', 'RISC-V architecture',
          'edge AI inference', 'containerization speed', 'database encryption',
          'React evolution', 'CSS architecture', 'build tool performance',
          'JavaScript compatibility', 'runtime benchmarks', 'open source licensing',
          'analytical databases', 'container networking', 'infrastructure as code',
          'observability platforms', 'secrets management', 'package management'
        ])[i]
      ), 12),
      format('https://images.unsplash.com/photo-%s?w=1200',
        (ARRAY[
          '1551650975-87deedd944c3','1526379095098-d400fd0bf935','1591405351990-4726e331f141',
          '1677442136019-21780ecad995','1620712943543-bcc4688e7485','1635070041078-e363dbe005cb',
          '1611532736597-de2d4265fba3','1551650975-87deedd944c3','1512941937669-90a1b58e7e9c',
          '1446776899648-aa78eefe8ed0','1591696205602-2f950c417cb9','1526379095098-d400fd0bf935',
          '1551650975-87deedd944c3','1677442136019-21780ecad995','1620712943543-bcc4688e7485',
          '1635070041078-e363dbe005cb','1526379095098-d400fd0bf935','1591405351990-4726e331f141',
          '1551650975-87deedd944c3','1512941937669-90a1b58e7e9c','1446776899648-aa78eefe8ed0',
          '1677442136019-21780ecad995','1620712943543-bcc4688e7485','1526379095098-d400fd0bf935',
          '1591405351990-4726e331f141','1635070041078-e363dbe005cb','1551650975-87deedd944c3',
          '1677442136019-21780ecad995','1512941937669-90a1b58e7e9c','1526379095098-d400fd0bf935'
        ])[i]
      ),
      format('https://images.unsplash.com/photo-%s?w=400',
        (ARRAY[
          '1551650975-87deedd944c3','1526379095098-d400fd0bf935','1591405351990-4726e331f141',
          '1677442136019-21780ecad995','1620712943543-bcc4688e7485','1635070041078-e363dbe005cb',
          '1611532736597-de2d4265fba3','1551650975-87deedd944c3','1512941937669-90a1b58e7e9c',
          '1446776899648-aa78eefe8ed0','1591696205602-2f950c417cb9','1526379095098-d400fd0bf935',
          '1551650975-87deedd944c3','1677442136019-21780ecad995','1620712943543-bcc4688e7485',
          '1635070041078-e363dbe005cb','1526379095098-d400fd0bf935','1591405351990-4726e331f141',
          '1551650975-87deedd944c3','1512941937669-90a1b58e7e9c','1446776899648-aa78eefe8ed0',
          '1677442136019-21780ecad995','1620712943543-bcc4688e7485','1526379095098-d400fd0bf935',
          '1591405351990-4726e331f141','1635070041078-e363dbe005cb','1551650975-87deedd944c3',
          '1677442136019-21780ecad995','1512941937669-90a1b58e7e9c','1526379095098-d400fd0bf935'
        ])[i]
      ),
      (i % 5) + 2,
      'published',
      NOW() - (i * INTERVAL '4 hours') - INTERVAL '7 days'
    ) ON CONFLICT (slug) DO NOTHING;
  END LOOP;

  -- ── FINANCE ────────────────────────────────────────────────────────────────
  FOR i IN 1..30 LOOP
    INSERT INTO articles
      (category_id, author_id, title, slug, excerpt, content, image_url,
       thumbnail_url, read_time_minutes, status, published_at)
    VALUES (
      cat_finance, author_id,
      format('Finance Story #%s: %s', i + 10,
        (ARRAY[
          'S&P 500 Reaches 7,000 Points Milestone Amid AI Euphoria',
          'ECB Cuts Rates to 2.5%, Lowest Since 2022 Debt Crisis',
          'Ant Group IPO Relaunched at $200 Billion Valuation',
          'US Dollar Index Falls to 3-Year Low as Fed Pivots',
          'Ethereum ETF Inflows Surpass Bitcoin ETF in Weekly Volume',
          'Japan Government Bond Yields Hit 15-Year High',
          'Carbon Credit Market Hits $1 Trillion Annually',
          'IMF Upgrades Global Growth Forecast to 3.8%',
          'Southeast Asia Venture Capital Hits Record $18B in Q1',
          'Sovereign Wealth Funds Increase Private Credit Allocation',
          'Aramco Surpasses Saudi GDP in Market Capitalization',
          'Real Estate Tech Startups Draw $5B Investment Wave',
          'European Banks Report Record Profits on Rate Normalization',
          'China Yuan Internationalization Accelerates Post-SWIFT Tension',
          'Commodity Supercycle 2.0 Driven by Energy Transition Demand',
          'Private Equity Returns Rebound After 2023-2024 Slump',
          'Stablecoin Market Cap Crosses $500 Billion',
          'Micro-Insurance Platforms Reach 400 Million Unbanked Users',
          'Green Bond Issuance Sets Record at $900 Billion Annually',
          'Vietnamese Dong Appreciates as Manufacturing Booms',
          'Mergers and Acquisitions Volume Hits Post-COVID High',
          'Fintech Lending Platforms Outpace Traditional Banks in SME Loans',
          'Commodity-Backed Digital Currencies Gain Emerging Market Traction',
          'Pension Fund Shift to Infrastructure Creates $3T Opportunity',
          'RegTech Investment Surges as Basel IV Compliance Deadline Nears',
          'Remittance Costs Drop to 2% Average as Crypto Rails Mature',
          'MSCI Emerging Markets Index Rebalance Adds Six New Countries',
          'Insurance Industry Faces $500B Climate Risk Repricing',
          'Central Bank Digital Currencies Now Active in 40 Countries',
          'Supply Chain Finance Platforms Become Critical Treasury Tool'
        ])[i]
      ),
      format('finance-story-%s', i + 10),
      format('Analysts weigh in on the implications of %s for global markets.',
        lower((ARRAY[
          'S&P 500 reaching 7,000', 'ECB rate cuts', 'Ant Group IPO',
          'dollar weakness', 'Ethereum ETFs', 'Japanese bond yields',
          'carbon credit growth', 'IMF upgrades', 'Southeast Asian VC',
          'sovereign wealth shifts', 'Aramco valuation', 'real estate tech',
          'European bank profits', 'yuan internationalization', 'commodity cycles',
          'private equity recovery', 'stablecoin growth', 'micro-insurance',
          'green bonds', 'Vietnamese dong strength', 'M&A activity',
          'fintech lending', 'commodity-backed crypto', 'pension infrastructure',
          'Basel IV compliance', 'crypto remittances', 'MSCI rebalancing',
          'climate risk insurance', 'CBDCs expansion', 'supply chain finance'
        ])[i])
      ),
      repeat('Detailed financial analysis covering market movements, investor sentiment, regulatory implications, and macroeconomic context that shapes investment decisions globally. ', 15),
      format('https://images.unsplash.com/photo-%s?w=1200',
        (ARRAY[
          '1611974789855-9c2a0a7236a3','1518546305927-5a555bb7020d','1579621970588-a35d0e7ab9b6',
          '1563013544-824ae1b704d3','1556742049-0cfed4f6a45d','1610375461246-83df859d849d',
          '1504868584819-f8e8b4b6d7e3','1591696205602-2f950c417cb9','1611974789855-9c2a0a7236a3',
          '1518546305927-5a555bb7020d','1579621970588-a35d0e7ab9b6','1563013544-824ae1b704d3',
          '1556742049-0cfed4f6a45d','1610375461246-83df859d849d','1504868584819-f8e8b4b6d7e3',
          '1591696205602-2f950c417cb9','1611974789855-9c2a0a7236a3','1518546305927-5a555bb7020d',
          '1579621970588-a35d0e7ab9b6','1563013544-824ae1b704d3','1556742049-0cfed4f6a45d',
          '1610375461246-83df859d849d','1504868584819-f8e8b4b6d7e3','1591696205602-2f950c417cb9',
          '1611974789855-9c2a0a7236a3','1518546305927-5a555bb7020d','1579621970588-a35d0e7ab9b6',
          '1563013544-824ae1b704d3','1556742049-0cfed4f6a45d','1610375461246-83df859d849d'
        ])[i]
      ),
      format('https://images.unsplash.com/photo-%s?w=400',
        (ARRAY[
          '1611974789855-9c2a0a7236a3','1518546305927-5a555bb7020d','1579621970588-a35d0e7ab9b6',
          '1563013544-824ae1b704d3','1556742049-0cfed4f6a45d','1610375461246-83df859d849d',
          '1504868584819-f8e8b4b6d7e3','1591696205602-2f950c417cb9','1611974789855-9c2a0a7236a3',
          '1518546305927-5a555bb7020d','1579621970588-a35d0e7ab9b6','1563013544-824ae1b704d3',
          '1556742049-0cfed4f6a45d','1610375461246-83df859d849d','1504868584819-f8e8b4b6d7e3',
          '1591696205602-2f950c417cb9','1611974789855-9c2a0a7236a3','1518546305927-5a555bb7020d',
          '1579621970588-a35d0e7ab9b6','1563013544-824ae1b704d3','1556742049-0cfed4f6a45d',
          '1610375461246-83df859d849d','1504868584819-f8e8b4b6d7e3','1591696205602-2f950c417cb9',
          '1611974789855-9c2a0a7236a3','1518546305927-5a555bb7020d','1579621970588-a35d0e7ab9b6',
          '1563013544-824ae1b704d3','1556742049-0cfed4f6a45d','1610375461246-83df859d849d'
        ])[i]
      ),
      (i % 4) + 2,
      'published',
      NOW() - (i * INTERVAL '5 hours') - INTERVAL '7 days'
    ) ON CONFLICT (slug) DO NOTHING;
  END LOOP;

  -- ── SPORTS ─────────────────────────────────────────────────────────────────
  FOR i IN 1..30 LOOP
    INSERT INTO articles
      (category_id, author_id, title, slug, excerpt, content, image_url,
       thumbnail_url, read_time_minutes, status, published_at)
    VALUES (
      cat_sports, author_id,
      format('Sports Story #%s: %s', i + 10,
        (ARRAY[
          'NFL Super Bowl LX Breaks All-Time Viewership Record with 140M Viewers',
          'Lionel Messi Wins Eighth Ballon d''Or at Age 39',
          'Serena Williams Returns for Charity Grand Slam, Wins First Set',
          'Premier League Introduces AI Offside Technology in All Matches',
          'Roger Federer Foundation Builds 100th School in Sub-Saharan Africa',
          'NBA Expansion Teams Announced for Las Vegas and Seattle',
          'Simone Biles Wins Fifth World All-Around Championship',
          'Patrick Mahomes Sets NFL Career Touchdown Record at 29',
          'Lionel Messi and Cristiano Ronaldo Final Match Draws 1 Billion Viewers',
          'IOC Announces 2036 Olympics Goes to Mumbai, India',
          'Tour de Suisse Introduces First Electric-Assist Category',
          'Spain Women Win Third Consecutive FIFA World Cup',
          'Novak Djokovic''s Retirement Match Sells Out in 4 Minutes',
          'UFC 320 Becomes Highest-Grossing Combat Sports Event Ever',
          'India Cricket Team Wins Test Championship for Third Time',
          'Tyson Fury vs Anthony Joshua Final: Fury Wins by Unanimous Decision',
          'Formula E Overtakes F1 in Social Media Engagement Among Under-30s',
          'Tiger Woods'' Son Charlie Qualifies for PGA Tour at 16',
          'Wimbledon Implements Hawkeye on Every Court Including Qualifying',
          'Cristiano Ronaldo Jr. Signs Professional Contract with Manchester City',
          'Olympics 2024 Paris: Team USA Tops Medal Table with 40 Gold',
          'Premier League Clubs Spend Record £3B in Summer Transfer Window',
          'Kylian Mbappe Breaks Ronaldo''s Champions League Goals Record',
          'Naomi Osaka Returns to Number 1 After Third Comeback',
          'IPL 2026 Sets Viewership Record with 900 Million Unique Viewers',
          'Magnus Carlsen Loses World Chess Title to 17-Year-Old Prodigy',
          'Sarina Wiegman Named Greatest Women''s Football Coach of All Time',
          'Anthony Davis Leads Lakers to First Championship Since 2020',
          'Iga Swiatek Wins French Open for Sixth Consecutive Year',
          'Formula 1 Adds Jakarta Street Circuit to 2027 Calendar'
        ])[i]
      ),
      format('sports-story-%s', i + 10),
      format('Breaking sports news and analysis about %s.',
        lower((ARRAY[
          'Super Bowl viewership records', 'Messi Ballon d''Or', 'Serena return',
          'AI offside technology', 'Federer foundation', 'NBA expansion',
          'Biles gymnastics', 'Mahomes milestone', 'Messi-Ronaldo final',
          'Mumbai 2036 Olympics', 'electric cycling', 'Spain women''s team',
          'Djokovic retirement', 'UFC record event', 'India cricket',
          'Fury vs Joshua', 'Formula E growth', 'Tiger Woods junior',
          'Wimbledon technology', 'Ronaldo Jr contract', 'Paris Olympics',
          'transfer spending', 'Mbappe record', 'Osaka comeback',
          'IPL viewership', 'chess prodigy', 'Wiegman coaching',
          'Lakers championship', 'Swiatek French Open', 'Jakarta F1'
        ])[i])
      ),
      repeat('Comprehensive sports coverage including match analysis, player statistics, expert commentary, and behind-the-scenes insights from the world of professional sports competition. ', 12),
      format('https://images.unsplash.com/photo-%s?w=1200',
        (ARRAY[
          '1546519638-68e109498ffc','1431324155629-1a6deb1dec8d','1622280227940-41ad9e8e9af4',
          '1568605117036-5fe5e7bab0b7','1574629810360-7efbbe195018','1504450758481-7338eba7524a',
          '1517927033932-b3d18e61fb3a','1558618666-fcd25c85cd64','1569693621544-9eacacd7612d',
          '1546519638-68e109498ffc','1431324155629-1a6deb1dec8d','1622280227940-41ad9e8e9af4',
          '1568605117036-5fe5e7bab0b7','1574629810360-7efbbe195018','1504450758481-7338eba7524a',
          '1517927033932-b3d18e61fb3a','1558618666-fcd25c85cd64','1569693621544-9eacacd7612d',
          '1546519638-68e109498ffc','1431324155629-1a6deb1dec8d','1622280227940-41ad9e8e9af4',
          '1568605117036-5fe5e7bab0b7','1574629810360-7efbbe195018','1504450758481-7338eba7524a',
          '1517927033932-b3d18e61fb3a','1558618666-fcd25c85cd64','1569693621544-9eacacd7612d',
          '1546519638-68e109498ffc','1431324155629-1a6deb1dec8d','1622280227940-41ad9e8e9af4'
        ])[i]
      ),
      format('https://images.unsplash.com/photo-%s?w=400',
        (ARRAY[
          '1546519638-68e109498ffc','1431324155629-1a6deb1dec8d','1622280227940-41ad9e8e9af4',
          '1568605117036-5fe5e7bab0b7','1574629810360-7efbbe195018','1504450758481-7338eba7524a',
          '1517927033932-b3d18e61fb3a','1558618666-fcd25c85cd64','1569693621544-9eacacd7612d',
          '1546519638-68e109498ffc','1431324155629-1a6deb1dec8d','1622280227940-41ad9e8e9af4',
          '1568605117036-5fe5e7bab0b7','1574629810360-7efbbe195018','1504450758481-7338eba7524a',
          '1517927033932-b3d18e61fb3a','1558618666-fcd25c85cd64','1569693621544-9eacacd7612d',
          '1546519638-68e109498ffc','1431324155629-1a6deb1dec8d','1622280227940-41ad9e8e9af4',
          '1568605117036-5fe5e7bab0b7','1574629810360-7efbbe195018','1504450758481-7338eba7524a',
          '1517927033932-b3d18e61fb3a','1558618666-fcd25c85cd64','1569693621544-9eacacd7612d',
          '1546519638-68e109498ffc','1431324155629-1a6deb1dec8d','1622280227940-41ad9e8e9af4'
        ])[i]
      ),
      (i % 3) + 2,
      'published',
      NOW() - (i * INTERVAL '3 hours') - INTERVAL '7 days'
    ) ON CONFLICT (slug) DO NOTHING;
  END LOOP;

  -- ── WORLD ──────────────────────────────────────────────────────────────────
  FOR i IN 1..30 LOOP
    INSERT INTO articles
      (category_id, author_id, title, slug, excerpt, content, image_url,
       thumbnail_url, read_time_minutes, status, published_at)
    VALUES (
      cat_world, author_id,
      format('World Story #%s: %s', i + 10,
        (ARRAY[
          'G20 Summit in Johannesburg Focuses on AI Governance Framework',
          'EU AI Act Enforcement Begins, First Fines Issued',
          'North Korea Launches First Civilian Space Agency',
          'Australia Bans Social Media for Under-16s, First Country Globally',
          'Brazil Hosts World''s Largest Reforestation Summit',
          'Turkey Joins BRICS Economic Bloc After Two Years of Talks',
          'UN Security Council Reform Adds African Permanent Seat',
          'Afghanistan Women''s Rights Crisis Triggers UN Emergency Session',
          'South Korea and Japan Sign Historic Reconciliation Treaty',
          'Panama Canal Expansion Phase 3 Breaks Ground',
          'Mediterranean Heatwave Breaks Records Across Seven Countries',
          'Mexico Becomes Largest US Trading Partner for Third Year',
          'Kenya Wins Bid to Host African Union Headquarters',
          'Pakistan and India Resume Bilateral Trade After Eight Years',
          'Arctic Shipping Route Opens Year-Round for First Time',
          'Global Water Crisis Report: 4 Billion Face Scarcity by 2030',
          'UK Rejoins EU Single Market Customs Union as Observer',
          'Iran Nuclear Deal Talks Resume in Geneva',
          'Philippines Reclaims South China Sea Reef After ICJ Ruling',
          'Pacific Island Nations Demand Climate Reparations at UN',
          'Nigeria Becomes Largest Economy in Africa, Overtakes South Africa',
          'Sweden Joins NATO''s Nuclear Sharing Agreement',
          'Singapore Becomes First City Fully Powered by Floating Solar',
          'Türkiye Mediates Sudan Peace Talks Successfully',
          'Rwanda''s Economic Model Draws Global Attention After IMF Report',
          'Cape Town Completes World''s First Desalination City Grid',
          'Venezuela Holds First Free Election in 25 Years',
          'Greenland Independence Vote Passes with 67% Majority',
          'Haiti Stabilization Mission Achieves Security Benchmarks',
          'Bolivia Discovers World''s Largest Lithium Reserve'
        ])[i]
      ),
      format('world-story-%s', i + 10),
      format('Global developments as %s reshapes international relations and policy.',
        lower((ARRAY[
          'G20 AI governance', 'EU AI enforcement', 'North Korea space program',
          'Australia social media ban', 'Brazil reforestation', 'Turkey in BRICS',
          'UN Security Council reform', 'Afghanistan crisis', 'Korea-Japan treaty',
          'Panama Canal expansion', 'Mediterranean climate', 'Mexico trade growth',
          'Kenya AU bid', 'India-Pakistan trade', 'Arctic shipping',
          'global water crisis', 'UK-EU relations', 'Iran nuclear talks',
          'Philippines sea rights', 'Pacific climate demands', 'Nigeria economy',
          'Sweden NATO nuclear', 'Singapore solar', 'Sudan peace talks',
          'Rwanda economic model', 'Cape Town desalination', 'Venezuela elections',
          'Greenland independence', 'Haiti stabilization', 'Bolivia lithium'
        ])[i])
      ),
      repeat('In-depth world news coverage examining geopolitical developments, humanitarian situations, diplomatic breakthroughs, and global policy shifts that affect billions of people worldwide. ', 14),
      format('https://images.unsplash.com/photo-%s?w=1200',
        (ARRAY[
          '1526406915894-7bcd65f60845','1552799446-159ba9523315','1524492412937-b28074a5d7da',
          '1477959858617-67f85cf4f1df','1451187580459-43490279c0fa','1540959733332-eab4deabeeaf',
          '1519923218604-6f8d64d50dde','1584036561566-baf8f5f1b144','1446776811953-b23d57bd21aa',
          '1526406915894-7bcd65f60845','1552799446-159ba9523315','1524492412937-b28074a5d7da',
          '1477959858617-67f85cf4f1df','1451187580459-43490279c0fa','1540959733332-eab4deabeeaf',
          '1519923218604-6f8d64d50dde','1584036561566-baf8f5f1b144','1446776811953-b23d57bd21aa',
          '1526406915894-7bcd65f60845','1552799446-159ba9523315','1524492412937-b28074a5d7da',
          '1477959858617-67f85cf4f1df','1451187580459-43490279c0fa','1540959733332-eab4deabeeaf',
          '1519923218604-6f8d64d50dde','1584036561566-baf8f5f1b144','1446776811953-b23d57bd21aa',
          '1526406915894-7bcd65f60845','1552799446-159ba9523315','1524492412937-b28074a5d7da'
        ])[i]
      ),
      format('https://images.unsplash.com/photo-%s?w=400',
        (ARRAY[
          '1526406915894-7bcd65f60845','1552799446-159ba9523315','1524492412937-b28074a5d7da',
          '1477959858617-67f85cf4f1df','1451187580459-43490279c0fa','1540959733332-eab4deabeeaf',
          '1519923218604-6f8d64d50dde','1584036561566-baf8f5f1b144','1446776811953-b23d57bd21aa',
          '1526406915894-7bcd65f60845','1552799446-159ba9523315','1524492412937-b28074a5d7da',
          '1477959858617-67f85cf4f1df','1451187580459-43490279c0fa','1540959733332-eab4deabeeaf',
          '1519923218604-6f8d64d50dde','1584036561566-baf8f5f1b144','1446776811953-b23d57bd21aa',
          '1526406915894-7bcd65f60845','1552799446-159ba9523315','1524492412937-b28074a5d7da',
          '1477959858617-67f85cf4f1df','1451187580459-43490279c0fa','1540959733332-eab4deabeeaf',
          '1519923218604-6f8d64d50dde','1584036561566-baf8f5f1b144','1446776811953-b23d57bd21aa',
          '1526406915894-7bcd65f60845','1552799446-159ba9523315','1524492412937-b28074a5d7da'
        ])[i]
      ),
      (i % 4) + 3,
      'published',
      NOW() - (i * INTERVAL '6 hours') - INTERVAL '7 days'
    ) ON CONFLICT (slug) DO NOTHING;
  END LOOP;

  -- ── SCIENCE ────────────────────────────────────────────────────────────────
  FOR i IN 1..30 LOOP
    INSERT INTO articles
      (category_id, author_id, title, slug, excerpt, content, image_url,
       thumbnail_url, read_time_minutes, status, published_at)
    VALUES (
      cat_science, author_id,
      format('Science Story #%s: %s', i + 10,
        (ARRAY[
          'Mars Sample Return Mission Brings First Martian Rocks to Earth',
          'Alzheimer''s Drug Lecanemab Slows Cognitive Decline by 35% in Trial',
          'New Battery Chemistry Charges EV to 80% in 4 Minutes',
          'Scientists Clone Extinct Thylacine, Bringing Tasmanian Tiger Back',
          'Ocean Cleanup Project Removes 100,000 Tonnes of Plastic',
          'Lab-Grown Meat Reaches Price Parity with Conventional Beef',
          'Neuralink Patient Controls Robotic Arm with Record 200 DoF Precision',
          'Astronomers Detect Signal Consistent with Dyson Sphere Structure',
          'mRNA Cancer Vaccine Shows 93% Remission Rate in Pancreatic Cancer',
          'CRISPR Therapy Cures Sickle Cell Disease in 95% of Patients',
          'World''s Fastest Supercomputer Achieves 2 Exaflops',
          'New Antibiotic Kills Resistant Bacteria Found in Soil Micro-organism',
          'Deep-Sea Mining Robot Discovers Undescribed Species Field',
          'Plastic-Eating Enzyme Upgraded to Break Down PET in 24 Hours',
          'Gravitational Wave Observatory Detects Neutron Star Merger in Milky Way',
          'Scientists Create First True Artificial Eye with Color and Depth Vision',
          'Photosynthesis Efficiency Doubled in Lab Using Quantum Dot Catalysts',
          'Human Organ Chip Replaced 40% of Animal Testing in Drug Trials',
          'Mycelium Network Found to Transmit Chemical Distress Signals at 1m/s',
          'Antarctic Ice Core Reveals CO2 Levels 14 Million Years in the Past',
          'Self-Healing Concrete Infrastructure Cuts Bridge Maintenance by 80%',
          'Quantum Internet Node Successfully Teleports Qubits 100km',
          'First Successful Xenotransplant Kidney Functions for 6 Months',
          'Deepest Ocean Trench Discovery Adds 3km to Mariana Depth Record',
          'Bird Migration Mystery Solved: Quantum Compass in Cryptochrome Proteins',
          'Neuroscience Maps Complete Fruit Fly Connectome, 140,000 Neurons',
          'Sea Level Rise Accelerating 40% Faster Than 2020 IPCC Projections',
          'First Exoplanet Atmosphere With All Building Blocks of Life Detected',
          'Scientists Achieve Direct Conversion of CO2 to Jet Fuel at 85% Efficiency',
          'Periodic Table Gets Element 120: Unbinilium Confirmed at CERN'
        ])[i]
      ),
      format('science-story-%s', i + 10),
      format('New research findings on %s with major implications for science and society.',
        lower((ARRAY[
          'Mars samples', 'Alzheimer''s treatment', 'EV battery technology',
          'thylacine cloning', 'ocean plastic cleanup', 'lab-grown meat',
          'Neuralink precision', 'Dyson sphere signals', 'cancer vaccines',
          'CRISPR sickle cell cure', 'supercomputers', 'antibiotic discovery',
          'deep-sea species', 'plastic-eating enzymes', 'gravitational waves',
          'artificial eyes', 'photosynthesis optimization', 'organ chip testing',
          'mycelium networks', 'Antarctic climate records', 'self-healing concrete',
          'quantum internet', 'xenotransplantation', 'ocean depth discovery',
          'bird quantum compass', 'connectome mapping', 'sea level rise',
          'exoplanet biosignatures', 'CO2 to fuel conversion', 'new periodic element'
        ])[i])
      ),
      repeat('Peer-reviewed scientific research translated for general audiences, covering methodology, implications, expert reactions, and the broader significance for human understanding and technological progress. ', 15),
      format('https://images.unsplash.com/photo-%s?w=1200',
        (ARRAY[
          '1532094349884-543559083c74','1462331940025-496dfbfc7564','1518770660439-4636190af475',
          '1559757148-5c350d0d3c56','1576086213369-97a306d36557','1446776895870-e32e47de8516',
          '1576765608535-5f04d1e3f289','1532187643603-ba119ca4109e','1544551763-46a013bb70d5',
          '1506905925346-21bda4d32df4','1532094349884-543559083c74','1462331940025-496dfbfc7564',
          '1518770660439-4636190af475','1559757148-5c350d0d3c56','1576086213369-97a306d36557',
          '1446776895870-e32e47de8516','1576765608535-5f04d1e3f289','1532187643603-ba119ca4109e',
          '1544551763-46a013bb70d5','1506905925346-21bda4d32df4','1532094349884-543559083c74',
          '1462331940025-496dfbfc7564','1518770660439-4636190af475','1559757148-5c350d0d3c56',
          '1576086213369-97a306d36557','1446776895870-e32e47de8516','1576765608535-5f04d1e3f289',
          '1532187643603-ba119ca4109e','1544551763-46a013bb70d5','1506905925346-21bda4d32df4'
        ])[i]
      ),
      format('https://images.unsplash.com/photo-%s?w=400',
        (ARRAY[
          '1532094349884-543559083c74','1462331940025-496dfbfc7564','1518770660439-4636190af475',
          '1559757148-5c350d0d3c56','1576086213369-97a306d36557','1446776895870-e32e47de8516',
          '1576765608535-5f04d1e3f289','1532187643603-ba119ca4109e','1544551763-46a013bb70d5',
          '1506905925346-21bda4d32df4','1532094349884-543559083c74','1462331940025-496dfbfc7564',
          '1518770660439-4636190af475','1559757148-5c350d0d3c56','1576086213369-97a306d36557',
          '1446776895870-e32e47de8516','1576765608535-5f04d1e3f289','1532187643603-ba119ca4109e',
          '1544551763-46a013bb70d5','1506905925346-21bda4d32df4','1532094349884-543559083c74',
          '1462331940025-496dfbfc7564','1518770660439-4636190af475','1559757148-5c350d0d3c56',
          '1576086213369-97a306d36557','1446776895870-e32e47de8516','1576765608535-5f04d1e3f289',
          '1532187643603-ba119ca4109e','1544551763-46a013bb70d5','1506905925346-21bda4d32df4'
        ])[i]
      ),
      (i % 4) + 3,
      'published',
      NOW() - (i * INTERVAL '7 hours') - INTERVAL '7 days'
    ) ON CONFLICT (slug) DO NOTHING;
  END LOOP;

END $$;

-- Verify final totals
SELECT c.name AS category, COUNT(a.id) AS total_articles,
       CEIL(COUNT(a.id)::float / 10) AS pages_with_limit_10
FROM articles a JOIN categories c ON a.category_id = c.id
WHERE a.status = 'published'
GROUP BY c.name ORDER BY c.name;
