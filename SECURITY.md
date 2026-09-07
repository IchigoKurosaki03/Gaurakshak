# Security and deployment

GauRakshak handles farm and animal-health data. The included setup is a local
development demo, not a production deployment.

Before deployment, set `APP_ENV=production`, a long random `JWT_SECRET_KEY`,
and `DEMO_AUTH_ENABLED=false`. The backend will refuse to start in production
when either insecure default remains. Connect `/auth/login` and
`/auth/verify-otp` to a rate-limited SMS provider before disabling demo auth.

Use HTTPS, restrict `CORS_ORIGINS` to the deployed application origins, store
secrets in the deployment environment, use PostgreSQL with migrations, and
back up the database. Do not expose the local SQLite database, CSV dataset, or
the FastAPI docs publicly without authentication and network controls.
