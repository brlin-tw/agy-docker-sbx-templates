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

### Injecting Antigravity Credentials via Kit

To run the sandbox pre-authenticated with your host's Antigravity credentials:

1. Prepare the authentication kit with your current host credentials:

   ```console
   ./prepare-auth-kit.sh
   ```

2. Run the sandbox with the kit attached:

   ```console
   sbx run --kit ./kits/antigravity-auth/ --template antigravity:latest shell
   ```

## Licensing

Unless otherwise noted([comment headers](https://reuse.software/spec-3.3/#comment-headers)/[REUSE.toml](https://reuse.software/spec-3.3/#reusetoml)), this product is licensed under [the 3.0 version of the GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.html), or any of its more recent versions of your preference.

This work complies to [the REUSE Specification](https://reuse.software/spec/), refer to the [REUSE - Make licensing easy for everyone](https://reuse.software/) website for info regarding the licensing of this product.
