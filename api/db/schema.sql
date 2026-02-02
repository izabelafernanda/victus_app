-- Victus App - Schema otimizado com boas práticas de relacionamento
-- Melhorias: FKs com ON DELETE/UPDATE, integridade referencial, normalização, índices
-- Versão: 2.0 (refatorado)

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

CREATE DATABASE IF NOT EXISTS `victus_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `victus_db`;

-- --------------------------------------------------------
-- Tabela: users (entidade central - utilizadores)
-- --------------------------------------------------------
CREATE TABLE `users` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password` varchar(255) NOT NULL,
  `avatar_url` varchar(512) DEFAULT NULL,
  `weight_lost` decimal(5,2) UNSIGNED DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_users_email` (`email`),
  KEY `idx_users_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Tabela: library_items (cursos/conteúdos - entidade principal)
-- Relacionamento: 1 curso tem N aulas (lessons)
-- --------------------------------------------------------
CREATE TABLE `library_items` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `image_url` varchar(512) DEFAULT NULL,
  `progress` int(11) UNSIGNED DEFAULT 0,
  `category` varchar(50) DEFAULT 'Curso',
  `video_url` varchar(512) DEFAULT NULL,
  `display_order` int(11) UNSIGNED DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_library_category` (`category`),
  KEY `idx_library_display_order` (`display_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Tabela: lessons (aulas - pertencem a um library_item)
-- FK: library_item_id NOT NULL - integridade referencial
-- is_completed removido - é por utilizador (user_lesson_progress)
-- --------------------------------------------------------
CREATE TABLE `lessons` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `library_item_id` int(11) UNSIGNED NOT NULL,
  `title` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `video_url` varchar(512) DEFAULT NULL,
  `duration_minutes` int(11) UNSIGNED DEFAULT NULL,
  `lesson_order` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `is_locked` tinyint(1) UNSIGNED NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_lessons_library_item` (`library_item_id`),
  KEY `idx_lessons_order` (`library_item_id`, `lesson_order`),
  CONSTRAINT `fk_lessons_library_item` FOREIGN KEY (`library_item_id`) 
    REFERENCES `library_items` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Tabela: user_favorites (N:N user <-> lesson)
-- Um utilizador pode favoritar várias aulas; uma aula pode ser favoritada por vários
-- --------------------------------------------------------
CREATE TABLE `user_favorites` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` int(11) UNSIGNED NOT NULL,
  `lesson_id` int(11) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_lesson_fav` (`user_id`, `lesson_id`),
  KEY `idx_fav_user` (`user_id`),
  KEY `idx_fav_lesson` (`lesson_id`),
  CONSTRAINT `fk_favorites_user` FOREIGN KEY (`user_id`) 
    REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_favorites_lesson` FOREIGN KEY (`lesson_id`) 
    REFERENCES `lessons` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Tabela: user_lesson_progress (progresso por utilizador e aula)
