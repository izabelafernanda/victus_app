-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 25/01/2026 às 19:21
-- Versão do servidor: 10.4.32-MariaDB
-- Versão do PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `victus_db`
--

-- --------------------------------------------------------

--
-- Estrutura para tabela `banners`
--

CREATE TABLE `banners` (
  `id` int(11) NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `title` varchar(100) DEFAULT NULL,
  `subtitle` varchar(100) DEFAULT NULL,
  `link_url` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `banners`
--

INSERT INTO `banners` (`id`, `image_url`, `title`, `subtitle`, `link_url`) VALUES
(1, 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60', 'Bem-vinda à minha App!', 'Clica aqui para iniciares a tua jornada', NULL);

-- --------------------------------------------------------

--
-- Estrutura para tabela `courses`
--

CREATE TABLE `courses` (
  `id` int(11) NOT NULL,
  `title` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `type` enum('course','workshop','masterclass') DEFAULT 'course',
  `progress` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `courses`
--

INSERT INTO `courses` (`id`, `title`, `description`, `image_url`, `type`, `progress`) VALUES
(1, 'Liberdade Alimentar', NULL, 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=500', 'course', 0),
(2, 'Olimpo', NULL, 'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=500', 'course', 0),
(3, 'Joanaflix', NULL, 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=500', 'course', 0);

-- --------------------------------------------------------

--
-- Estrutura para tabela `daily_quotes`
--

CREATE TABLE `daily_quotes` (
  `id` int(11) NOT NULL,
  `message` text NOT NULL,
  `display_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `daily_quotes`
--

INSERT INTO `daily_quotes` (`id`, `message`, `display_date`) VALUES
(1, 'É importante agradecer pelo hoje, sem nunca desistir do amanhã!', '2026-01-22');

-- --------------------------------------------------------

--
-- Estrutura para tabela `daily_tips`
--

CREATE TABLE `daily_tips` (
  `id` int(11) NOT NULL,
  `title` varchar(100) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `background_color` varchar(20) DEFAULT '0xFFF8E8E8'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `daily_tips`
--

INSERT INTO `daily_tips` (`id`, `title`, `message`, `background_color`) VALUES
(3, NULL, 'É importante agradecer pelo hoje, sem nunca desistir do amanhã!', '0xFFF8E8E8');

-- --------------------------------------------------------

--
-- Estrutura para tabela `events`
--

CREATE TABLE `events` (
  `id` int(11) NOT NULL,
  `title` varchar(100) DEFAULT NULL,
  `date_label` varchar(20) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `events`
--

INSERT INTO `events` (`id`, `title`, `date_label`, `type`) VALUES
(4, 'Masterclass', '23/05', 'Masterclass'),
(5, 'Workshop', '12/08', 'Workshop'),
(7, '+ 1 evento', '', '');

-- --------------------------------------------------------

--
-- Estrutura para tabela `lessons`
--

CREATE TABLE `lessons` (
  `id` int(11) NOT NULL,
  `library_item_id` int(11) DEFAULT NULL,
  `title` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `video_url` varchar(255) DEFAULT NULL,
  `duration_minutes` int(11) DEFAULT NULL,
  `is_locked` tinyint(4) DEFAULT 1,
  `is_completed` tinyint(4) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `lessons`
--

INSERT INTO `lessons` (`id`, `library_item_id`, `title`, `description`, `video_url`, `duration_minutes`, `is_locked`, `is_completed`) VALUES
(1, 1, 'Bem-vindas', 'Nesta aula vamos aprender os conceitos fundamentais para iniciar a tua jornada.', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 5, 0, 1),
(2, 1, 'Guias Alimentares', 'Aqui vamos aprofundar as estratégias para manter a consistência a longo prazo.', '', 12, 0, 1),
(3, 1, 'Alimentação Saudável', 'Os pilares de uma vida saudável.', '', 20, 1, 0),
(4, 1, 'Emagrecimento', 'Estratégias avançadas para perda de peso.', '', 15, 1, 0),
(5, 1, 'Planeamento Alimentar', 'Como organizar a tua semana alimentar.', '', 30, 1, 0);

-- --------------------------------------------------------

--
-- Estrutura para tabela `library_items`
--

CREATE TABLE `library_items` (
  `id` int(11) NOT NULL,
  `title` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `progress` int(11) DEFAULT 0,
  `category` varchar(50) DEFAULT 'Curso',
  `video_url` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `library_items`
--

INSERT INTO `library_items` (`id`, `title`, `description`, `image_url`, `progress`, `category`, `video_url`) VALUES
(1, 'Liberdade Alimentar', 'Programa de 8 Semanas', 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?q=80&w=500', 80, 'Curso', 'https://www.youtube.com/watch?v=b_VObRzIKGY'),
(2, 'Olimpo', 'Corpo e mente invencíveis.', 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=500', 0, 'Curso', 'https://www.youtube.com/watch?v=UGzU8s8e3Zw'),
(3, 'Joanaflix', 'Desvenda o poder da nutrição com aulas didáticas.', 'https://images.unsplash.com/photo-1532012197267-da84d127e765?q=80&w=500', 0, 'Curso', NULL),
(4, 'Workshops', 'Aprenda na prática com especialistas.', 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?q=80&w=500', 0, 'Curso', NULL),
(5, 'Masterclasses', 'Conteúdo profundo e avançado.', 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?q=80&w=500', 0, 'Curso', NULL),
(6, 'Desafio Corpo & Mente Sã', 'Supere seus limites em 30 dias.', 'https://images.unsplash.com/photo-1545205597-3d9d02c29597?q=80&w=500', 0, 'Curso', NULL);

-- --------------------------------------------------------

--
-- Estrutura para tabela `modules`
--

CREATE TABLE `modules` (
  `id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `title` varchar(150) NOT NULL,
  `module_order` int(11) NOT NULL,
  `is_locked` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `modules`
--

INSERT INTO `modules` (`id`, `course_id`, `title`, `module_order`, `is_locked`) VALUES
(1, 1, '1 | Bem-vindas', 1, 0);

-- --------------------------------------------------------

--
-- Estrutura para tabela `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password` varchar(255) NOT NULL,
  `avatar_url` varchar(255) DEFAULT NULL,
  `weight_lost` decimal(5,2) DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `avatar_url`, `weight_lost`, `created_at`) VALUES
(1, 'Cristiana', 'cristiana@victus.pt', '$2y$10$T6dYqIov0KE0jGYq0Pzd/.CAWgT.Ey83wCgLvl68wNTMMCBRBOQ3y', 'https://i.pravatar.cc/300', 2.00, '2026-01-22 15:00:33');

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `banners`
--
ALTER TABLE `banners`
  ADD PRIMARY KEY (`id`);

--
-- Índices de tabela `courses`
--
ALTER TABLE `courses`
  ADD PRIMARY KEY (`id`);

--
-- Índices de tabela `daily_quotes`
--
ALTER TABLE `daily_quotes`
  ADD PRIMARY KEY (`id`);

--
-- Índices de tabela `daily_tips`
--
ALTER TABLE `daily_tips`
  ADD PRIMARY KEY (`id`);

--
-- Índices de tabela `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`id`);

--
-- Índices de tabela `lessons`
--
ALTER TABLE `lessons`
  ADD PRIMARY KEY (`id`),
  ADD KEY `library_item_id` (`library_item_id`);

--
-- Índices de tabela `library_items`
--
ALTER TABLE `library_items`
  ADD PRIMARY KEY (`id`);

--
-- Índices de tabela `modules`
--
ALTER TABLE `modules`
  ADD PRIMARY KEY (`id`),
  ADD KEY `course_id` (`course_id`);

--
-- Índices de tabela `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT para tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `banners`
--
ALTER TABLE `banners`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de tabela `courses`
--
ALTER TABLE `courses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de tabela `daily_quotes`
--
ALTER TABLE `daily_quotes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de tabela `daily_tips`
--
ALTER TABLE `daily_tips`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de tabela `events`
--
ALTER TABLE `events`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de tabela `lessons`
--
ALTER TABLE `lessons`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de tabela `library_items`
--
ALTER TABLE `library_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de tabela `modules`
--
ALTER TABLE `modules`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de tabela `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Restrições para tabelas despejadas
--

--
-- Restrições para tabelas `lessons`
--
ALTER TABLE `lessons`
  ADD CONSTRAINT `lessons_ibfk_1` FOREIGN KEY (`library_item_id`) REFERENCES `library_items` (`id`);

--
-- Restrições para tabelas `modules`
--
ALTER TABLE `modules`
  ADD CONSTRAINT `modules_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
