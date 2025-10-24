# Terraform IaC Plan — Stepwise Implementation

## Prompt ✅

> Role: Assume you're a Senior Software Engineer
>
> Input: Generate a plan to generate Terraform infrastructure as code.
>
> Steps:
>
> * Generate a plan first; each step will be reviewed and approved one at a time.
>
> * Ensure Terraform is accurate and use **official docs only** to generate code (in later stages upon approval).
>
> * Use a canvas (or file workspace) for the code.
>
> * Only make changes to the canvas after review and approval from the user
>
> * Use ✅ emoji to indicate which steps are completed, upon completion of the step
>
> Expected output: Working, executable Terraform code to generate the infrastructure.

---

## Goals

* Deliver production-grade, modular Terraform code (HCL) that is executable with `terraform init/plan/apply`.
* Follow Terraform best practices: remote state, locking, modules, separation of concerns, immutability where possible.
* Provide tests and linters (fmt/validate/tflint/tfsec or equivalents) in later stages.

---

## Required access & pre-reqs (before implementation)

* Cloud account(s) with permissions to create resources.
* Git repository to store Terraform code.
* Secrets backend for CI (GitHub Secrets or equivalent).

---

## High-level repo structure (what I'll create)

```
infra/                      # root for terraform
  ├── README.md
  ├── versions.tf           # terraform & provider constraints
   ├── (remote backend configured at runtime) # configure with `terraform init -backend-config` or via CI
  ├── modules/              # reusable modules
  │     ├── network/
  │     ├── compute/
  │     ├── db/
  │     ├── iam/
  │     └── monitoring/
  ├── envs/
  │     ├── prod/
  │     └── stage/
  │         └── main.tf
  └── ci/                   # placeholder for workflows
```

Modules will be **called from environment-specific configs** and accept inputs to customize resources per environment.

---

## Stepwise plan (review & approve one step at a time)

Each step includes: **Objective → Tasks → Deliverables → Acceptance Criteria**.

### Step 1 — Requirements & scope ✅

**Objective:** Lock scope and exact resource list for Azure deployment, account/regions, compliance needs, cost limits.

**Requirements (Azure-specific):**

1. **Network:**

   * Azure VNet with a single subnet for AKS (defaults used)
   * Subnet for PostgreSQL (default configuration)

2. **Compute:**

   * Azure Kubernetes Service (AKS), basic small cluster for MVP, no autoscaling

3. **Database:**

   * Azure PostgreSQL with PGVector extension, basic sizing for MVP

4. **Storage:**

   * Azure Storage Account with single $web container for front-end deployment

5. **IAM:**

   * Not specified yet (to be decided)

6. **Regions / Availability Zones:**

   * Not required for MVP

7. **Tagging and naming conventions:**

   * Not required for MVP

8. **Compliance / Security requirements:**

   * Use Azure defaults

**Acceptance Criteria:** You confirm the resource list and settings for Azure deployment.

---

### Step 2 — Repo skeleton & development conventions ✅

**Objective:** Create repository skeleton and developer conventions.

**Tasks:**

* Create repo folder structure (as above), `versions.tf`, runtime backend configuration, `.gitignore`, `README.md` with usage.

**Deliverable:** Repo skeleton and files initialized to allow `terraform init` and `terraform plan` to work.

**Acceptance Criteria:** Running `terraform init` and `terraform plan` in the environment directory succeeds without errors.

---

### Step 3 — Local state backend, locking, and secrets workflow ✅

**Objective:** Use a local backend for development and CI-friendly remote backend patterns documented for later migration.

Rationale: until remote backend credentials and subscription details are available we keep a local backend per-environment for fast iteration and safe testing. We'll document a clear migration path to the `azurerm` remote backend so switching to remote state is reproducible and secure.

---

### Step 4 — Provider & module registry baseline ✅

**Objective:** Define provider blocks and initial module interfaces.

**Tasks:**

* Add `providers.tf` and `versions.tf` with pinned provider versions.
* Create empty module interfaces for `network`, `compute`, `db`, `iam`, `monitoring` with clear variable and output contracts.

**Deliverable:** `providers.tf` + module skeletons committed.

**Acceptance Criteria:** You approve the provider choices and module interfaces.

---

### Step 5 — Network module ✅

**Objective:** Implement the `network` module and wire it into environment configs.

**Tasks:**

* Build VNet, subnets, route tables, security groups, and common endpoints.
* Outputs: VNet ID, subnet IDs, route tables, default security groups.

**Deliverable:** Network module with examples and docs.

**Acceptance Criteria:** `terraform plan` for network-only returns planned resources without errors; outputs are sensible.

---

### Step 6 — IAM module

**Objective:** Implement IAM constructs needed for resources.

**Tasks:**

* Create roles and service principals for compute and storage access.
* Add MFA/assume-role guidance for operators.

**Deliverable:** `iam` module and policy JSONs.

**Acceptance Criteria:** Roles and policies are modular, least-privilege, and referenced by other modules.

