# AI Usage Limit Implementation Summary

## Overview
Implemented a comprehensive AI usage tracking system to prevent spam and manage API costs. Each AI feature (Chat, Symptom Checker, Insights) is limited to **10 requests per user per day**.

## Database Schema
Added `ai_usage` table to track usage:
```sql
create table public.ai_usage (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) not null,
  feature_name text not null, -- 'chat', 'symptom_checker', 'insights'
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
```

## Implementation Details

### 1. **Usage Service** (`lib/features/usage/data/services/usage_service.dart`)
- `getTodayUsageCount(featureName)`: Returns current day's usage count
- `incrementUsage(featureName)`: Records a new usage entry
- `getAllTodayUsage()`: Returns usage stats for all features
- Daily limit constant: `UsageService.dailyLimit = 10`

### 2. **Chat Screen**
- ✅ Checks usage limit before sending messages
- ✅ Shows "Daily Usage: X/10" counter above input field
- ✅ Displays error snackbar when limit reached
- ✅ Increments usage after successful API call

### 3. **Symptom Checker Screen**
- ✅ Checks usage limit before analysis
- ✅ Shows "X/10 used" counter next to title
- ✅ Displays error snackbar when limit reached
- ✅ Increments usage after successful analysis

### 4. **Insights Screen** (On-Demand Loading)
- ✅ **Initial state**: Shows "Generate Insights" button with usage counter
- ✅ User must tap button to load insights (prevents automatic API calls)
- ✅ Checks usage limit before generating
- ✅ Shows "X/10" counter in app bar
- ✅ Displays error snackbar when limit reached
- ✅ Increments usage after successful generation

### 5. **Profile Screen** (Usage Dashboard)
- ✅ New "AI Usage Today" section
- ✅ Visual progress bars for each feature
- ✅ Color-coded icons (Blue=Chat, Red=Symptom, Purple=Insights)
- ✅ Shows "X/10" for each feature
- ✅ Progress bars fill based on usage percentage
- ✅ Red text when limit reached

## User Experience

### Visual Indicators
- **Green/Grey text**: Normal usage (0-9/10)
- **Red text**: Limit reached (10/10)
- **Progress bars**: Visual representation of usage
- **Calm presentation**: Non-intrusive, informative display

### Error Messages
All features show a friendly error message when limit is reached:
> "Daily limit reached for [Feature] (10/10). Try again tomorrow!"

### Reset Behavior
- Limits reset automatically at midnight UTC
- No manual reset required
- Database query filters by `created_at >= startOfDay`

## Files Modified/Created

### Created:
- `lib/features/usage/data/models/ai_usage.dart`
- `lib/features/usage/data/services/usage_service.dart`
- `lib/features/usage/presentation/providers/usage_providers.dart`

### Modified:
- `lib/core/database/supabase_schema.sql` - Added ai_usage table
- `lib/core/services/service_locator.dart` - Registered UsageService
- `lib/features/chat/presentation/chat_screen.dart` - Added usage tracking
- `lib/features/symptom_checker/presentation/symptom_checker_screen.dart` - Added usage tracking
- `lib/features/dashboard/presentation/insights_screen.dart` - Converted to on-demand loading
- `lib/features/profile/presentation/profile_screen.dart` - Added usage dashboard

## Next Steps

### Database Setup
Run the updated schema in your Supabase SQL editor:
```bash
# The ai_usage table creation is in:
lib/core/database/supabase_schema.sql (lines 117-135)
```

### Testing Checklist
- [ ] Test chat limit (send 10 messages, verify 11th is blocked)
- [ ] Test symptom checker limit (analyze 10 times, verify 11th is blocked)
- [ ] Test insights limit (generate 10 times, verify 11th is blocked)
- [ ] Verify usage counters update in real-time
- [ ] Check profile screen shows correct usage stats
- [ ] Confirm limits reset after midnight UTC

## Benefits
✅ **Cost Control**: Prevents excessive API usage
✅ **Spam Prevention**: 10 requests/day is reasonable for legitimate use
✅ **User Transparency**: Clear visibility of usage limits
✅ **Calm UX**: Non-intrusive, informative presentation
✅ **On-Demand Insights**: User controls when AI is invoked
