# Antigravity CLI Docker sandbox templates

Container image templates to run Antigravity CLI using the Docker Sandboxes utility

<https://gitlab.com/brlin/agy-docker-sbx-templates>  
[![The GitLab CI pipeline status badge of the project's `main` branch](https://gitlab.com/brlin/agy-docker-sbx-templates/badges/main/pipeline.svg?ignore_skipped=true "Click here to check out the comprehensive status of the GitLab CI pipelines")](https://gitlab.com/brlin/agy-docker-sbx-templates/-/pipelines) [![GitHub Actions workflow status badge](https://github.com/brlin-tw/agy-docker-sbx-templates/actions/workflows/check-potential-problems.yml/badge.svg "GitHub Actions workflow status")](https://github.com/brlin-tw/agy-docker-sbx-templates/actions/workflows/check-potential-problems.yml) [![pre-commit enabled badge](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white "This project uses pre-commit to check potential problems")](https://pre-commit.com/) [![REUSE Specification compliance badge](https://api.reuse.software/badge/gitlab.com/brlin/agy-docker-sbx-templates "This project complies to the REUSE specification to decrease software licensing costs")](https://api.reuse.software/info/gitlab.com/brlin/agy-docker-sbx-templates)

## Usage

### Prerequisites

* [Docker Desktop](https://www.docker.com/products/docker-desktop/) with Docker Sandboxes (`sbx`) enabled
* Docker CLI

### Building the Template Image

You can build the template using the provided helper script:

```console
# Build default base variant
./build-sandbox-template.sh base

# Or build Docker-in-Docker variant
./build-sandbox-template.sh dind antigravity:dind agy-template-dind.tar
```

Alternatively, build manually using Docker CLI:

```console
# Base template
docker build -t antigravity:latest -f Dockerfile .

# Docker-in-Docker template
docker build -t antigravity:dind -f Dockerfile.dind .
```

### Loading the Template into Docker Sandboxes

Save the image archive and load it directly into the sandbox runtime image store:

```console
docker image save antigravity:latest -o agy-template.tar
sbx template load agy-template.tar
```

### Running Antigravity CLI in a Sandbox

Launch a new sandbox shell session using the custom template:

```console
sbx run --template antigravity:latest shell
```

### Running as a Dedicated Agent

You can also run Antigravity as a first-class agent using the Agent Kit definition:

```console
sbx run --kit ./agents/antigravity/ antigravity
```

### Injecting Antigravity Credentials and Authentication

Because Docker Sandboxes run inside isolated MicroVMs, the host operating system's native D-Bus Keyring / Secret Service (where desktop OAuth refresh tokens are kept) is not accessible from inside the sandbox.

You can configure and authenticate Antigravity CLI using any of the following approaches:

#### Method 1: Using the Configuration Kit

1. Prepare the authentication kit with your current host configuration files (`settings.json`, `keybindings.json`):

   ```console
   ./prepare-auth-kit.sh
   ```

2. Run the sandbox with the kit attached:

   ```console
   # Running as a shell
   sbx run --kit ./kits/antigravity-auth/ --template antigravity:latest shell

   # Or running as a dedicated agent
   sbx run --kit ./agents/antigravity/ --kit ./kits/antigravity-auth/ antigravity
   ```

#### Method 2: Host-Managed Dynamic Secret Injection (Recommended)

Docker Sandboxes can dynamically resolve and inject credentials on the host side without ever storing plaintext secrets in the sandbox microVM:

1. Store or bind the credential for the `antigravity` service in `sbx`:

   ```console
   # Set API key interactively:
   sbx secret set antigravity

   # Or dynamically resolve using host CLI (e.g. gcloud):
   sbx secret set antigravity --command "gcloud auth print-access-token"

   # Or dynamically resolve from a secret manager (e.g. 1Password):
   sbx secret set antigravity --ref "op://Work/Gemini/api-key"
   ```

2. Run the agent or sandbox with the kit:

   ```console
   sbx run --kit ./agents/antigravity/ antigravity
   ```

   The Docker Sandboxes proxy will automatically intercept outbound requests to `*.googleapis.com` and inject the resolved `Authorization: Bearer <token>` header securely on the host side.

#### Method 3: Direct API Key Passing

Pass your Gemini API key via environment variable:

```console
sbx run --template antigravity:latest -e GEMINI_API_KEY="your-api-key" shell
```

#### Method 4: Persistent Sandbox OAuth Sign-In

Docker Sandboxes preserves the guest filesystem state across restarts for a named sandbox:

1. Launch a named sandbox:

   ```console
   sbx run --name antigravity-dev --template antigravity:latest shell
   ```

2. Inside the sandbox, run `agy` and complete the browser OAuth sign-in loop once.
3. Subsequent runs with `sbx run --name antigravity-dev shell` will reuse the authenticated session.

## Credits

Special thanks to [Oleg Šelajev](https://github.com/shelajev) for the [agy-sbx-kit](https://github.com/shelajev/agy-sbx-kit) project, which provided inspiration for Docker Sandboxes OAuth proxy interception, `--mode=accept-edits` configuration, and headless Google authentication patterns.

## Licensing

Unless otherwise noted([comment headers](https://reuse.software/spec-3.3/#comment-headers)/[REUSE.toml](https://reuse.software/spec-3.3/#reusetoml)), this product is licensed under [the 3.0 version of the GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.html), or any of its more recent versions of your preference.

This work complies to [the REUSE Specification](https://reuse.software/spec/), refer to the [REUSE - Make licensing easy for everyone](https://reuse.software/) website for info regarding the licensing of this product.
