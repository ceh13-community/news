# news.rozoom.app

Hugo site behind Caddy on the rozoom.app box. Five languages: EN (default), DE, FR, IT, UK.

## Local

```bash
hugo server -D            # drafts included, http://localhost:1313
hugo --gc --minify        # production build into public/
```

Hugo extended 0.168.0 or newer is required (the theme uses SCSS). The theme is a git submodule:

```bash
git submodule update --init --recursive
```

## Layout

- `content/<section>/<slug>.<lang>.md` posts, sections: `self-hosting`, `kubernetes`, `switzerland`, `voice-ai`
- `content/<page>.<lang>.md` standalone pages: about, privacy, affiliate-disclosure, contact
- `layouts/_partials/extend_head.html` hreflang x-default, FAQ schema, analytics hook
- `layouts/_partials/extend_footer.html` newsletter block and shared CSS
- `layouts/_partials/templates/schema_json.html` theme copy, patched to emit the article author
- `layouts/_shortcodes/` `aff`, `cta`, `disclosure`
- `i18n/<lang>.toml` UI strings, including the affiliate disclosure text

## Affiliate links

Never link a partner directly. Use the shortcodes, which point at `/go/<program>/` and carry
`rel="sponsored nofollow"`:

```markdown
{{< disclosure >}}
{{< aff program="hetzner" text="Hetzner Cloud" >}}
{{< cta program="infomaniak" title="Infomaniak" >}}Why it fits here.{{< /cta >}}
```

`/go/<program>/` is a 302 redirect defined in the Caddyfile on the server, so a changed partner URL
or tracking parameter is one Caddy reload, not a site rebuild.

## Deploy

Push to `main`. The workflow builds, refuses an empty build, rsyncs `public/` to the box and smoke
tests the live URLs. Secrets: `DEPLOY_HOST`, `DEPLOY_USER`, `DEPLOY_PATH`, `DEPLOY_SSH_KEY`,
`DEPLOY_KNOWN_HOSTS`.
