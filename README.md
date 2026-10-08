# Maintenance Planner · WEIG Terminal

A web and mobile app for planning and recording maintenance at WEIG Terminal: belt conveyors, warehouses, structures and equipment. It covers both scheduled (PM) and unscheduled work.

## Features

- **Site plan:** upload your general layout as a PDF or image (always shown in landscape, halftone grayscale with grid lines) and place work-order pins on it. You can filter by status, including In progress.
- **Equipment register:** each item can have its own PDF drawing, with a pin for each work order on that drawing.
- **Work orders:** priority, due date and time, man-hours (hours + minutes) and materials. An order is locked once it is Done.
- **Planned maintenance:** recurring PM plans, plus import from **Microsoft Project** (XML or CSV).
- **Responsible people:** a person can be assigned to orders and set as edit or view-only. Signatures are captured on screen after completion.
- **Notifications:** a person gets an in-app notification when assigned as responsible person or approver, and a reminder to sign.
- **PDF reports:** one report per order (including comments and signatures) and a general dashboard report.
- **Languages:** English, Georgian and Russian.
- **Phones:** layout optimised for mobile.

## How data is stored

`index.html` picks one of three modes on its own:

| Mode | When | Data |
|---|---|---|
| **Shared server** (recommended) | `config.js` contains your Supabase details | One shared database for the whole team, live updates, sign-in with email and password, access enforced by the server |
| Single device | `config.js` is empty | Saved only in the browser you use. Nothing is shared between computers |
| Inside Claude | Opened as a Claude artifact | Claude's own shared storage |

The code is plain HTML, CSS and JavaScript in one file. There is nothing to build or install.

---

## Setup with a shared server (Supabase)

Supabase is a hosted database service. The free plan is enough for a team this size (500 MB database, 1 GB files).

### 1. Create the Supabase project
1. Go to <https://supabase.com>, sign up, and click **New project**.
2. Name it `maintenance-planner`, set a strong database password (save it somewhere safe), choose the region **Central EU (Frankfurt)**, then click **Create**. Wait about 2 minutes.

### 2. Create the tables and access rules
1. In Supabase, open **SQL Editor → New query**. Paste the **entire contents** of `supabase-setup.sql` (open it in Notepad, press Ctrl+A, then Ctrl+C) and click **Run**. It should end with "Success. No rows returned".
2. Make yourself administrator. Open another **New query**, paste this line with your own sign-in email between the quotes, and click **Run**:
   ```sql
   insert into public.app_admins (email) values (lower('your.name@weig-bft.com'));
   ```

### 3. Lock down sign-up and create accounts
1. Go to **Authentication → Sign In / Providers**, switch off **Allow new users to sign up**, and save. Only people you add can then get in.
2. Go to **Authentication → Users → Add user → Create new user**. Enter an email and password and tick **Auto Confirm User**. Do this for yourself first, using the same email you made administrator, and then for each colleague.

### 4. Connect the app
1. In Supabase, open **Project Settings → API Keys** (or **Data API**). Copy the **Project URL** and the **anon / publishable** key.
2. Open `config.js` and paste both values between the quotes. **Never** use the `service_role` or secret key.

### 5. Publish on GitHub Pages
1. Create a repository on GitHub (on a free account it must be **Public**).
2. **Add file → Upload files** → drag in everything in this folder, including `config.js`, `fonts/` and `samples/`. Click **Commit changes**.
3. **Settings → Pages →** Deploy from a branch → `main` / `(root)` → **Save**. After 1–2 minutes the app is at `https://<your-user>.github.io/<repo>/`.

### 6. Load your existing data and give access
1. Open the app and sign in as the administrator.
2. **Settings → Backup → Import backup**. Choose `maintenance-planner-backup-part1-of-3.json`, then part 2, then part 3. Wait for "Backup imported" each time.
3. Open **People**. For each person, enter **the same email they sign in with** and set their access to **Can create and edit** or **View only**.
4. Send each colleague the app address and their password. They can change it under **Settings → Your account → Change password**.

### Who can do what
- **Administrator** (email in `app_admins`): everything.
- **Editors**: signed-in users whose email appears in People with *Can create and edit* and who are active.
- **Everyone else who signs in**: view only. They can still read everything and mark their own notifications as read.
- **Not signed in**: nothing, not even reading.

The server enforces these rules, not just the app's screens. To add another administrator, run this in the SQL Editor:
```sql
insert into public.app_admins (email) values (lower('name@weig-bft.com'));
```

### Good to know
- **Security:** the Supabase URL and anon key in `config.js` are public by design. Your data is protected by sign-in and the server rules. A public GitHub repository shows the code but not your data.
- **Free plan pausing:** Supabase pauses a free project after about a week with no activity. Daily use keeps it awake. If it does pause, click **Restore** in the Supabase dashboard; no data is lost.
- **Backups:** **Settings → Backup → Export backup** downloads everything, drawings included, as one file. Do this regularly.
- **Not available outside Claude:** automatic translation of text your team writes. Translations already made in Claude are kept.

---

## Run locally (for testing)

PDF reports need the fonts, which browsers block when you open the file directly from disk (`file://`). Serve the folder instead:

```bash
python3 -m http.server 8000
# then open http://localhost:8000
```

## Microsoft Project import

Save the plan from MS Project as **XML** (*File → Save As → XML Format*) or export a CSV. `.mpp` files cannot be read directly. Example files are in `samples/`.

## Structure

```
index.html              the whole app (HTML, CSS, JavaScript in one file)
config.js               your Supabase URL and public key (empty = single-device mode)
supabase-setup.sql      run once in Supabase: tables, access rules, file storage
fonts/                  DejaVu Sans subsets used in PDF reports (Latin, Cyrillic, Georgian)
fonts/LICENSE-DejaVu.txt
samples/                example MS Project XML and CSV files
.nojekyll               tells GitHub Pages to serve files as-is
```

External code loaded at runtime from jsDelivr / cdnjs:
- **supabase-js 2.100.1**, only when `config.js` is filled in
- **pdf.js 3.11.174**, only to read uploaded PDF drawings or layouts

## Licence

The fonts are DejaVu (free licence, see `fonts/LICENSE-DejaVu.txt`). Add your own licence for the app code if you want one. For internal company use, "All rights reserved" is fine.
