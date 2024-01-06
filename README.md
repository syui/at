## atproto in docker

|server|url|port|
|---|---|---|
|pds|https://github.com/bluesky-social/atproto/tree/main/services/pds|2583|
|appview|https://github.com/bluesky-social/atproto/tree/main/services/bsky|2584|
|plc|https://github.com/did-method-plc/did-method-plc/tree/main/packages/server|2582|
|bgs|https://github.com/bluesky-social/indigo/tree/main/cmd/bigsky|2470|

> .bsky.env

```sh
PORT=2584
PUBLIC_URL=example.com
DID_PLC_URL=plc.example.com
DB_PRIMARY_POSTGRES_URL="postgresql://postgres:password@localhost:5404/postgres"
REDIS_HOST="127.0.0.1:6379"
SERVER_DID=did:web:api.example.com
#SERVICE_SIGNING_KEY=xxx
#SERVER_DID=did:plc:xxx
```

> compose.yaml

```yaml
version: '3.9'

services:
  bsky_db:
    container_name: bsky_db
    restart: always
    image: postgres:14
    ports:
      - 5404:5432
    volumes:
      - ./data/bsky:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=password

  bsky_redis:
    container_name: bsky_redis
    image: redis
    ports:
      - 6379:6379
    volumes:
      - ./data/redis:/data

  bsky:
    container_name: bsky
    build:
      context: .
      dockerfile: services/bsky/Dockerfile
    ports:
      - 2584:2584
    depends_on:
      - bsky_db
      - bsky_redis
    network_mode: host
    restart: unless-stopped
    env_file:
      - ./.bsky.env
    volumes:
      - type: bind
        source: ./services/bsky
        target: /app/services/bsky
```

### appview : SERVICE_SIGNING_KEY/SERVER_DID

> packages/devn-env/src/bsky.ts 

```ts
//SERVICE_SIGNING_KEY=xxx
//SERVER_DID=did:plc:xxx
  static async create(cfg: BskyConfig): Promise<TestBsky> {
    // packages/crypto/tests/keypairs.test.ts
    const serviceKeypair = await Secp256k1Keypair.create({ exportable: true })
    console.log(`ROTATION_KEY=${serviceKeypair.did()}`)
    const exported = await serviceKeypair.export()
    const plcClient = new PlcClient(cfg.plcUrl)

    const port = cfg.port || (await getPort())
    const url = `http://localhost:${port}`
    const serverDid = await plcClient.createDid({
      signingKey: serviceKeypair.did(),
      rotationKeys: [serviceKeypair.did()],
      handle: 'bsky.test',
      pds: `http://localhost:${port}`,
      signer: serviceKeypair,
    })
    console.log(`SERVER_DID=${serverDid}`)

    const server = bsky.BskyAppView.create({
      db,
      redis: redisCache,
      config,
      algos: cfg.algos,
      imgInvalidator: cfg.imgInvalidator,
      signingKey: serviceKeypair,
    })
```

```sh
# https://web.plc.directory/api/redoc#operation/ResolveDid
url=https://plc.directory/did:plc:pyc2ihzpelxtg4cdkfzbhcv4
json='{ "type": "create", "signingKey": "did:key:zQ3shP5TBe1sQfSttXty15FAEHV1DZgcxRZNxvEWnPfLFwLxJ", "recoveryKey": "did:key:zQ3shhCGUqDKjStzuDxPkTxN6ujddP4RkEKJJouJGRRkaLGbg", "handle": "first-post.bsky.social", "service": "https://bsky.social", "prev": null, "sig": "yvN4nQYWTZTDl9nKSSyC5EC3nsF5g4S56OmRg9G6_-pM6FCItV2U2u14riiMGyHiCD86l6O-1xC5MPwf8vVsRw" }'
curl -X POST -H "Content-Type: application/json" -d "$json" $url | jq .
```

### pds : invitecode 

```sh
host=example.com
admin_password="admin-pass"
url=https://$host/xrpc/com.atproto.server.createInviteCode
json="{\"useCount\":1}"
curl -X POST -u admin:${admin_password} -H "Content-Type: application/json" -d "$json" -sL $url | jq .
```
