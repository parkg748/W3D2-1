DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;

PRAGMA foreign_keys = ON;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Grace', 'Park'),
  ('Anthony', 'Tam'),
  ('Cynthia', 'Ma');

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER,
  
  FOREIGN KEY (author_id) REFERENCES users(id)
);

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('What is App Academy?', 'I want to know.', 1);
  
INSERT INTO
  questions (title, body, author_id)
SELECT
  'Anthony Question', 'ANTHONY', users.id
FROM
  users
WHERE
  users.fname = 'Anthony' AND users.lname = 'Tam';

INSERT INTO
  questions (title, body, author_id)
SELECT
  'Grace Question', 'GRACE', users.id
FROM
  users
WHERE
  users.fname = 'Grace' AND users.lname = 'Park';

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER,
  user_id INTEGER,
  
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
  question_follows (question_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE questions.title = 'Anthony Question'),
  (SELECT id FROM users WHERE users.fname = 'Anthony'));

INSERT INTO
  question_follows (question_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE questions.title = 'Grace Question'),
  (SELECT id FROM users WHERE users.fname = 'Grace'));
  

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  question_id INTEGER NOT NULL,
  author_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (author_id) REFERENCES users(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id)
);

INSERT INTO
  replies (body, question_id, author_id, parent_reply_id)
VALUES
  (('Ok, I''ll answer your question'), (SELECT id FROM questions WHERE questions.title = 'Anthony Question'),
  (SELECT id FROM users WHERE users.fname = 'Anthony'), NULL);
  
INSERT INTO
  replies (body, question_id, author_id, parent_reply_id)
VALUES
  (('Yes, please answer'), (SELECT id FROM questions WHERE questions.title = 'Anthony Question'),
  (SELECT id FROM users WHERE users.lname = 'Park'), (SELECT id FROM replies WHERE body = 'Ok, I''ll answer your question'));



CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  question_id INTEGER,
  
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id) 
);

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE users.fname = 'Anthony'), 
  (SELECT id FROM questions WHERE questions.title = 'Anthony Question'));
  
INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE users.fname = 'Grace'), 
  (SELECT id FROM questions WHERE questions.title = 'Grace Question'));