-- Enable pgcrypto for gen_random_uuid()
create extension if not exists "pgcrypto";

-- SUBJECTS
create table subjects (
 id uuid primary key default gen_random_uuid(),
 user_id uuid references auth.users not null default auth.uid(),
 name text not null,
 exam_date date,
 created_at timestamp with time zone default now()
);

-- CHAPTERS
create table chapters (
 id uuid primary key default gen_random_uuid(),
 user_id uuid references auth.users not null default auth.uid(),
 subject_id uuid references subjects on delete cascade not null,
 name text not null,
 first_studied_at timestamp with time zone,
 stage integer default 0 check (stage between 0 and 5),
 next_review_at timestamp with time zone,
 created_at timestamp with time zone default now()
);

-- REVIEWS
create table reviews (
 id uuid primary key default gen_random_uuid(),
 user_id uuid references auth.users not null default auth.uid(),
 chapter_id uuid references chapters on delete cascade not null,
 reviewed_at timestamp with time zone default now(),
 rating text check (rating in ('easy', 'medium', 'hard')) not null
);

-- TASKS
create table tasks (
 id uuid primary key default gen_random_uuid(),
 user_id uuid references auth.users not null default auth.uid(),
 title text not null,
 due_date date,
 status text default 'open' check (status in ('open', 'done', 'postponed')),
 type text default 'normal' check (type in ('normal', 'study')),
 subject_id uuid references subjects on delete set null,
 repeat text default 'none' check (repeat in ('none', 'daily', 'weekly')),
 planned_minutes integer,
 actual_seconds integer default 0,
 created_at timestamp with time zone default now(),
 done_at timestamp with time zone
);

-- ROW LEVEL SECURITY
alter table subjects enable row level security;
alter table chapters enable row level security;
alter table reviews enable row level security;
alter table tasks enable row level security;

-- POLICIES (SELECT, INSERT, UPDATE, DELETE) for user isolation
-- SUBJECTS
create policy "subjects: select own" on subjects for select using (user_id = auth.uid());
create policy "subjects: insert own" on subjects for insert with check (user_id = auth.uid());
create policy "subjects: update own" on subjects for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "subjects: delete own" on subjects for delete using (user_id = auth.uid());

-- CHAPTERS
create policy "chapters: select own" on chapters for select using (user_id = auth.uid());
create policy "chapters: insert own" on chapters for insert with check (user_id = auth.uid());
create policy "chapters: update own" on chapters for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "chapters: delete own" on chapters for delete using (user_id = auth.uid());

-- REVIEWS
create policy "reviews: select own" on reviews for select using (user_id = auth.uid());
create policy "reviews: insert own" on reviews for insert with check (user_id = auth.uid());
create policy "reviews: update own" on reviews for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "reviews: delete own" on reviews for delete using (user_id = auth.uid());

-- TASKS
create policy "tasks: select own" on tasks for select using (user_id = auth.uid());
create policy "tasks: insert own" on tasks for insert with check (user_id = auth.uid());
create policy "tasks: update own" on tasks for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "tasks: delete own" on tasks for delete using (user_id = auth.uid());

-- INDEXES
create index tasks_user_due on tasks (user_id, due_date);
create index chapters_user_next on chapters (user_id, next_review_at);