# Docker

Our application is entirely containerized using Docker. Upon the recommendation from our cyber team, we configured our development environment to use non-root Docker. This is different from rootless Docker, which we eventually implemented in the cloud version of our application.

---

# Authentication

Several security-conscious decisions have been made regarding user authentication. This is handled exclusively through Auth0, which we use to manage user profiles.

- **Email verification** — users must verify their email address upon registration.
- **Domain enforcement** — student access is restricted to `crimson.ua.edu` addresses.
- **Admin role assignments** — admin access in deployment is managed through role delegation.

---

# HTTPS Deployment

Our application has been deployed to a custom HTTPS domain. This resolved a couple of security concerns. Notably, in order to access the Django admin panel, we previously exposed port 8000 to universal traffic. It is now accessed through a proxy setup that is only accessible to an authenticated Auth0 admin user.

---

# Backlogged Items

- Upgrading our PostgreSQL instance to the latest version.
- Configuring Auth0 for deployment.
- Fixing minor browser caching issues. For example, on a local deployment, if an admin has recently logged in, their authentication cookies will persist and a non-admin user may gain access to the Django admin sign-in page.
- Improving HTTP action sanitization.