Note: Step 6 is skipped for now per user instruction. We'll implement IAM after compute if needed for service principals and least-privilege policies.

---

### Step 7 — Compute module ✅

**Objective:** Implement compute resources with AKS configuration.

**Tasks:**

* Create `compute` module with AKS cluster.
* Configure any required RBAC or attached policies.

**Deliverable:** `compute` module and example environment usage.

**Acceptance Criteria:** `terraform plan` adds compute resources successfully.

---

### Step 8 — Database & storage module ✅

**Objective:** Implement PostgreSQL and Storage Account.

**Tasks:**

* `db` module for PostgreSQL provisioning with PGVector.
* `storage` module for Storage Account with $web container.

**Deliverable:** `db` and `storage` modules.

**Acceptance Criteria:** Databases plan & apply succeed; credentials handled via secrets.

Notes about PGVector and DB readiness

- The DB module will be prepared for PGVector (the `pgvector` extension) but will NOT automatically run extension creation. You asked to enable the extension directly on the DB, so the module will:
   - Default the server Postgres major version to 14 (configurable via variable `postgres_version`). PGVector requires Postgres 13+; we choose 14 as the default for compatibility.
   - Use a SKU and storage profile suitable for extensions and reasonable performance (configurable via `sku_name` / `db_sku` and `storage_gb`).
   - Expose variables to switch between public access and VNet delegated subnet deployment (the module supports both patterns; enabling VNet access requires a Private DNS zone and is optional).
   - Expose the admin username and (placeholder) admin password as inputs — rotate and store these in Key Vault or CI secrets for production.
   - Document the exact psql command to enable PGVector manually; e.g.:

      PGPASSWORD='<admin-password>' psql "host=<server-fqdn> port=5432 user=<admin-user> dbname=<db-name> sslmode=require" -c "CREATE EXTENSION IF NOT EXISTS pgvector;"

   - Note: some managed database providers may require additional configuration or version support for installing optional extensions. If you prefer, we can add an optional run-once provisioning step (CI job or `null_resource` with `local-exec`) to enable the extension; you asked to enable it manually so this is left out of the default apply.

**Acceptance Criteria (updated):** Databases plan & apply succeed; the server is provisioned with Postgres >=14 and the module documents the manual `CREATE EXTENSION pgvector` command so you can enable it directly on the DB after networking/credentials are configured.

---

### Step 9 — Monitoring module

**Objective:** Wire Azure Monitor for logs and metrics; implement basic alerting.

**Tasks:**

* Centralized log group patterns, retention, metrics filters for important alerts.
* Export important metrics and document runbook for alert response.

**Deliverable:** `monitoring` module and `alerts.md` runbook.

**Acceptance Criteria:** Alerts can be created via Terraform; test alerts appear in monitoring.

### Step 10 — Application Gateway

**Objective:** Provision an Azure Application Gateway (v2) to provide ingress for the AKS cluster, support TLS termination, and optionally integrate with the Web Application Firewall (WAF) policy.

**Tasks:**

* Create an `app_gateway` module that provisions an Application Gateway v2 with a configurable frontend IP (public or private), listener(s), HTTP settings, and backend pool referencing AKS ingress NICs or service IPs.
* Add optional support for TLS termination by accepting certificate secret references (Key Vault or file path) and configuring HTTPS listeners.
* Provide an option to enable WAF (OWASP 3.2 ruleset) with configurable mode (Prevention/Detection) and logging to Azure Monitor.
* Output the Application Gateway resource ID, frontend IP, public FQDN (if public), and associated subnet ID.
* Document integration notes for AKS ingress controller (NGINX/Azure Application Gateway Ingress Controller) including required role assignments and annotations.

**Deliverable:** `modules/app_gateway` module with examples and docs, plus a short example in `envs/stage/main.tf` showing how to wire the module to the `compute`/AKS outputs.

**Acceptance Criteria:** `terraform plan` for the environment including the `app_gateway` module shows the Application Gateway resources planned without errors; outputs return the gateway ID and frontend address. Documentation explains how to wire AKS ingress controller and configure TLS and WAF.

---

## Implementation approach & guarantees

* **One step at a time:** I will not implement the next step until you approve the previous step.
* **Official docs only for code:** Terraform HCL will follow **official Terraform provider docs**.
* **Modular & testable:** Modules will be small, documented, and maintainable; examples included for envs.
* **No secrets in repo:** All secrets will be variables with guidance to store them in CI secret manager.

---

## Next action for you

Step 2 has been approved; we can now initialize the repo skeleton so `terraform init` and `terraform plan` work.

---

## How to use this skeleton

Quick local test (uses local backend inside an env):

1. cd into an environment, for example `cd envs/stage`
2. terraform init
3. terraform plan

To use a remote `azurerm` backend, provide backend configuration at runtime with `terraform init -backend-config=...` or configure your CI to pass the backend values from secrets.

Do not commit secrets or access keys. Use CI secret stores for automation.
