/*
  # Fix User Registration Database Error

  1. Changes
    - Add proper RLS policies for service role during user registration
    - Ensure the handle_new_user function can insert data properly
    - Add error handling to the trigger function

  2. Security
    - Allow service role to bypass RLS during user registration trigger
    - Maintain security for regular user operations
*/

-- Drop existing trigger and function to recreate with better error handling
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user();

-- Add service role policies for profiles table
CREATE POLICY "Service role can insert profiles during registration"
  ON profiles
  FOR INSERT
  TO service_role
  WITH CHECK (true);

-- Add service role policies for daily_goals table  
CREATE POLICY "Service role can insert daily goals during registration"
  ON daily_goals
  FOR INSERT
  TO service_role
  WITH CHECK (true);

-- Recreate the handle_new_user function with better error handling
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
  -- Insert into profiles table
  INSERT INTO profiles (id, full_name)
  VALUES (
    NEW.id, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'User')
  );
  
  -- Insert initial daily goal
  INSERT INTO daily_goals (user_id, goal_type, target_value, date)
  VALUES (
    NEW.id, 
    'lessons_completed', 
    5, 
    CURRENT_DATE
  );
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log the error but don't fail the user creation
    RAISE LOG 'Error in handle_new_user: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();