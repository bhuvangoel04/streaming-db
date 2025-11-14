CREATE DATABASE IF NOT EXISTS streamdb CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
USE streamdb;

-- PLANS
CREATE TABLE plans (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  price_cents BIGINT NOT NULL,
  max_streams INT NOT NULL,
  max_quality VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- USERS
CREATE TABLE users (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  plan_id INT NOT NULL,
  billing_address JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE,
  CONSTRAINT fk_users_plan FOREIGN KEY (plan_id) REFERENCES plans(id)
) ENGINE=InnoDB;

-- PROFILES
CREATE TABLE profiles (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  user_id CHAR(36) NOT NULL,
  name VARCHAR(100) NOT NULL,
  avatar VARCHAR(255),
  is_kids BOOLEAN DEFAULT FALSE,
  language VARCHAR(10) DEFAULT 'en',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_profiles_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- CONTENT
CREATE TABLE content (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  title VARCHAR(500) NOT NULL,
  slug VARCHAR(500) NOT NULL UNIQUE,
  type ENUM('movie','series') NOT NULL,
  description TEXT,
  release_date DATE,
  duration_seconds INT,
  maturity_rating VARCHAR(20),
  language VARCHAR(20),
  metadata JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- EPISODES
CREATE TABLE episodes (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  content_id CHAR(36) NOT NULL,
  season INT NOT NULL,
  episode_no INT NOT NULL,
  title VARCHAR(500),
  description TEXT,
  duration_seconds INT,
  release_date DATE,
  video_url VARCHAR(2000),
  CONSTRAINT uniq_episode UNIQUE (content_id, season, episode_no),
  CONSTRAINT fk_episodes_content FOREIGN KEY (content_id) REFERENCES content(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- GENRES
CREATE TABLE genres (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- CONTENT_GENRES (many-to-many)
CREATE TABLE content_genres (
  content_id CHAR(36) NOT NULL,
  genre_id INT NOT NULL,
  PRIMARY KEY (content_id, genre_id),
  CONSTRAINT fk_cg_content FOREIGN KEY (content_id) REFERENCES content(id) ON DELETE CASCADE,
  CONSTRAINT fk_cg_genre FOREIGN KEY (genre_id) REFERENCES genres(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- DEVICES
CREATE TABLE devices (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  profile_id CHAR(36),
  device_type VARCHAR(100),
  device_name VARCHAR(255),
  device_token VARCHAR(1000),
  last_seen_at TIMESTAMP NULL,
  CONSTRAINT fk_devices_profile FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- WATCH_HISTORY
CREATE TABLE watch_history (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  profile_id CHAR(36) NOT NULL,
  content_id CHAR(36) NOT NULL,
  episode_id CHAR(36),
  started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_watched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  watched_seconds INT DEFAULT 0,
  finished BOOLEAN DEFAULT FALSE,
  device_id CHAR(36),
  -- unique resume constraint (implies index) so ON DUPLICATE KEY works
  UNIQUE KEY uq_resume (profile_id, content_id, episode_id),
  CONSTRAINT fk_wh_profile FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE,
  CONSTRAINT fk_wh_content FOREIGN KEY (content_id) REFERENCES content(id),
  CONSTRAINT fk_wh_episode FOREIGN KEY (episode_id) REFERENCES episodes(id),
  CONSTRAINT fk_wh_device FOREIGN KEY (device_id) REFERENCES devices(id)
) ENGINE=InnoDB;

-- RATINGS
CREATE TABLE ratings (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  profile_id CHAR(36) NOT NULL,
  content_id CHAR(36) NOT NULL,
  rating TINYINT UNSIGNED CHECK (rating >= 1 AND rating <= 5),
  rated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_rating (profile_id, content_id),
  CONSTRAINT fk_ratings_profile FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE,
  CONSTRAINT fk_ratings_content FOREIGN KEY (content_id) REFERENCES content(id)
) ENGINE=InnoDB;

-- PAYMENTS
CREATE TABLE payments (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  plan_id INT NOT NULL,
  amount_cents BIGINT NOT NULL,
  currency CHAR(3) DEFAULT 'USD',
  provider VARCHAR(255),
  provider_txn_id VARCHAR(255),
  status VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NULL,
  CONSTRAINT fk_payments_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_payments_plan FOREIGN KEY (plan_id) REFERENCES plans(id)
) ENGINE=InnoDB;

-- SUBSCRIPTIONS
CREATE TABLE subscriptions (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id CHAR(36) NOT NULL UNIQUE,
  plan_id INT NOT NULL,
  started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  next_billing_at TIMESTAMP NULL,
  status VARCHAR(50) NOT NULL,
  cancel_at_period_end BOOLEAN DEFAULT FALSE,
  CONSTRAINT fk_sub_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_sub_plan FOREIGN KEY (plan_id) REFERENCES plans(id)
) ENGINE=InnoDB;

-- RECOMMENDATIONS
CREATE TABLE recommendations (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  profile_id CHAR(36) NOT NULL,
  content_id CHAR(36) NOT NULL,
  score DOUBLE NOT NULL,
  reason VARCHAR(1000),
  generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_rec (profile_id, content_id),
  CONSTRAINT fk_rec_profile FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE,
  CONSTRAINT fk_rec_content FOREIGN KEY (content_id) REFERENCES content(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- EVENTS (audit)
CREATE TABLE events (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id CHAR(36),
  profile_id CHAR(36),
  event_type VARCHAR(255) NOT NULL,
  payload JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_event_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_event_profile FOREIGN KEY (profile_id) REFERENCES profiles(id)
) ENGINE=InnoDB;
