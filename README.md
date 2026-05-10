# 🎟️ FrontRow

FrontRow is a modern web application built with **SvelteKit** (Svelte 5) and **Tailwind CSS**, powered by a local **Supabase** backend. It features passwordless email authentication and a PostgreSQL database to track users, venues, and saved concerts.

## 📋 Prerequisites

Before you begin, ensure you have the following installed on your machine:

- **[Node.js](https://nodejs.org/)** (v18 or higher recommended)
- **[Docker Desktop](https://www.docker.com/products/docker-desktop)** (Must be running to start the local database)
- **Git**

---

## 🚀 Getting Started

### 1. Install Dependencies

Clone the repository and install the frontend packages:
`npm install`

### 2. Start the Local Backend (Supabase)

Make sure Docker Desktop is open and running in the background. Then, start the local Supabase environment:
`npx supabase start`

_Note: The first time you run this, it may take a few minutes to download the necessary Docker images. It will automatically apply the database migrations located in `supabase/migrations/`._

### 3. Set Up Environment Variables

Once Supabase starts, it will print your local credentials in the terminal. Create a `.env` file in the root of the project and add your local keys:

PUBLIC_SUPABASE_URL="http://127.0.0.1:54321"
PUBLIC_SUPABASE_ANON_KEY="your-local-anon-key"

_(Replace the anon key with the one printed in your terminal!)_

### 4. Start the Frontend Server

Run the SvelteKit development server:
`npm run dev`

---

## 🗺️ Local Services Directory

When the Supabase backend and Svelte dev server are running, you can access your tools at these local URLs:

| Service                   | URL                      | Description                                                                                                                       |
| :------------------------ | :----------------------- | :-------------------------------------------------------------------------------------------------------------------------------- |
| **FrontRow App**          | `http://localhost:5173`  | Your live Svelte application.                                                                                                     |
| **Supabase Studio**       | `http://127.0.0.1:54323` | Your local database dashboard. Use the "Table Editor" to view your tables.                                                        |
| **Mailpit (Local Email)** | `http://127.0.0.1:54324` | Local email catcher. All Magic Links and OTP codes sent during local development will appear here instead of sending real emails. |
| **API Endpoint**          | `http://127.0.0.1:54321` | The underlying REST API for your Postgres database.                                                                               |

---

## 🛠️ Database Management Workflow

Your database schema is version-controlled using Supabase Migrations.

**To stop the backend when you are done working:**
`npx supabase stop`

**To completely wipe the database and restart fresh:**
_(This will destroy local data and re-run all your `.sql` migration files)_
`npx supabase db reset`

**To create a new database migration:**
`npx supabase migration new my_new_feature`

This will create a new `.sql` file in `supabase/migrations/` where you can write your table changes before running `npx supabase db reset` to apply them.
