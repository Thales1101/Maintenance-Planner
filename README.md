# Maintenance Planner · WEIG Terminal

A web and mobile app for planning and recording maintenance at WEIG Terminal: belt conveyors, warehouses, structures and equipment. It covers both scheduled (PM) and unscheduled work.

## Features

- **Site plan:** upload your general layout as a PDF or image (always shown in landscape, halftone grayscale with grid lines) and place work-order pins on it. You can filter by status, including In progress.
- **Equipment register:** each item can have its own PDF drawing, with a pin for each work order on that drawing.
- **Work orders:** priority, due date and time, man-hours (hours + minutes) and materials. An order is locked once it is Done.
- **Planned maintenance:** recurring PM plans, plus import from **Microsoft Project** (XML or CSV).
- **Responsible people:** a person can be assigned to orders and set as edit or view-only. Signatures are captured on screen after completion.
- **PDF reports:** one report per order (including comments and signatures) and a general dashboard report.
- **Languages:** English, Georgian and Russian.
- **Phones:** layout optimised for mobile.

## Two ways to run it

| | Inside Claude (artifact) | Standalone (GitHub Pages / any web server) |
|---|---|---|
| Data | Shared by the whole team, live | Saved in **this browser on this device only** |
| Sign-in, access levels per account | Yes | No: everyone using the device can edit |
| In-app notifications to colleagues | Yes | No |
| Automatic translation of team-written text | Yes | No (the interface is still translated) |
| Backup | — | **Settings → Export backup / Import backup** (JSON, includes drawings and photos) |

The same `index.html` works in both modes. It switches to standalone mode automatically when it is not running inside Claude.

## Publish on GitHub Pages

1. Create a new repository on GitHub, for example `maintenance-planner`. A **private** repo is recommended.
2. Click **Add file → Upload files** and drag in *everything in this folder*, keeping the `fonts/` and `samples/` folders. Commit.
3. Go to **Settings → Pages**. Under *Build and deployment* choose **Deploy from a branch**, select `main` and `/ (root)`, then click **Save**.
4. After about a minute the app is live at `https://<your-user>.github.io/maintenance-planner/`.

> GitHub Pages sites are public even if the repository is private, unless you have GitHub Enterprise. This is safe because the data never leaves the user's browser. Still, anyone with the address can open an empty copy of the app.

## Run locally

Opening `index.html` by double-clicking works, but PDF reports need the fonts, which browsers block on `file://`. Serve the folder instead:

```bash
python3 -m http.server 8000
# then open http://localhost:8000
```

## Moving data between devices

On the old device go to **Settings → Export backup**. On the new device go to **Settings → Import backup** and select the file. Importing merges records with the same id and replaces existing ones.

## Microsoft Project import

Save the plan from MS Project as **XML** (*File → Save As → XML Format*) or export a CSV. `.mpp` files cannot be read directly. Example files are in `samples/`.

## Structure

```
index.html              the whole app (HTML, CSS, JavaScript in one file)
fonts/                  DejaVu Sans subsets used in PDF reports (Latin, Cyrillic, Georgian)
fonts/LICENSE-DejaVu.txt
samples/                example MS Project XML and CSV files
.nojekyll               tells GitHub Pages to serve files as-is
```

External code loaded at runtime: **pdf.js 3.11.174** from cdnjs. It is only needed to read uploaded PDF drawings or layouts.

## Licence

The fonts are DejaVu (free licence, see `fonts/LICENSE-DejaVu.txt`). Add your own licence for the app code if you want one. For internal company use, "All rights reserved" is fine.
