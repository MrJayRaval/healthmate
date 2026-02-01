-- ============================================
-- AI Usage Tracking Migration
-- Run this in your Supabase SQL Editor
-- ============================================

-- Create ai_usage table (only if it doesn't exist)
CREATE TABLE IF NOT EXISTS public.ai_usage (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id uuid REFERENCES public.users(id) NOT NULL,
  feature_name text NOT NULL, -- 'chat', 'symptom_checker', 'insights'
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for ai_usage
ALTER TABLE public.ai_usage ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view own ai usage" ON public.ai_usage;
DROP POLICY IF EXISTS "Users can insert own ai usage" ON public.ai_usage;

-- Create policies for ai_usage
CREATE POLICY "Users can view own ai usage" ON public.ai_usage
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own ai usage" ON public.ai_usage
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Drop existing index if it exists
DROP INDEX IF EXISTS ai_usage_user_feature_date_idx;

-- Create index for faster daily queries
CREATE INDEX ai_usage_user_feature_date_idx ON public.ai_usage(user_id, feature_name, created_at);

-- ============================================
-- Verification Query (Optional - Run separately to check)
-- ============================================
-- SELECT 
--   table_name, 
--   column_name, 
--   data_type 
-- FROM information_schema.columns 
-- WHERE table_name = 'ai_usage' 
-- ORDER BY ordinal_position;
