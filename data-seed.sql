USE streamdb;

-- CLEAN OLD DATA (optional)
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE recommendations;
TRUNCATE TABLE payments;
TRUNCATE TABLE subscriptions;
TRUNCATE TABLE watch_history;
TRUNCATE TABLE devices;
TRUNCATE TABLE ratings;
TRUNCATE TABLE content_genres;
TRUNCATE TABLE genres;
TRUNCATE TABLE episodes;
TRUNCATE TABLE content;
TRUNCATE TABLE profiles;
TRUNCATE TABLE users;
TRUNCATE TABLE plans;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================
-- 1. PLANS
-- ============================
INSERT INTO plans (id, name, price_cents, max_streams, max_quality)
VALUES
(1, 'Basic', 499, 1, 'SD'),
(2, 'Standard', 799, 2, 'HD'),
(3, 'Premium', 1299, 4, 'UHD');

-- ============================
-- 2. USERS
-- ============================
INSERT INTO users (id, email, password_hash, plan_id, billing_address)
VALUES
('11111111-1111-1111-1111-111111111111', 'alice@example.com', 'hash1', 3, JSON_OBJECT('city','Metropolis')),
('22222222-2222-2222-2222-222222222222', 'bob@example.com', 'hash2', 2, JSON_OBJECT('city','Gotham')),
('33333333-3333-3333-3333-333333333333', 'carol@example.com', 'hash3', 1, JSON_OBJECT('city','Star City'));

-- ============================
-- 3. PROFILES
-- ============================
INSERT INTO profiles (id, user_id, name, is_kids, language)
VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', '11111111-1111-1111-1111-111111111111', 'Alice-main', 0, 'en'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', '11111111-1111-1111-1111-111111111111', 'Kiddo', 1, 'en'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', '22222222-2222-2222-2222-222222222222', 'Bob-main', 0, 'en'),
('cccccccc-cccc-cccc-cccc-ccccccccccc1', '33333333-3333-3333-3333-333333333333', 'Carol-main', 0, 'en');

-- ============================
-- 4. GENRES
-- ============================
INSERT INTO genres (id, name) VALUES
(1, 'Sci-Fi'),
(2, 'Comedy'),
(3, 'Documentary'),
(4, 'Kids'),
(5, 'Drama');

-- ============================
-- 5. CONTENT (3 movies + 2 series)
-- ============================
INSERT INTO content (id, title, slug, type, description, release_date, duration_seconds, maturity_rating, language)
VALUES
('c1', 'Space Quest', 'space-quest', 'series', 'Sci-fi space adventure', '2021-05-01', NULL, 'PG-13', 'en'),
('c2', 'Comedy Night', 'comedy-night', 'movie', 'Funny family comedy', '2020-08-15', 5400, 'U', 'en'),
('c3', 'History of Earth', 'history-earth', 'movie', 'Educational documentary', '2019-01-20', 3600, 'U', 'en'),
('c4', 'Kids Show!', 'kids-show', 'series', 'Children educational show', '2022-07-01', NULL, 'U', 'en'),
('c5', 'Life of Warriors', 'life-warriors', 'movie', 'Dramatic movie', '2023-04-12', 7200, 'PG-13', 'en');

-- ============================
-- 6. EPISODES
-- ============================
-- Space Quest S1E1–E3
INSERT INTO episodes (id, content_id, season, episode_no, title, duration_seconds, release_date)
VALUES
('e1', 'c1', 1, 1, 'Episode 1', 2400, '2021-05-01'),
('e2', 'c1', 1, 2, 'Episode 2', 2500, '2021-05-02'),
('e3', 'c1', 1, 3, 'Episode 3', 2600, '2021-05-03');

-- Kids Show! S1E1–E2
INSERT INTO episodes (id, content_id, season, episode_no, title, duration_seconds, release_date)
VALUES
('e4', 'c4', 1, 1, 'Kids Ep 1', 600, '2022-07-01'),
('e5', 'c4', 1, 2, 'Kids Ep 2', 620, '2022-07-02');

-- ============================
-- 7. CONTENT_GENRES
-- ============================
INSERT INTO content_genres (content_id, genre_id) VALUES
('c1', 1), -- Space Quest -> Sci-Fi
('c2', 2), -- Comedy Night -> Comedy
('c3', 3), -- History of Earth -> Documentary
('c4', 4), -- Kids Show -> Kids
('c5', 5); -- Warriors -> Drama

-- Multiple genres for Space Quest
INSERT INTO content_genres (content_id, genre_id) VALUES
('c1', 5); -- extra: Drama

-- ============================
-- 8. DEVICES
-- ============================
INSERT INTO devices (id, profile_id, device_type, device_name, last_seen_at)
VALUES
('d1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'web', 'Alice Laptop', NOW()),
('d2', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'android', 'Bob Phone', NOW());

-- ============================
-- 9. WATCH_HISTORY
-- ============================
INSERT INTO watch_history (profile_id, content_id, episode_id, watched_seconds, finished, last_watched_at)
VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'c1', 'e1', 1200, 0, NOW() - INTERVAL 3 DAY),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'c2', NULL, 5400, 1, NOW() - INTERVAL 1 DAY),
('cccccccc-cccc-cccc-cccc-ccccccccccc1', 'c3', NULL, 1800, 0, NOW() - INTERVAL 2 DAY),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'c5', NULL, 3500, 1, NOW() - INTERVAL 4 DAY);

-- ============================
-- 10. RATINGS
-- ============================
INSERT INTO ratings (profile_id, content_id, rating)
VALUES
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'c2', 4),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'c1', 5),
('cccccccc-cccc-cccc-cccc-ccccccccccc1', 'c3', 3);

-- ============================
-- 11. SUBSCRIPTIONS
-- ============================
INSERT INTO subscriptions (user_id, plan_id, started_at, next_billing_at, status)
VALUES
('11111111-1111-1111-1111-111111111111', 3, NOW() - INTERVAL 20 DAY, NOW() + INTERVAL 10 DAY, 'active'),
('22222222-2222-2222-2222-222222222222', 2, NOW() - INTERVAL 10 DAY, NOW() + INTERVAL 20 DAY, 'active'),
('33333333-3333-3333-3333-333333333333', 1, NOW() - INTERVAL 40 DAY, NOW() + INTERVAL 5 DAY, 'active');

-- ============================
-- 12. PAYMENTS
-- ============================
INSERT INTO payments (user_id, plan_id, amount_cents, provider, status, created_at)
VALUES
('11111111-1111-1111-1111-111111111111', 3, 1299, 'stripe', 'succeeded', NOW() - INTERVAL 20 DAY),
('22222222-2222-2222-2222-222222222222', 2, 799, 'stripe', 'succeeded', NOW() - INTERVAL 10 DAY);

-- ============================
-- 13. RECOMMENDATIONS (optional demo)
-- ============================
INSERT INTO recommendations (profile_id, content_id, score, reason)
VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'c3', 9.2, 'Because you watched Space Quest'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'c5', 7.8, 'Based on your interests');
