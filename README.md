# Berry Blast

anandamide.ks

A private cycle tracker that installs to a phone's home screen and works offline.
Each person's log is stored on their own phone. Partner sharing is optional: when someone turns it on, only the categories they tick are copied to an online database so the partners they invite can see them, read-only.

## Files

- `index.html` – the whole app
- `config.js` – your Supabase settings for partner sharing (see below)
- `supabase.js` – the Supabase library, kept here so the app works offline
- `setup.sql` – database setup for partner sharing (run once in Supabase; it doesn't need to be on GitHub, but it does no harm there)
- `manifest.webmanifest`, `sw.js` – installing and offline use
- `icon-192.png`, `icon-512.png`, `icon-maskable-512.png`, `apple-touch-icon.png` – app icons

Upload every file to the top level of the GitHub repository, replacing old copies.

## Setting up partner sharing (once, about 15 minutes)

Until `config.js` is filled in, the app works as before and the partner-sharing section stays hidden.

1. **Create a Supabase project.** Sign up free at supabase.com, click **New project**, name it `berry-blast`, choose a database password (save it somewhere), and pick the region closest to you (Mumbai for India). Wait a couple of minutes for it to finish.
2. **Create the tables.** In the project, open **SQL Editor**, click **New query**, paste the whole of `setup.sql`, and click **Run**. It should say "Success. No rows returned".
3. **Tell Supabase where the app lives.** Open **Authentication → URL Configuration**.
   - Set **Site URL** to `https://anandamide-ks.github.io/berry-blast/`
   - Under **Redirect URLs**, add `https://anandamide-ks.github.io/berry-blast/**`
   - Save.
4. **Copy two values into `config.js`.**
   - **Project URL**: click **Connect** at the top of the project (or Settings → Data API). It looks like `https://abcdefgh.supabase.co`.
   - **Publishable key**: Settings → API Keys. Copy the key starting `sb_publishable_` (or the older "anon public" key).
   - Paste both between the quotes in `config.js`. Never use the "secret" or "service_role" key here.
5. **Upload** `config.js` (and any other changed files) to the GitHub repository.

Both values in `config.js` are meant to be public. What keeps the data private is the access rules created by `setup.sql`: people see only their own share, and a partner sees someone's share only after redeeming an invite code that person made.

## How people use it

- **Sharing your cycle:** Partner sharing → sign in or create an account → tick "Share with partners I invite" → choose a name and what to share → **Create invite code** and send the code to your partner. Codes work once and expire after 24 hours.
- **Seeing a partner's cycle:** sign in → type their code under "See a partner's cycle" → **Join**. A tab with their name appears at the top.
- **Ending access:** the person sharing can **Remove** anyone; a partner can **Leave**. Unticking "Share with partners I invite" deletes the online copy.

New accounts get a confirmation email. On iPhone, the link opens in Safari; after confirming, go back to the installed app and sign in there.

## Things to know

- **Free-plan pausing:** Supabase pauses a free project after a week with too little activity. If sharing stops working after a quiet spell, open the project in the Supabase dashboard and click **Resume project**. Everyone's own logs keep working regardless.
- **Backups:** each person's own log lives only on their phone. Under **Settings and data**, use **Download backup** now and then. Uninstalling the app or clearing the browser's site data erases the log.

## Updating the app

When you change `index.html` or `config.js`, also change `VERSION` at the top of `sw.js` (for example to `berry-blast-v5`) so installed copies pick up the new version.
