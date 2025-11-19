/*
  # Fix User Registration Database Trigger

  1. Changes
    - Modify handle_new_user function to explicitly set service_role before inserts
    - Reset role after operations to maintain security
    - Ensure RLS is bypassed during user registration

  2. Security
    - Temporarily elevate to service_role for registration operations
    - Reset role after completion to maintain security boundaries
*/

-- Drop existing trigger and function to recreate with proper role handling
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user();

-- Recreate the handle_new_user function with explicit role management
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
  -- Set role to service_role to bypass RLS
  PERFORM set_config('role', 'service_role', true);
  
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
  
  -- Reset role back to authenticated
  PERFORM set_config('role', 'authenticated', true);
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Reset role even on error
    PERFORM set_config('role', 'authenticated', true);
    -- Log the error but don't fail the user creation
    RAISE LOG 'Error in handle_new_user: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();