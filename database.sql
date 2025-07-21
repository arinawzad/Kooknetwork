-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jul 21, 2025 at 02:24 PM
-- Server version: 8.0.42-cll-lve
-- PHP Version: 8.3.23

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- 
--

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `community_channels`
--

CREATE TABLE `community_channels` (
  `id` bigint UNSIGNED NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `subtitle` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `community_channels`
--

INSERT INTO `community_channels` (`id`, `title`, `subtitle`, `url`, `type`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'x', 'kooknetwork', 'https://x.com/kooknetwork', 'twitter', 1, 1, '2025-03-28 22:54:20', '2025-03-28 22:54:20'),
(2, 'telegram', '@kooknetwork', 'https://t.me/kooknetwork', 'telegram', 2, 1, '2025-03-28 22:54:20', '2025-03-28 22:54:20'),
(3, 'youtube', '@kooknetwork\n', 'https://www.youtube.com/@kooknetwork', 'youtube', 3, 1, '2025-03-28 22:54:20', '2025-03-28 22:54:20');

-- --------------------------------------------------------

--
-- Table structure for table `community_posts`
--

CREATE TABLE `community_posts` (
  `id` bigint UNSIGNED NOT NULL,
  `username` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_avatar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `likes` int NOT NULL DEFAULT '0',
  `comments` int NOT NULL DEFAULT '0',
  `is_official` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `community_posts`
--

INSERT INTO `community_posts` (`id`, `username`, `user_avatar`, `content`, `image_url`, `likes`, `comments`, `is_official`, `created_at`, `updated_at`) VALUES
(1, 'Kook Team', NULL, 'Important update: We\'re upgrading our network infrastructure next week. Mining rates may fluctuate during this period. Thank you for your patience!', NULL, 57, 23, 1, '2025-03-28 20:54:20', '2025-03-28 20:54:20');

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `invite_usages`
--

CREATE TABLE `invite_usages` (
  `id` bigint UNSIGNED NOT NULL,
  `inviter_user_id` bigint UNSIGNED NOT NULL,
  `invited_user_id` bigint UNSIGNED NOT NULL,
  `invite_code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint UNSIGNED NOT NULL,
  `reserved_at` int UNSIGNED DEFAULT NULL,
  `available_at` int UNSIGNED NOT NULL,
  `created_at` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2025_03_27_150607_create_personal_access_tokens_table', 1),
(5, '2025_03_28_132032_create_teams_and_update_users_table', 2),
(6, '2025_03_28_142959_add_mining_fields_to_users_table', 2);

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE `password_resets` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `post_likes`
--

CREATE TABLE `post_likes` (
  `id` bigint UNSIGNED NOT NULL,
  `post_id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `projects`
--

CREATE TABLE `projects` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Planned',
  `progress` float NOT NULL DEFAULT '0',
  `due_date` date DEFAULT NULL,
  `priority` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Medium',
  `tasks` int DEFAULT NULL,
  `completed_tasks` int DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '0',
  `team` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ;

--
-- Dumping data for table `projects`
--

INSERT INTO `projects` (`id`, `name`, `status`, `progress`, `due_date`, `priority`, `tasks`, `completed_tasks`, `is_active`, `team`, `created_at`, `updated_at`) VALUES
(1, 'App Development (iOS & Android)', 'In Progress', 0.99, '2025-04-30', 'High', 30, 24, 1, NULL, '2025-03-29 09:07:55', '2025-03-29 09:07:55'),
(2, 'KYC Verification System', 'Planned', 0, NULL, 'Medium', NULL, NULL, 0, NULL, '2025-03-29 09:07:55', '2025-03-29 09:07:55'),
(3, 'Wallet Integration', 'Planned', 0, NULL, 'Medium', NULL, NULL, 0, NULL, '2025-03-29 09:07:55', '2025-03-29 09:07:55'),
(4, 'Mainnet Launch', 'Planned', 0, NULL, 'High', NULL, NULL, 0, NULL, '2025-03-29 09:07:55', '2025-03-29 09:07:55'),
(5, 'Token Listing on Exchange', 'Planned', 0, NULL, 'High', NULL, NULL, 0, NULL, '2025-03-29 09:07:55', '2025-03-29 09:07:55'),
(6, 'Smart Contract Deployment', 'Planned', 0, NULL, 'Medium', NULL, NULL, 0, NULL, '2025-03-29 09:07:55', '2025-03-29 09:07:55'),
(7, 'Ecosystem Expansion', 'Planned', 0, NULL, 'Low', NULL, NULL, 0, NULL, '2025-03-29 09:07:55', '2025-03-29 09:07:55');

-- --------------------------------------------------------

--
-- Table structure for table `referral_relationships`
--

CREATE TABLE `referral_relationships` (
  `id` bigint UNSIGNED NOT NULL,
  `referrer_id` bigint UNSIGNED NOT NULL,
  `referred_id` bigint UNSIGNED NOT NULL,
  `invite_code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tasks`
--

CREATE TABLE `tasks` (
  `id` bigint UNSIGNED NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `reward` double(8,2) NOT NULL,
  `due_date` date NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `action_type` enum('url','video','in_app','simple') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'simple',
  `action_data` text COLLATE utf8mb4_unicode_ci,
  `verification_code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tasks`
--

INSERT INTO `tasks` (`id`, `title`, `description`, `reward`, `due_date`, `is_active`, `action_type`, `action_data`, `verification_code`, `created_at`, `updated_at`) VALUES
(1, 'Join our Telegram community', 'Join our Telegram group to get the latest updates and connect with other miners', 5.00, '2025-04-04', 1, 'url', 'https://t.me/kookcoin', 'KOOK123', '2025-03-28 20:47:45', '2025-03-28 20:47:45'),
(2, 'Watch the tutorial video', 'Learn how to maximize your mining earnings with this short video', 3.00, '2025-04-02', 1, 'video', 'https://youtu.be/tutorial', 'MINE456', '2025-03-28 20:47:45', '2025-03-28 20:47:45'),
(3, 'Complete security verification', 'Secure your account with additional verification', 10.00, '2025-03-31', 1, 'in_app', NULL, 'SECURE789', '2025-03-28 20:47:45', '2025-03-28 20:47:45'),
(4, 'Follow our Twitter account', 'Stay updated with the latest news on Twitter', 2.50, '2025-04-07', 1, 'url', 'https://twitter.com/kookcoin', 'TWEET101', '2025-03-28 20:47:45', '2025-03-28 20:47:45'),
(5, 'Enable notifications', 'Don\'t miss important updates by enabling notifications', 1.00, '2025-03-30', 1, 'simple', NULL, NULL, '2025-03-28 20:47:45', '2025-03-28 20:47:45');

-- --------------------------------------------------------

--
-- Table structure for table `task_completions`
--

CREATE TABLE `task_completions` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `task_id` bigint UNSIGNED NOT NULL,
  `verification_code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `completed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `teams`
--

CREATE TABLE `teams` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `code` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `owner_id` bigint UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint UNSIGNED NOT NULL,
  `team_id` bigint UNSIGNED DEFAULT NULL,
  `base_balance` decimal(15,2) DEFAULT '0.00',
  `balance` decimal(10,2) NOT NULL DEFAULT '0.00',
  `mining_rate` decimal(5,2) NOT NULL DEFAULT '0.25',
  `last_balance_update` timestamp NULL DEFAULT NULL,
  `mining_session_start` timestamp NULL DEFAULT NULL,
  `mining_session_end` timestamp NULL DEFAULT NULL,
  `mining_status` enum('idle','active','completed','failed') COLLATE utf8mb4_unicode_ci DEFAULT 'idle',
  `last_mining_session` timestamp NULL DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_invite_codes`
--

CREATE TABLE `user_invite_codes` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `team_id` bigint UNSIGNED NOT NULL,
  `code` varchar(8) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `community_channels`
--
ALTER TABLE `community_channels`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `community_posts`
--
ALTER TABLE `community_posts`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `invite_usages`
--
ALTER TABLE `invite_usages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `invite_usages_inviter_user_id_foreign` (`inviter_user_id`),
  ADD KEY `invite_usages_invited_user_id_foreign` (`invited_user_id`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`);

--
-- Indexes for table `post_likes`
--
ALTER TABLE `post_likes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `post_likes_post_id_user_id_unique` (`post_id`,`user_id`),
  ADD KEY `post_likes_user_id_foreign` (`user_id`);

--
-- Indexes for table `projects`
--
ALTER TABLE `projects`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `referral_relationships`
--
ALTER TABLE `referral_relationships`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `referral_relationships_referred_id_unique` (`referred_id`),
  ADD KEY `referral_relationships_referrer_id_foreign` (`referrer_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `tasks`
--
ALTER TABLE `tasks`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `task_completions`
--
ALTER TABLE `task_completions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `task_completions_user_id_task_id_unique` (`user_id`,`task_id`),
  ADD KEY `task_completions_task_id_foreign` (`task_id`);

--
-- Indexes for table `teams`
--
ALTER TABLE `teams`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `owner_id` (`owner_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- Indexes for table `user_invite_codes`
--
ALTER TABLE `user_invite_codes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_invite_codes_code_unique` (`code`),
  ADD KEY `user_invite_codes_user_id_foreign` (`user_id`),
  ADD KEY `user_invite_codes_team_id_foreign` (`team_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `community_channels`
--
ALTER TABLE `community_channels`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `community_posts`
--
ALTER TABLE `community_posts`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `invite_usages`
--
ALTER TABLE `invite_usages`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=157;

--
-- AUTO_INCREMENT for table `post_likes`
--
ALTER TABLE `post_likes`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `projects`
--
ALTER TABLE `projects`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `referral_relationships`
--
ALTER TABLE `referral_relationships`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `tasks`
--
ALTER TABLE `tasks`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `task_completions`
--
ALTER TABLE `task_completions`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `teams`
--
ALTER TABLE `teams`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT for table `user_invite_codes`
--
ALTER TABLE `user_invite_codes`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `invite_usages`
--
ALTER TABLE `invite_usages`
  ADD CONSTRAINT `invite_usages_invited_user_id_foreign` FOREIGN KEY (`invited_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `invite_usages_inviter_user_id_foreign` FOREIGN KEY (`inviter_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `post_likes`
--
ALTER TABLE `post_likes`
  ADD CONSTRAINT `post_likes_post_id_foreign` FOREIGN KEY (`post_id`) REFERENCES `community_posts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `post_likes_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `referral_relationships`
--
ALTER TABLE `referral_relationships`
  ADD CONSTRAINT `referral_relationships_referred_id_foreign` FOREIGN KEY (`referred_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `referral_relationships_referrer_id_foreign` FOREIGN KEY (`referrer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `task_completions`
--
ALTER TABLE `task_completions`
  ADD CONSTRAINT `task_completions_task_id_foreign` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `task_completions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `teams`
--
ALTER TABLE `teams`
  ADD CONSTRAINT `teams_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `user_invite_codes`
--
ALTER TABLE `user_invite_codes`
  ADD CONSTRAINT `user_invite_codes_team_id_foreign` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_invite_codes_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
