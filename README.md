# Santanniadi
Immagine Docker per la gestione di tornei sportivi.

È basata interamente su [Bracket](https://github.com/evroon/bracket), fare riferimento alla repo di GitHub e alla documentazione associata per tutto.

## Volumi
L'applicazione utilizza un unico volume, che va mappato a
```/app/static```

## Porte
Le seguenti porte vengono esposte dal container:

- `3000`, dove si trova il frontend
- `8400`, dove si trova il backend (anch'esso deve essere esposto, è un'API chiamata dal browser)

## Variabili d'ambiente

Le seguenti variabili di ambiente devono essere passate al contenitore

- `PG_DSN`: **obbligatoria**. Url con credenziali dove trovare l'istanza di PosgreSQL al quale appoggiarsi
- `NEXT_PUBLIC_API_BASE_URL`: **obbligatoria**. Url al quale è esposto il backend, nel caso la porta non sia una tipica dell'http specificarla. È consigliato che il backend sia esposto in un sottodominio rispetto del frontend
- `NEXT_PUBLIC_HCAPTCHA_SITE_KEY`: **obbligatoria**. Ottenibile da [hcaptcha.com](https://www.hcaptcha.com/)
- `CORS_ORIGINS`: impostarla all'url base a cui si troverà il frontend
- `ENVIRONMENT`: impostarla a `PRODUCTION` o `DEVELOPMENT` (default)
- `ADMIN_EMAIL`: email dell'account amministratore
- `ADMIN_PASSWORD`: password dell'account amministratore
- `ALLOW_USER_REGISTRATION`: `true` o `false` (default)