-- ============================================
-- Chat History Migration
-- Run this in your Supabase SQL Editor
-- ============================================

-- Create chat_messages table
CREATE TABLE IF NOT EXISTS public.chat_messages (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id uuid REFERENCES public.users(id) NOT NULL,
  text text NOT NULL,
  is_user boolean NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for chat_messages
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own chat messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Users can insert own chat messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Users can delete own chat messages" ON public.chat_messages;

-- Create policies for chat_messages
CREATE POLICY "Users can view own chat messages" ON public.chat_messages
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own chat messages" ON public.chat_messages
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own chat messages" ON public.chat_messages
  FOR DELETE USING (auth.uid() = user_id);

-- Drop existing index if it exists
DROP INDEX IF EXISTS chat_messages_user_created_idx;

-- Create index for faster queries
CREATE INDEX chat_messages_user_created_idx ON public.chat_messages(user_id, created_at ASC);
