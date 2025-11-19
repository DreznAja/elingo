/*
  # Fix User Registration RLS Policies

  1. New Policies
    - Allow service_role to insert into profiles table during user registration
    - Allow service_role to manage daily_goals table during user registration

  2. Changes
    - Add service_role policies to enable the handle_new_user trigger to work properly
    - These policies allow the trigger function to bypass RLS restrictions during signup
*/

-- Add policy to allow service_role to insert into profiles table
CREATE POLICY "Service role can insert profiles"
  ON profiles
  FOR INSERT
  TO service_role
  WITH CHECK (true);

-- Add policy to allow service_role to manage daily_goals table
CREATE POLICY "Service role can manage daily goals"
  ON daily_goals
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);