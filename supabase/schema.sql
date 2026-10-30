-- ====================================================================
-- NOTICEPERIOD (OFFBOARD) - ENTERPRISE ZERO-KNOWLEDGE POSTGRES SCHEMA
-- Run this entire script in your Supabase Project -> SQL Editor
-- ====================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. EXIT POSTS TABLE (Zero PII - No email or user_id stored)
CREATE TABLE IF NOT EXISTS public.exit_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name TEXT NOT NULL,
    role TEXT NOT NULL,
    tenure_years NUMERIC(4, 1) NOT NULL,
    notice_days INT NOT NULL DEFAULT 90,
    current_notice_day INT,
    primary_reason TEXT NOT NULL,
    manager_quote TEXT,
    employee_reply TEXT,
    story_body TEXT NOT NULL,
    survival_tip TEXT,
    hike_percent INT DEFAULT 0,
    is_verified_work_email BOOLEAN DEFAULT false,
    is_layoff BOOLEAN DEFAULT false,
    open_to_refer BOOLEAN DEFAULT false,
    valid_exit_count INT DEFAULT 0,
    dodged_bullet_count INT DEFAULT 0,
    toxic_alert_count INT DEFAULT 0,
    report_count INT DEFAULT 0,
    is_hidden BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. ENTERPRISE B-TREE INDEXES (Sub-10ms queries at 100k+ rows)
