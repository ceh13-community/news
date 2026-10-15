# Server side

The site is static files served by nginx behind the Caddy that already terminates TLS for
`tax`, `box` and `kostik` on the same box (Hetzner cx23, `5.75.187.208`).

- `/home/ubuntu/stack/news` rsync target, bind-mounted read-only into the `news-web` container
- `news-web` service in `/home/ubuntu/stack/docker-compose.yml` (`nginx:alpine`, no published ports)
- `caddy-news.snippet` the live `news.rozoom.app` block from `/home/ubuntu/stack/Caddyfile`,
  including the `/go/<program>` affiliate redirects and the cache headers
- DNS `news.rozoom.app A 5.75.187.208`, Route53 zone `Z10158072EXOSAI897NOU`

The deploy key is restricted on the box to `command="/usr/bin/rrsync -wo /home/ubuntu/stack/news"`,
so it can only write into that one directory: no shell, no reads, no port forwarding.

## Caddy config lives in a directory now

Config is `/home/ubuntu/stack/caddy/Caddyfile`, mounted as `./caddy:/etc/caddy:ro`:

```bash
docker exec caddy caddy validate --adapter caddyfile --config /etc/caddy/Caddyfile
docker exec caddy caddy reload   --adapter caddyfile --config /etc/caddy/Caddyfile
```

It used to be a single-file bind mount, which pinned an inode that later edits replaced, so reloads
silently read a stale copy and answered "config is unchanged". If a Caddy edit ever appears to do
nothing, compare `stat -c %i` on the file inside and outside the container before suspecting the
config itself.

## Analytics

Self-hosted Umami at `https://stats.rozoom.app`, same compose stack (`umami` + `umami-db`,
postgres 17). The tracking script is wired through `params.umamiScriptUrl` and
`params.umamiWebsiteId` in `hugo.toml`; the website id is public by design, the admin credentials
are not in this repo.
