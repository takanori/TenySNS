CREATE TABLE IF NOT EXISTS user (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  email TEXT,
  password TEXT,
  salt TEXT,
  bio TEXT,
  created_at INTEGER
);

CREATE TABLE IF NOT EXISTS tweet (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  text TEXT,
  created_at INTEGER
);

CREATE TABLE IF NOT EXISTS follow (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  follower_id INTEGER,
  followee_id INTEGER,
  created_at INTEGER
);
