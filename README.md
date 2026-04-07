# JellyStream Search

A Disney+ inspired visual search plugin for Jellyfin that replaces the default text-based search suggestions with a rich, browsable media experience.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Jellyfin](https://img.shields.io/badge/Jellyfin-10.9%2B-blueviolet)

## Features

- **Visual genre rows** — All your server media organized by genre in horizontal scroll rows
- **Landscape cards** — Wide 16:9 backdrop cards with hover effects, play icons, and text overlays
- **Live search** — Visual card results as you type, split into Movies and Series
- **Browse by Genre pills** — Click any genre to scroll to its row or load it on demand
- **Continue Watching & Recently Added** — Featured rows at the top
- **Custom search bar** — Full-width Disney+ style search input with auto-focus
- **Abyss theme compatible** — Styled to match the Abyss Jellyfin theme out of the box
- **Cached landing** — Returns to the search page are instant after first load
- **Progressive loading** — Genre rows load in batches so the page stays responsive

## Screenshots

*Coming soon*

## Requirements

- Jellyfin 10.9 or later
- Docker-based Jellyfin installation
- SSH access to your server

## Installation

### Quick Install (non-persistent)

This method is fast but the patch will be lost when the Jellyfin Docker image is updated.

**1.** Download `jellystream-search.js` and `install-search-plugin.sh` to your server:

```bash
mkdir -p ~/jellystream
cd ~/jellystream
wget https://raw.githubusercontent.com/Jenari-Dev/jellystream-search/main/jellystream-search.js
wget https://raw.githubusercontent.com/Jenari-Dev/jellystream-search/main/install-search-plugin.sh
chmod +x install-search-plugin.sh
```

**2.** Run the install script:

```bash
./install-search-plugin.sh
```

> **Note:** If your Jellyfin container has a different name than `jellyfin`, edit the `CONTAINER_NAME` variable at the top of the script before running.

**3.** Hard refresh your browser (`Ctrl+Shift+R`) and navigate to the search page.

---

### Persistent Install (survives updates)

This method uses a custom Docker entrypoint that patches Jellyfin automatically on every container start, including after image updates.

**1.** Download all three files to your server:

```bash
mkdir -p ~/jellystream
cd ~/jellystream
wget https://raw.githubusercontent.com/Jenari-Dev/jellystream-search/main/jellystream-search.js
wget https://raw.githubusercontent.com/Jenari-Dev/jellystream-search/main/jellystream-entrypoint.sh
chmod +x jellystream-entrypoint.sh
```

**2.** Stop and remove your current Jellyfin container:

```bash
docker stop jellyfin
docker rm jellyfin
```

> **Your config, cache, and media are stored on volumes and will NOT be deleted.**

**3.** Recreate the container with the entrypoint and plugin mounted:

```bash
docker run -d \
  --name jellyfin \
  --restart unless-stopped \
  -p 8096:8096 \
  -v /path/to/config:/config \
  -v /path/to/cache:/cache \
  -v /path/to/media:/media \
  -v ~/jellystream/jellystream-search.js:/jellystream-search.js:ro \
  -v ~/jellystream/jellystream-entrypoint.sh:/jellystream-entrypoint.sh:ro \
  --entrypoint /jellystream-entrypoint.sh \
  jellyfin/jellyfin
```

> **Replace** `/path/to/config`, `/path/to/cache`, and `/path/to/media` with your actual volume paths. Check your existing paths with `docker inspect jellyfin --format '{{json .HostConfig.Binds}}'` before removing the container.

**4.** Verify the patch applied:

```bash
docker logs jellyfin | head -15
```

You should see:

```
=========================================
 JellyStream Search — Auto Patcher
=========================================
[✓] Copied jellystream-search.js to web root
[✓] Patched index.html with script tag
=========================================
 Starting Jellyfin...
=========================================
```

**5.** Hard refresh your browser (`Ctrl+Shift+R`) and navigate to the search page.

---

### Docker Compose

If you use Docker Compose, add the following to your `docker-compose.yml`:

```yaml
services:
  jellyfin:
    image: jellyfin/jellyfin
    container_name: jellyfin
    restart: unless-stopped
    entrypoint: /jellystream-entrypoint.sh
    ports:
      - 8096:8096
    volumes:
      - /path/to/config:/config
      - /path/to/cache:/cache
      - /path/to/media:/media
      - ~/jellystream/jellystream-search.js:/jellystream-search.js:ro
      - ~/jellystream/jellystream-entrypoint.sh:/jellystream-entrypoint.sh:ro
```

Then run:

```bash
docker compose up -d
```

## Updating the Plugin

To update to a newer version of JellyStream Search:

```bash
cd ~/jellystream
wget -O jellystream-search.js https://raw.githubusercontent.com/Jenari-Dev/jellystream-search/main/jellystream-search.js
docker restart jellyfin
```

Then hard refresh your browser.

## Updating Jellyfin

With the persistent install, updating Jellyfin is the same as usual:

```bash
docker pull jellyfin/jellyfin
docker stop jellyfin
docker rm jellyfin
# Re-run your docker run command from Step 3 above
```

The entrypoint script will automatically re-patch the new Jellyfin version on startup.

## Customization

Edit the `CONFIG` object at the top of `jellystream-search.js`:

| Option | Default | Description |
|--------|---------|-------------|
| `searchDelay` | `300` | Debounce delay in ms before live search triggers |
| `minSearchChars` | `2` | Minimum characters before search starts |
| `genreRowLimit` | `20` | Number of items per genre row |
| `maxGenreRows` | `30` | Maximum number of genre rows to load |

## How It Works

JellyStream Search is a client-side JavaScript plugin that hooks into Jellyfin's web interface. It:

1. Detects when you navigate to the search page (Jellyfin is a single-page app)
2. Hides the default text-based search suggestions
3. Creates a custom search bar and content container
4. Fetches your library data via Jellyfin's REST API using your existing auth token
5. Renders visual card grids organized by genre with horizontal scrolling
6. Provides live search results as you type, split into Movies and Series categories

No server-side modifications are made beyond injecting a `<script>` tag into `index.html`.

## Compatibility

- **Jellyfin:** 10.9.x, 10.10.x, 10.11.x
- **Themes:** Tested with Abyss theme. Should work with any theme — the plugin uses its own scoped CSS classes
- **Browsers:** Chrome, Firefox, Edge, Safari

## Uninstalling

### Quick Install

Restart or recreate your Jellyfin container without running the install script. The patch will be gone.

### Persistent Install

Remove the entrypoint and volume mounts from your `docker run` command or `docker-compose.yml`, then recreate the container:

```bash
docker stop jellyfin
docker rm jellyfin
# Re-run docker run without the --entrypoint and jellystream volume lines
```

## Credits

- **Author:** [Kain (jenariskywalker / Jenari-Dev)](https://github.com/Jenari-Dev)
- **Inspired by:** Disney+ and Netflix search interfaces
- **Built for:** The Jellyfin community

## License

MIT — see [LICENSE](LICENSE) for details.
