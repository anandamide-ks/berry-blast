# Cycle Tracker (installable web app)

anandamide.ks

A private cycle tracker that installs to a phone's home screen and works offline.
All entries are stored on the device, in the browser's storage for this site. Nothing is sent anywhere.

## Files

- `index.html` – the whole app
- `manifest.webmanifest` – name, icons and colours for the installed app
- `sw.js` – offline cache
- `icons/` – app icons

## Put it online (GitHub Pages, free)

The app must be served over HTTPS for installing and offline use to work; opening `index.html` straight from a folder is not enough.

1. Create a GitHub account if you don't have one, then create a new **public** repository, for example `cycle-tracker`.
2. Upload everything in this folder to the repository, keeping the `icons` folder as a folder.
3. In the repository, open **Settings → Pages**, set the source to **Deploy from a branch**, pick the `main` branch and the `/ (root)` folder, and save.
4. After a minute or two the app is live at `https://<your-username>.github.io/cycle-tracker/`.

The repository holds only the app's code. Nobody's entries are ever in it.

## Install on a phone

- **iPhone:** open the link in Safari, tap Share, then **Add to Home Screen**.
- **Android:** open the link in Chrome, tap the menu, then **Install app** or **Add to Home screen**.

## Backups

Entries live only on that phone and browser. Under **Settings and data**:

- **Download backup** saves everything as a JSON file.
- **Restore from backup** loads such a file, replacing what is on the device.
- **Download CSV** gives a spreadsheet-friendly copy.

Uninstalling the app or clearing the browser's site data erases the log, so keep a backup.

## Updating the app

When you change `index.html`, also change `VERSION` at the top of `sw.js` (for example to `cycle-tracker-v2`), so installed copies pick up the new version.