-- Armazena segundos assistidos e conclusão
-- --------------------------------------------------------
CREATE TABLE `user_lesson_progress` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` int(11) UNSIGNED NOT NULL,
  `lesson_id` int(11) UNSIGNED NOT NULL,
  `progress_seconds` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_lesson_progress` (`user_id`, `lesson_id`),
  KEY `idx_progress_user` (`user_id`),
  KEY `idx_progress_lesson` (`lesson_id`),
  CONSTRAINT `fk_progress_user` FOREIGN KEY (`user_id`) 
    REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_progress_lesson` FOREIGN KEY (`lesson_id`) 
    REFERENCES `lessons` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Tabelas auxiliares (configuração/conteúdo estático)
-- --------------------------------------------------------
CREATE TABLE `banners` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `image_url` varchar(512) DEFAULT NULL,
  `title` varchar(150) DEFAULT NULL,
  `subtitle` varchar(150) DEFAULT NULL,
  `link_url` varchar(512) DEFAULT NULL,
  `display_order` int(11) UNSIGNED DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `daily_tips` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` varchar(150) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `background_color` varchar(20) DEFAULT '0xFFF8E8E8',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `daily_quotes` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `message` text NOT NULL,
  `display_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_quotes_date` (`display_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `events` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` varchar(150) DEFAULT NULL,
  `date_label` varchar(30) DEFAULT NULL,
  `event_date` date DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_events_date` (`event_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Tabelas courses e modules (estrutura alternativa/legado)
-- Mantidas para compatibilidade - relacionadas via conteúdo
-- --------------------------------------------------------
CREATE TABLE `courses` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `image_url` varchar(512) DEFAULT NULL,
  `type` enum('course','workshop','masterclass') DEFAULT 'course',
  `progress` int(11) UNSIGNED DEFAULT 0,
  `library_item_id` int(11) UNSIGNED DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_courses_library` (`library_item_id`),
  CONSTRAINT `fk_courses_library` FOREIGN KEY (`library_item_id`) 
    REFERENCES `library_items` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `modules` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `course_id` int(11) UNSIGNED NOT NULL,
  `title` varchar(150) NOT NULL,
  `module_order` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `is_locked` tinyint(1) UNSIGNED DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `idx_modules_course` (`course_id`),
  CONSTRAINT `fk_modules_course` FOREIGN KEY (`course_id`) 
    REFERENCES `courses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Dados iniciais
-- --------------------------------------------------------
INSERT INTO `users` (`id`, `name`, `email`, `password`, `avatar_url`, `weight_lost`) VALUES
(1, 'Cristiana', 'cristiana@victus.pt', '$2y$10$PjRrBkQvc5zDn2qz0bonKO3QUW6Cn1/YKe8HYq1wKBod/DJTlc94S', NULL, 2.00);

INSERT INTO `library_items` (`id`, `title`, `description`, `image_url`, `progress`, `category`, `video_url`, `display_order`) VALUES
(1, 'Liberdade Alimentar', 'Programa de 8 Semanas', 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?q=80&w=500', 80, 'Curso', 'https://www.youtube.com/watch?v=b_VObRzIKGY', 1),
(2, 'Olimpo', 'Corpo e mente invencíveis.', 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=500', 0, 'Curso', 'https://www.youtube.com/watch?v=UGzU8s8e3Zw', 2),
(3, 'Joanaflix', 'Desvenda o poder da nutrição com aulas didáticas.', 'https://images.unsplash.com/photo-1532012197267-da84d127e765?q=80&w=500', 0, 'Curso', NULL, 3),
(4, 'Workshops', 'Aprenda na prática com especialistas.', 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?q=80&w=500', 0, 'Curso', NULL, 4),
(5, 'Masterclasses', 'Conteúdo profundo e avançado.', 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?q=80&w=500', 0, 'Curso', NULL, 5),
(6, 'Desafio Corpo & Mente Sã', 'Supere seus limites em 30 dias.', 'https://images.unsplash.com/photo-1545205597-3d9d02c29597?q=80&w=500', 0, 'Curso', NULL, 6);

INSERT INTO `lessons` (`id`, `library_item_id`, `title`, `description`, `video_url`, `duration_minutes`, `lesson_order`, `is_locked`) VALUES
(1, 1, 'Bem-vindas', 'Nesta aula vamos aprender os conceitos fundamentais para iniciar a tua jornada.', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 5, 1, 0),
(2, 1, 'Guias Alimentares', 'Aqui vamos aprofundar as estratégias para manter a consistência a longo prazo.', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', 12, 2, 0),
(3, 1, 'Alimentação Saudável', 'Os pilares de uma vida saudável.', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4', 20, 3, 0),
(4, 1, 'Emagrecimento', 'Estratégias avançadas para perda de peso.', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4', 15, 4, 0),
(5, 1, 'Planeamento Alimentar', 'Como organizar a tua semana alimentar.', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4', 30, 5, 1);

INSERT INTO `banners` (`id`, `image_url`, `title`, `subtitle`, `link_url`) VALUES
(1, 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60', 'Bem-vinda à minha App!', 'Clica aqui para iniciares a tua jornada', NULL);

INSERT INTO `daily_tips` (`id`, `title`, `message`, `background_color`) VALUES
(1, NULL, 'É importante agradecer pelo hoje, sem nunca desistir do amanhã!', '0xFFF8E8E8');

INSERT INTO `daily_quotes` (`id`, `message`, `display_date`) VALUES
(1, 'É importante agradecer pelo hoje, sem nunca desistir do amanhã!', '2026-01-22');

INSERT INTO `events` (`id`, `title`, `date_label`, `type`) VALUES
(1, 'Masterclass', '23/05', 'Masterclass'),
(2, 'Workshop', '12/08', 'Workshop'),
(3, '+ 1 evento', '', '');

INSERT INTO `courses` (`id`, `title`, `description`, `image_url`, `type`, `progress`, `library_item_id`) VALUES
(1, 'Liberdade Alimentar', NULL, 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=500', 'course', 0, 1),
(2, 'Olimpo', NULL, 'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=500', 'course', 0, 2),
(3, 'Joanaflix', NULL, 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=500', 'course', 0, 3);

INSERT INTO `modules` (`id`, `course_id`, `title`, `module_order`, `is_locked`) VALUES
(1, 1, '1 | Bem-vindas', 1, 0);

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
