CONTEXT_ROOT="$1"
CONTEXT_PATH="$2"
CLOUDFLARE_ZONE_ID="$3"
CLOUDFLARE_CACHE_TOKEN="$4"

SSH_PRIVATE_KEY_PATH="$HOME/.ssh/${GITHUB_REPOSITORY:-publish-docs}"

if [ "$#" -ne 4 ]; then
  echo -e "not enough arguments USAGE:\n\n$0 \$CONTEXT_ROOT \$CONTEXT_PATH \$CLOUDFLARE_ZONE_ID \$CLOUDFLARE_CACHE_TOKEN\n\n" >&2
  exit 1
fi

CONTEXT="${CONTEXT_ROOT}${CONTEXT_PATH}"

curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
     -H "Authorization: Bearer $CLOUDFLARE_CACHE_TOKEN" \
     -H "Content-Type:application/json"

curl -v -X POST "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/purge_cache" \
      -H "Content-Type:application/json" -H "Authorization: Bearer $CLOUDFLARE_CACHE_TOKEN" \
      --data "{\"prefixes\":[\"docs.spring.io/${CONTEXT}\"]}"