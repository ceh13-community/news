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

## Known trap

The Caddy container bind-mounts the Caddyfile as a single file and was started three months ago.
The inode it holds no longer matches `/home/ubuntu/stack/Caddyfile`, so `caddy reload` against
`/etc/caddy/Caddyfile` reads a stale copy. Until the container is recreated, config changes have to
be pushed in with:

```bash
docker cp /home/ubuntu/stack/Caddyfile caddy:/tmp/Caddyfile.new
docker exec caddy caddy validate --adapter caddyfile --config /tmp/Caddyfile.new
docker exec caddy caddy reload  --adapter caddyfile --config /tmp/Caddyfile.new
```

A container restart would fall back to the stale file and drop the `news.rozoom.app` block. The
permanent fix is to recreate the caddy container once with the directory mounted instead of the
single file (`./caddy:/etc/caddy`), which costs a few seconds of downtime for the other three
hostnames.
