/*
  # Language Learning App Database Schema

  1. New Tables
    - `profiles` - User profile information
      - `id` (uuid, references auth.users)
      - `full_name` (text)
      - `avatar_url` (text, optional)
      - `level` (integer, default 1)
      - `total_xp` (integer, default 0)
      - `current_streak` (integer, default 0)
      - `longest_streak` (integer, default 0)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

    - `languages` - Available languages to learn
      - `id` (uuid, primary key)
      - `name` (text)
      - `code` (text, unique)
      - `flag_emoji` (text)
      - `difficulty_level` (integer)
      - `total_lessons` (integer)
      - `created_at` (timestamp)

    - `courses` - Language courses
      - `id` (uuid, primary key)
      - `language_id` (uuid, references languages)
      - `title` (text)
      - `description` (text)
      - `difficulty_level` (integer)
      - `total_lessons` (integer)
      - `order_index` (integer)
      - `created_at` (timestamp)

    - `lessons` - Individual lessons
      - `id` (uuid, primary key)
      - `course_id` (uuid, references courses)
      - `title` (text)
      - `description` (text)
      - `lesson_type` (text)
      - `content` (jsonb)
      - `order_index` (integer)
      - `xp_reward` (integer, default 10)
      - `created_at` (timestamp)

    - `user_progress` - Track user progress
      - `id` (uuid, primary key)
      - `user_id` (uuid, references profiles)
      - `course_id` (uuid, references courses)
      - `lessons_completed` (integer, default 0)
      - `total_xp_earned` (integer, default 0)
      - `accuracy_percentage` (decimal, default 0)
      - `last_accessed` (timestamp)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

    - `lesson_completions` - Track completed lessons
      - `id` (uuid, primary key)
      - `user_id` (uuid, references profiles)
      - `lesson_id` (uuid, references lessons)
      - `score` (integer)
      - `accuracy` (decimal)
      - `time_spent` (integer)
      - `completed_at` (timestamp)

    - `achievements` - Available achievements
      - `id` (uuid, primary key)
      - `title` (text)
      - `description` (text)
      - `icon` (text)
      - `requirement_type` (text)
      - `requirement_value` (integer)
      - `xp_reward` (integer, default 50)
      - `created_at` (timestamp)

    - `user_achievements` - User earned achievements
      - `id` (uuid, primary key)
      - `user_id` (uuid, references profiles)
      - `achievement_id` (uuid, references achievements)
      - `earned_at` (timestamp)

    - `daily_goals` - User daily goals
      - `id` (uuid, primary key)
      - `user_id` (uuid, references profiles)
      - `goal_type` (text)
      - `target_value` (integer)
      - `current_value` (integer, default 0)
      - `date` (date)
      - `completed` (boolean, default false)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users to manage their own data
    - Public read access for languages, courses, lessons, and achievements
*/

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name text NOT NULL,
  avatar_url text,
  level integer DEFAULT 1,
  total_xp integer DEFAULT 0,
  current_streak integer DEFAULT 0,
  longest_streak integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create languages table
CREATE TABLE IF NOT EXISTS languages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  code text UNIQUE NOT NULL,
  flag_emoji text NOT NULL,
  difficulty_level integer DEFAULT 1,
  total_lessons integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Create courses table
CREATE TABLE IF NOT EXISTS courses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  language_id uuid REFERENCES languages(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  difficulty_level integer DEFAULT 1,
  total_lessons integer DEFAULT 0,
  order_index integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Create lessons table
CREATE TABLE IF NOT EXISTS lessons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  lesson_type text DEFAULT 'multiple-choice',
  content jsonb NOT NULL,
  order_index integer DEFAULT 0,
  xp_reward integer DEFAULT 10,
  created_at timestamptz DEFAULT now()
);

-- Create user_progress table
CREATE TABLE IF NOT EXISTS user_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  lessons_completed integer DEFAULT 0,
  total_xp_earned integer DEFAULT 0,
  accuracy_percentage decimal DEFAULT 0,
  last_accessed timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, course_id)
);

-- Create lesson_completions table
CREATE TABLE IF NOT EXISTS lesson_completions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  lesson_id uuid REFERENCES lessons(id) ON DELETE CASCADE,
  score integer NOT NULL,
  accuracy decimal NOT NULL,
  time_spent integer DEFAULT 0,
  completed_at timestamptz DEFAULT now(),
  UNIQUE(user_id, lesson_id)
);

-- Create achievements table
CREATE TABLE IF NOT EXISTS achievements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  icon text NOT NULL,
  requirement_type text NOT NULL,
  requirement_value integer NOT NULL,
  xp_reward integer DEFAULT 50,
  created_at timestamptz DEFAULT now()
);

-- Create user_achievements table
CREATE TABLE IF NOT EXISTS user_achievements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  achievement_id uuid REFERENCES achievements(id) ON DELETE CASCADE,
  earned_at timestamptz DEFAULT now(),
  UNIQUE(user_id, achievement_id)
);

