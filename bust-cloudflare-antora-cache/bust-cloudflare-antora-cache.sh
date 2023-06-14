CONTEXT_ROOT="$1"
CLOUDFLARE_ZONE_ID="$2"
CLOUDFLARE_CACHE_TOKEN="$3"

SSH_PRIVATE_KEY_PATH="$HOME/.ssh/${GITHUB_REPOSITORY:-publish-docs}"

if [ "$#" -ne 3 ]; then
  echo -e "not enough arguments USAGE:\n\n$0 \$CONTEXT_ROOT \$CLOUDFLARE_ZONE_ID \$CLOUDFLARE_CACHE_TOKEN\n\n" >&2
  exit 1
fi

curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
     -H "Authorization: Bearer $CLOUDFLARE_CACHE_TOKEN" \
     -H "Content-Type:application/json"

curl -v -X POST "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/purge_cache" \
      -H "Content-Type:application/json" -H "Authorization: Bearer $CLOUDFLARE_CACHE_TOKEN" \
      --data '{"files":["https://docs.spring.io/$CONTEXT_ROOT/reference/_/js/site.js","https://docs.spring.io/$CONTEXT_ROOT/reference/_/js/vendor/docsearch.js","https://docs.spring.io/$CONTEXT_ROOT/reference/_/css/site.css","https://docs.spring.io/$CONTEXT_ROOT/reference/_/css/vendor/docsearch.css"]}'