-- 1. Create Base Tables
CREATE TABLE "venues"(
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "coordinates" geography NOT NULL,
    "created_at" TIMESTAMP(0) WITH TIME zone NOT NULL,
    "mapbox_id" TEXT NOT NULL
);
ALTER TABLE "venues" ADD PRIMARY KEY("id");

CREATE TABLE "concerts"(
    "id" UUID NOT NULL,
    "artist" TEXT NOT NULL,
    "venue" UUID NOT NULL,
    "date" TIMESTAMP(0) WITH TIME zone NOT NULL,
    "description" TEXT NULL,
    "name" TEXT NULL,
    "created_at" TIMESTAMP(0) WITH TIME zone NOT NULL,
    "image_url" TEXT NOT NULL,
    "updated_at" TIMESTAMP(0) WITH TIME zone NOT NULL
);
ALTER TABLE "concerts" ADD PRIMARY KEY("id");

CREATE TABLE "user"("id" UUID NOT NULL);
ALTER TABLE "user" ADD PRIMARY KEY("id");

CREATE TABLE "user_concerts"(
    "id" UUID NOT NULL,
    "concert_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "created_at" TIMESTAMP(0) WITH TIME zone NOT NULL,
    "status" TEXT NOT NULL,
    "updated_at" TIMESTAMP(0) WITH TIME zone NOT NULL
);
ALTER TABLE "user_concerts" ADD PRIMARY KEY("id");

-- 2. Add Foreign Keys & Unique Constraints
ALTER TABLE "user_concerts" ADD CONSTRAINT "user_concerts_user_id_concert_id_unique" UNIQUE("user_id", "concert_id");
ALTER TABLE "user_concerts" ADD CONSTRAINT "user_concerts_user_id_foreign" FOREIGN KEY("user_id") REFERENCES "user"("id");
ALTER TABLE "concerts" ADD CONSTRAINT "concerts_venue_foreign" FOREIGN KEY("venue") REFERENCES "venues"("id");
ALTER TABLE "user_concerts" ADD CONSTRAINT "user_concerts_concert_id_foreign" FOREIGN KEY("concert_id") REFERENCES "concerts"("id");

-- 3. Connect to Supabase Auth
ALTER TABLE "user" ADD CONSTRAINT "user_id_fkey" FOREIGN KEY ("id") REFERENCES auth.users("id") ON DELETE CASCADE;

-- 4. Add Performance Indexes (New!)
CREATE INDEX "idx_concerts_venue" ON "concerts"("venue");
CREATE INDEX "idx_user_concerts_user_id" ON "user_concerts"("user_id");
CREATE INDEX "idx_user_concerts_concert_id" ON "user_concerts"("concert_id");

-- 5. Set up the Supabase Auth Trigger (New!)
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public."user" (id)
  values (new.id);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();