-- Create daily_goals table
CREATE TABLE IF NOT EXISTS daily_goals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  goal_type text NOT NULL,
  target_value integer NOT NULL,
  current_value integer DEFAULT 0,
  date date DEFAULT CURRENT_DATE,
  completed boolean DEFAULT false,
  UNIQUE(user_id, goal_type, date)
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE languages ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_goals ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can read own profile"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Languages policies (public read)
CREATE POLICY "Anyone can read languages"
  ON languages
  FOR SELECT
  TO authenticated
  USING (true);

-- Courses policies (public read)
CREATE POLICY "Anyone can read courses"
  ON courses
  FOR SELECT
  TO authenticated
  USING (true);

-- Lessons policies (public read)
CREATE POLICY "Anyone can read lessons"
  ON lessons
  FOR SELECT
  TO authenticated
  USING (true);

-- User progress policies
CREATE POLICY "Users can read own progress"
  ON user_progress
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own progress"
  ON user_progress
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own progress"
  ON user_progress
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

-- Lesson completions policies
CREATE POLICY "Users can read own completions"
  ON lesson_completions
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own completions"
  ON lesson_completions
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Achievements policies (public read)
CREATE POLICY "Anyone can read achievements"
  ON achievements
  FOR SELECT
  TO authenticated
  USING (true);

-- User achievements policies
CREATE POLICY "Users can read own achievements"
  ON user_achievements
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own achievements"
  ON user_achievements
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Daily goals policies
CREATE POLICY "Users can manage own daily goals"
  ON daily_goals
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create function to handle user registration
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO profiles (id, full_name)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'));
  
  -- Create initial daily goal
  INSERT INTO daily_goals (user_id, goal_type, target_value, date)
  VALUES (NEW.id, 'lessons_completed', 5, CURRENT_DATE);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user registration
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Insert sample data
INSERT INTO languages (name, code, flag_emoji, difficulty_level, total_lessons) VALUES
  ('Spanish', 'es', '🇪🇸', 1, 24),
  ('French', 'fr', '🇫🇷', 2, 18),
  ('Japanese', 'ja', '🇯🇵', 3, 32),
  ('German', 'de', '🇩🇪', 2, 20),
  ('Italian', 'it', '🇮🇹', 1, 16),
  ('Portuguese', 'pt', '🇵🇹', 1, 14)
ON CONFLICT (code) DO NOTHING;

-- Insert sample courses
INSERT INTO courses (language_id, title, description, difficulty_level, total_lessons, order_index)
SELECT 
  l.id,
  CASE l.code
    WHEN 'es' THEN 'Spanish Basics'
    WHEN 'fr' THEN 'French Conversation'
    WHEN 'ja' THEN 'Japanese Writing'
    WHEN 'de' THEN 'German Grammar'
    WHEN 'it' THEN 'Italian Essentials'
    WHEN 'pt' THEN 'Portuguese Fundamentals'
  END,
  CASE l.code
    WHEN 'es' THEN 'Learn basic Spanish vocabulary and grammar'
    WHEN 'fr' THEN 'Master French conversation skills'
    WHEN 'ja' THEN 'Learn Japanese writing systems'
    WHEN 'de' THEN 'Understand German grammar rules'
    WHEN 'it' THEN 'Essential Italian for beginners'
    WHEN 'pt' THEN 'Portuguese language fundamentals'
  END,
  l.difficulty_level,
  l.total_lessons,
  1
FROM languages l;

-- Insert sample lessons for Spanish course
INSERT INTO lessons (course_id, title, description, lesson_type, content, order_index, xp_reward)
SELECT 
  c.id,
  'Basic Greetings',
  'Learn common Spanish greetings',
  'multiple-choice',
  '[
    {
      "type": "multiple-choice",
      "question": "How do you say \"Hello\" in Spanish?",
      "options": ["Hola", "Adiós", "Gracias", "Por favor"],
      "correct": "Hola"
    },
    {
      "type": "multiple-choice",
      "question": "What does \"Gracias\" mean?",
      "options": ["Please", "Thank you", "Excuse me", "You are welcome"],
      "correct": "Thank you"
    },
    {
      "type": "translation",
      "question": "Translate: \"Good morning\"",
      "options": ["Buenas noches", "Buenos días", "Buenas tardes", "Hasta luego"],
      "correct": "Buenos días"
    }
  ]'::jsonb,
  1,
  15
FROM courses c
JOIN languages l ON c.language_id = l.id
WHERE l.code = 'es';

-- Insert sample achievements
INSERT INTO achievements (title, description, icon, requirement_type, requirement_value, xp_reward) VALUES
  ('First Lesson', 'Complete your first lesson', '🎯', 'lessons_completed', 1, 50),
  ('Week Streak', '7 days in a row', '🔥', 'streak_days', 7, 100),
  ('Quick Learner', 'Perfect score on 5 lessons', '⚡', 'perfect_scores', 5, 150),
  ('Dedicated Student', 'Study for 30 days', '📚', 'study_days', 30, 300),
  ('Language Explorer', 'Try 3 different languages', '🌍', 'languages_tried', 3, 200),
  ('XP Master', 'Earn 1000 XP', '💎', 'total_xp', 1000, 500);