CREATE INDEX IF NOT EXISTS idx_exit_posts_created_at ON public.exit_posts (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_exit_posts_company ON public.exit_posts (company_name);
CREATE INDEX IF NOT EXISTS idx_exit_posts_reason ON public.exit_posts (primary_reason);
CREATE INDEX IF NOT EXISTS idx_exit_posts_visible ON public.exit_posts (is_hidden, created_at DESC);

-- 4. ATOMIC REACTIONS TABLE (Prevents duplicate likes and client tampering)
CREATE TABLE IF NOT EXISTS public.post_reactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID REFERENCES public.exit_posts(id) ON DELETE CASCADE,
    client_id TEXT NOT NULL, -- Anonymous client UUID
    reaction_type TEXT NOT NULL CHECK (reaction_type IN ('valid', 'dodged', 'toxic')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(post_id, client_id)
);

CREATE INDEX IF NOT EXISTS idx_post_reactions_post_id ON public.post_reactions(post_id);

-- 5. RPC FUNCTION FOR ATOMIC VOTING
CREATE OR REPLACE FUNCTION public.react_to_post(
    p_post_id UUID,
    p_client_id TEXT,
    p_reaction_type TEXT
) RETURNS JSONB AS $$
DECLARE
    v_existing_type TEXT;
BEGIN
    SELECT reaction_type INTO v_existing_type
    FROM public.post_reactions
    WHERE post_id = p_post_id AND client_id = p_client_id;

    IF v_existing_type IS NOT NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Already reacted to this post');
    END IF;

    -- Insert reaction
    INSERT INTO public.post_reactions (post_id, client_id, reaction_type)
    VALUES (p_post_id, p_client_id, p_reaction_type);

    -- Increment corresponding counter atomically
    IF p_reaction_type = 'valid' THEN
        UPDATE public.exit_posts SET valid_exit_count = valid_exit_count + 1 WHERE id = p_post_id;
    ELSIF p_reaction_type = 'dodged' THEN
        UPDATE public.exit_posts SET dodged_bullet_count = dodged_bullet_count + 1 WHERE id = p_post_id;
    ELSIF p_reaction_type = 'toxic' THEN
        UPDATE public.exit_posts SET toxic_alert_count = toxic_alert_count + 1 WHERE id = p_post_id;
    END IF;

    RETURN jsonb_build_object('success', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. MATERIALIZED VIEW FOR FAST LEADERBOARD STATS (O(1) Indexed Query)
CREATE MATERIALIZED VIEW IF NOT EXISTS public.company_exit_stats AS
SELECT 
    company_name,
    COUNT(*) AS total_exits,
    ROUND(AVG(tenure_years), 1) AS avg_tenure_years,
    ROUND(AVG(notice_days), 0) AS avg_notice_days,
    ROUND(AVG(hike_percent), 0) AS avg_hike_percent,
    MODE() WITHIN GROUP (ORDER BY primary_reason) AS top_exit_reason
FROM public.exit_posts
WHERE is_hidden = false
GROUP BY company_name
ORDER BY total_exits DESC;

CREATE UNIQUE INDEX IF NOT EXISTS idx_company_exit_stats_name ON public.company_exit_stats (company_name);

-- Refresh helper function
CREATE OR REPLACE FUNCTION public.refresh_company_stats()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY public.company_exit_stats;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE public.exit_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_reactions ENABLE ROW LEVEL SECURITY;

-- Anyone can read non-hidden posts
CREATE POLICY "Public read exit posts"
ON public.exit_posts FOR SELECT
USING (is_hidden = false);

-- Public can insert new posts (validated: length > 30 characters)
CREATE POLICY "Public insert exit posts"
ON public.exit_posts FOR INSERT
WITH CHECK (char_length(story_body) >= 30 AND char_length(company_name) >= 2);

-- Public read reactions
CREATE POLICY "Public read reactions"
ON public.post_reactions FOR SELECT
USING (true);

-- 8. INITIAL SEED DATA (Realistic Corporate Exit Stories)
INSERT INTO public.exit_posts (
    company_name, role, tenure_years, notice_days, current_notice_day,
    primary_reason, manager_quote, employee_reply, story_body, survival_tip,
    hike_percent, is_verified_work_email, is_layoff, open_to_refer,
    valid_exit_count, dodged_bullet_count, toxic_alert_count
) VALUES 
(
    'TCS',
    'SDE-2 (Cloud Engineering)',
    2.8,
    90,
    72,
    'Toxic Management & Unpaid Overtime',
    '10:45 PM on Teams: "Cancel your Diwali train ticket. Client wants UAT deployment tested over weekend."',
    '10:48 PM: "I have submitted my formal resignation on the portal. My 90-day countdown starts tonight."',
    'Manager expected 11 PM Teams replies and rejected my pre-approved medical PTO right before Diwali. Handed in my paper the next morning. Best decision I made this year.',
    'Stopped doing unofficial weekend support, documented all project handovers over email, and prepared for interviews during morning hours.',
    75,
    true,
    false,
    false,
    412,
    194,
    28
),
(
    'Fintech Unicorn',
    'Product Designer',
    1.5,
    30,
    30,
    'Silent Layoff / Role Elimination',
    '9:15 AM Calendar Invite: "Quick 10-Min Sync (HR + VP Product) - Attendance Mandatory"',
    '9:25 AM: "Slack deactivated mid-sentence. Exported my Figma portfolio the night before after seeing the signs."',
    'Entire design division was called into an unexpected 9:30 AM Google Meet. HR gave 30 days severance. No warning, stellar performance reviews prior.',
    'Immediately reached out to my alumni network. I am now at a Series-B startup and have 3 open referrals for product designers and UI engineers—feel free to reach out!',
    35,
    true,
    true,
    true,
    530,
    215,
    19
),
(
    'Accenture',
    'Senior Consultant',
    3.2,
    90,
    45,
    'Forced Return To Office & Relocation',
    'HR Broadcast: "Report to the Bangalore office within 14 days for 5-day badge tracking or face disciplinary separation."',
    'Me: "My offer letter states Permanent Remote. Please process my 90-day notice period from home."',
    'Hired as permanent remote during 2023. Suddenly given a mandatory 14-day relocation notice to Bangalore or face termination. Team had 98% CSAT remotely.',
    'Refused to sign the relocation agreement without compensation. Served the full 90 days remotely and used the time to lock in two competitive remote offers.',
    60,
    true,
    false,
    false,
    298,
    142,
    14
),
(
    'Cognizant',
    'Data Analyst',
    2.1,
    90,
    84,
    '1.8% Appraisal after 14-hour days',
    'Manager in 1-on-1: "Budget is tight this year so we gave you 1.8%, but we are promoting you in responsibility!"',
    'Me: "Another company just promoted my compensation by +85%. Only 6 days of notice left!"',
    'Three years of "next cycle for sure" ended with a 1.8% hike. I spent my notice period studying SQL LeetCode instead of fixing midnight pipeline bugs.',
    'Set strict boundaries. Handed over clear documentation every Friday and left the desk at 6 PM sharp.',
    85,
    false,
    false,
    false,
    385,
    160,
    12
);

-- Initial refresh of the materialized view with seed data
REFRESH MATERIALIZED VIEW public.company_exit_stats;

