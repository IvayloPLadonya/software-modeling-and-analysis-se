CREATE DATABASE TwitterDB;
GO
USE TwitterDB;
GO

CREATE TABLE [USER] (
    user_id INT IDENTITY PRIMARY KEY,
    username NVARCHAR(50) UNIQUE NOT NULL,
    email NVARCHAR(100) UNIQUE NOT NULL,
    password_hash NVARCHAR(255) NOT NULL,
    display_name NVARCHAR(100),
    bio NVARCHAR(280),
    avatar_url NVARCHAR(300),
    banner_url NVARCHAR(300),
    created_at DATETIME DEFAULT GETDATE(),
    is_verified BIT DEFAULT 0,
    is_premium BIT DEFAULT 0
);
GO

CREATE TABLE TWEET (
    tweet_id INT IDENTITY PRIMARY KEY,
    user_id INT NOT NULL,
    content NVARCHAR(500),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME,
    is_reply BIT DEFAULT 0,
    parent_tweet_id INT NULL,
    like_count INT DEFAULT 0,
    retweet_count INT DEFAULT 0,
    visibility NVARCHAR(20) DEFAULT 'public',

    FOREIGN KEY (user_id) REFERENCES [USER](user_id),
    FOREIGN KEY (parent_tweet_id) REFERENCES TWEET(tweet_id)
);
GO

CREATE TABLE MEDIA (
    media_id INT IDENTITY PRIMARY KEY,
    tweet_id INT NOT NULL,
    media_type NVARCHAR(20),
    media_url NVARCHAR(300),
    thumbnail_url NVARCHAR(300),
    duration_seconds INT,
    width INT,
    height INT,
    created_at DATETIME DEFAULT GETDATE(),

    FOREIGN KEY (tweet_id) REFERENCES TWEET(tweet_id)
);
GO

CREATE TABLE HASHTAG (
    hashtag_id INT IDENTITY PRIMARY KEY,
    tag_text NVARCHAR(100) UNIQUE NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    usage_count INT DEFAULT 0,
    language NVARCHAR(20)
);
GO

CREATE TABLE FOLLOW (
    follower_id INT NOT NULL,
    followed_id INT NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),

    PRIMARY KEY (follower_id, followed_id),
    FOREIGN KEY (follower_id) REFERENCES [USER](user_id),
    FOREIGN KEY (followed_id) REFERENCES [USER](user_id)
);
GO

CREATE TABLE [LIKE] (
    user_id INT NOT NULL,
    tweet_id INT NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),

    PRIMARY KEY (user_id, tweet_id),
    FOREIGN KEY (user_id) REFERENCES [USER](user_id),
    FOREIGN KEY (tweet_id) REFERENCES TWEET(tweet_id)
);
GO

CREATE TABLE TWEET_HASHTAG (
    tweet_id INT NOT NULL,
    hashtag_id INT NOT NULL,
    tagged_at DATETIME DEFAULT GETDATE(),

    PRIMARY KEY (tweet_id, hashtag_id),
    FOREIGN KEY (tweet_id) REFERENCES TWEET(tweet_id),
    FOREIGN KEY (hashtag_id) REFERENCES HASHTAG(hashtag_id)
);
GO
CREATE PROCEDURE PostTweet
    @user_id INT,
    @content NVARCHAR(500)
AS
BEGIN
    INSERT INTO TWEET (user_id, content)
    VALUES (@user_id, @content);
END;
GO
CREATE FUNCTION CountFollowers(@uid INT)
RETURNS INT
AS
BEGIN
    RETURN (SELECT COUNT(*) FROM FOLLOW WHERE followed_id = @uid);
END;
GO
CREATE TRIGGER AddLike_UpdateTweetCount
ON [LIKE]
AFTER INSERT
AS
BEGIN
    UPDATE TWEET
    SET like_count = like_count + 1
    WHERE tweet_id IN (SELECT tweet_id FROM inserted);
END;
GO
INSERT INTO [USER] (username, email, password_hash, display_name, bio, avatar_url, banner_url, is_verified, is_premium)
VALUES
('alex', 'alex@example.com', 'hash1', 'Alex Ivanov', 'Software developer.', NULL, NULL, 1, 1),
('maria', 'maria@example.com', 'hash2', 'Maria Petrova', 'Journalist & blogger.', NULL, NULL, 0, 0),
('nikola', 'nikola@example.com', 'hash3', 'Nikola Dimitrov', 'Sports analyst.', NULL, NULL, 0, 0),
('viktor', 'viktor@example.com', 'hash4', 'Viktor Stoyanov', 'Music producer.', NULL, NULL, 0, 1),
('elena', 'elena@example.com', 'hash5', 'Elena Georgieva', 'Photographer.', NULL, NULL, 1, 0);
GO
INSERT INTO TWEET (user_id, content)
VALUES
(1, 'Hello Twitter! This is my first post.'),
(2, 'Breaking news: New tech announcements expected tomorrow.'),
(3, 'What a great game last night! #sports'),
(4, 'Working on new music beats. Stay tuned!'),
(5, 'Check out my new photography shots ??');
GO
INSERT INTO MEDIA (tweet_id, media_type, media_url, width, height)
VALUES
(5, 'image', 'https://images.com/photo1.jpg', 1080, 720),
(4, 'video', 'https://videos.com/music-teaser.mp4', 1920, 1080),
(3, 'image', 'https://images.com/sports1.jpg', 1280, 720);
GO
INSERT INTO HASHTAG (tag_text, language)
VALUES
('#sports', 'en'),
('#news', 'en'),
('#music', 'en'),
('#photo', 'en');
GO
INSERT INTO TWEET_HASHTAG (tweet_id, hashtag_id)
VALUES
(3, 1),
(2, 2), 
(4, 3),
(5, 4); 
GO
INSERT INTO FOLLOW (follower_id, followed_id)
VALUES
(1, 2),
(1, 3),
(2, 1),
(3, 4),
(4, 5),
(5, 1);
GO
INSERT INTO [LIKE] (user_id, tweet_id)
VALUES
(1, 2),
(2, 1),
(3, 1),
(4, 3),
(5, 5),
(1, 5);
GO

SELECT * FROM [USER];
SELECT * FROM TWEET;
SELECT * FROM MEDIA;
SELECT * FROM HASHTAG;
SELECT * FROM TWEET_HASHTAG;
SELECT * FROM FOLLOW;
SELECT * FROM [LIKE];
