-- 1. Turn on the locks for all tables
ALTER TABLE "venues" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "concerts" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "user" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "user_concerts" ENABLE ROW LEVEL SECURITY;

-- 2. Venues & Concerts: Anyone (even logged-out guests) can read them, but nobody can edit them via the public API
CREATE POLICY "Venues are viewable by everyone" ON "venues" FOR SELECT USING (true);
CREATE POLICY "Concerts are viewable by everyone" ON "concerts" FOR SELECT USING (true);

-- 3. Users: Logged-in users can only read and update their OWN profile data
CREATE POLICY "Users can manage their own profile" ON "user" FOR ALL USING (auth.uid() = id);

-- 4. User Concerts (Saved List): Users can only see, save, or unsave their OWN tickets
CREATE POLICY "Users can manage their own saved concerts" ON "user_concerts" FOR ALL USING (auth.uid() = user_id);