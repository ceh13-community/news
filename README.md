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

- `content/<section>/<slug>.<lang>.md` posts, sections: `self-hosting`, `kubernetes`, `cloud`, `voice-ai`
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

`DEPLOY_PATH` is `/`: the deploy key on the box is restricted to
`rrsync -wo /home/ubuntu/stack/news`, so the remote path is relative to that directory and the key
cannot read anything or open a shell.

## Ads

Google AdSense is wired but switched off: with `params.adsenseClient` empty the site ships no
Google code at all, verified in the built HTML. Turning ads on, in order:

1. Apply for AdSense with this domain. Expect a rejection while the blog has no real articles, so
   apply after the first batch is published.
2. Put the publisher id in `params.adsenseClient` (`ca-pub-...`) and the unit ids in
   `params.adsenseSlotInArticle` / `params.adsenseSlotBelowPost`.
3. Serve `ads.txt` from the site root:
   `echo 'google.com, pub-XXXXXXXXXXXXXXXX, DIRECT, f08c47fec0942fa0' > static/ads.txt`
4. Enable the consent message in AdSense (Privacy and messaging). It is a Google-certified CMP and
   is required wherever consent law applies; the loader script pulls it in, nothing extra goes here.

Placement rules enforced in the templates, not left to discipline:

- `{{< ad >}}` places an in-article unit; a unit also renders after the post body when
  `adsenseSlotBelowPost` is set.
- At most `params.adsenseMaxPerPost` units per page (3 by default). Extra units are dropped at build
  time with a warning instead of silently stacking up.
- No ads on the pages in `params.adsenseExcludeSlugs`: about, privacy, affiliate disclosure, contact.
- Never place `{{< ad >}}` inside or directly between code blocks: it breaks reading flow and is the
  fastest way to a policy complaint.
- The privacy page carries `{{< ads-notice >}}`, which prints the advertising paragraph only while
  an ad client is configured, so the page cannot describe ads that do not run, or stay silent about
  ads that do.
