DROP DATABASE IF EXISTS victus_db;
CREATE DATABASE victus_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE victus_db;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(255),
    weight_lost DECIMAL(5,2) DEFAULT 0.00, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE daily_quotes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message TEXT NOT NULL,
    display_date DATE 
);

CREATE TABLE events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    event_date DATE NOT NULL,
    event_type VARCHAR(50) 
);

CREATE TABLE courses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    image_url VARCHAR(255),
    type ENUM('course', 'workshop', 'masterclass') DEFAULT 'course',
    progress INT DEFAULT 0 
);

CREATE TABLE modules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    module_order INT NOT NULL, 
    is_locked BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

CREATE TABLE lessons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    module_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    video_url VARCHAR(255) NOT NULL,
    thumbnail_url VARCHAR(255),
    duration_seconds INT DEFAULT 0,
    is_completed BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE
);

INSERT INTO users (name, email, password, avatar_url, weight_lost) VALUES 
('Cristiana', 'cristiana@victus.pt', '$2y$10$2.H.x8j.x8j.x8j.x8j.x8j.x8j.x8j.x8j.x8j.x8j.x8j.x8j.', 'https://i.pravatar.cc/300', 2.0);

INSERT INTO daily_quotes (message, display_date) VALUES 
('É importante agradecer pelo hoje, sem nunca desistir do amanhã!', CURDATE());

INSERT INTO events (title, event_date, event_type) VALUES 
('Masterclass', '2026-05-23', 'Masterclass'),
('Workshop', '2026-08-12', 'Workshop');

INSERT INTO courses (title, image_url, type) VALUES 
('Liberdade Alimentar', 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=500', 'course'),
('Olimpo', 'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=500', 'course'),
('Joanaflix', 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=500', 'course');

INSERT INTO modules (course_id, title, module_order, is_locked) VALUES (1, '1 | Bem-vindas', 1, FALSE);
INSERT INTO lessons (module_id, title, video_url, duration_seconds) VALUES 
(1, 'Boas-vindas', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 120);
