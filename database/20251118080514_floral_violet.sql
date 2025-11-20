/*
  # Fix User Registration Database Trigger - Final Solution

  1. Changes
    - Create a proper service role function that can bypass RLS
    - Use SECURITY DEFINER to run with elevated privileges
    - Ensure proper error handling and role management

  2. Security
    - Function runs with definer rights (service_role equivalent)
    - Maintains security boundaries for regular operations
*/

-- Drop existing trigger and function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user();

-- Remove the problematic service role policies
DROP POLICY IF EXISTS "Service role can insert profiles" ON profiles;
DROP POLICY IF EXISTS "Service role can manage daily goals" ON daily_goals;
DROP POLICY IF EXISTS "Service role can insert profiles during registration" ON profiles;
DROP POLICY IF EXISTS "Service role can insert daily goals during registration" ON daily_goals;

-- Create a new function that runs with definer privileges
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Insert into profiles table (this will run with elevated privileges)
  INSERT INTO public.profiles (id, full_name, level, total_xp, current_streak, longest_streak)
  VALUES (
    NEW.id, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
    1,
    0,
    0,
    0
  );
  
  -- Insert initial daily goal
  INSERT INTO public.daily_goals (user_id, goal_type, target_value, current_value, date, completed)
  VALUES (
    NEW.id, 
    'lessons_completed', 
    5,
    0,
    CURRENT_DATE,
    false
  );
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log the error but don't fail the user creation
    RAISE LOG 'Error in handle_new_user for user %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$;

-- Recreate the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();