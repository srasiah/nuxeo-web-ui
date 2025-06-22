# ===== Configuration (default values) =====
REVISION ?= 3.1.19-SNAPSHOT
RELEASE_VERSION ?= 3.1.19
MAVEN_PROFILE ?= -Pdistrib
MAVEN_INTERNAL_URL ?= https://packages.nuxeo.com/repository/maven-internal
MAVEN_DEPLOY := -DaltDeploymentRepository=github::default::https://maven.pkg.github.com/OWNER/REPO
ORG_NAME ?= your-org-name
MAVEN_WEBUI_GROUP_ID ?= org.nuxeo.web.ui
PACKAGE_NAME ?= org.nuxeo.web.ui.nuxeo-web-ui-parent

# ===== Optional .env Loading =====
ifneq (,$(wildcard .env))
include .env
export
endif

# ===== Maven Configuration =====
MAVEN_OPTS := -Xmx4g -Xms2g -XX:+TieredCompilation -XX:TieredStopAtLevel=1
MAVEN_COMMON := -B -DskipTests -Dnuxeo.skip.enforcer=true -T6

# ===== Targets =====
.PHONY: all build-marketplace build-release-marketplace release-marketplace \
        set_version reset_version deploy-marketplace \
        delete-version delete-version-org delete-packages delete-snapshots \
        check-env test

all: build-marketplace

build-marketplace: _build-marketplace deploy-marketplace
	@echo "✅ Release build successful."

build-release-marketplace: set_version _build-release-marketplace deploy-marketplace reset_version
	@echo "🎉 Full release completed: built, deployed, and version reset."

_build-marketplace:
	@echo "🐳 Building Docker base image and dependencies..."
	@echo "   - Revision: $(REVISION)"
	@export MAVEN_OPTS='$(MAVEN_OPTS)' && \
	mvn clean install $(MAVEN_PROFILE) -pl plugin/web-ui/marketplace -am \
		$(MAVEN_COMMON)

_build-release-marketplace:
	@echo "🔨 Building release version: $(RELEASE_VERSION)"
	@export MAVEN_OPTS='$(MAVEN_OPTS)' && \
	mvn clean install $(MAVEN_PROFILE) -pl plugin/web-ui/marketplace -am \
		$(MAVEN_COMMON)

set_version:
	@echo "📝 Setting new version: $(RELEASE_VERSION)"
	mvn versions:set -DnewVersion=$(RELEASE_VERSION)

reset_version:
	@echo "🔁 Reverting to previous version using versions:revert..."
	mvn versions:revert

# ===== Deploy =====
deploy-marketplace:
	@echo "📦 Deploying Maven artifact to GitHub Packages..."
	@export MAVEN_OPTS='$(MAVEN_OPTS)' && \
	mvn deploy -Pdistrib -pl plugin/web-ui/marketplace -am \
		$(MAVEN_COMMON) \
		$(MAVEN_DEPLOY)

# ===== Check Required ENV =====
check-env:
	@[[ -n "$(GITHUB_TOKEN)" ]] || (echo "❌ GITHUB_TOKEN is not set" && exit 1)

# ===== Diagnostic Target =====
test:
	@echo "🔧 Test Environment:"
	@printf '%-25s %s\n' "REVISION:" "$(REVISION)"
	@printf '%-25s %s\n' "RELEASE_VERSION:" "$(RELEASE_VERSION)"
	@printf '%-25s %s\n' "MAVEN_PROFILE:" "$(MAVEN_PROFILE)"
	@printf '%-25s %s\n' "MAVEN_INTERNAL_URL:" "$(MAVEN_INTERNAL_URL)"
	@printf '%-25s %s\n' "MAVEN_DEPLOY:" "$(MAVEN_DEPLOY)"
	@printf '%-25s %s\n' "MAVEN_OPTS:" "$(MAVEN_OPTS)"
	@printf '%-25s %s\n' "MAVEN_COMMON:" "$(MAVEN_COMMON)"
	@printf '%-25s %s\n' "ORG_NAME:" "$(ORG_NAME)"
	@printf '%-25s %s\n' "MAVEN_WEBUI_GROUP_ID:" "$(MAVEN_WEBUI_GROUP_ID)"
	@printf '%-25s %s\n' "PACKAGE_NAME:" "$(PACKAGE_NAME)"
	@printf '%-25s %s\n' "GITHUB_USER:" "$${GITHUB_USER:-<not set>}"
	@printf '%-25s %s\n' "GITHUB_TOKEN:" "$$( [ -n "$$GITHUB_TOKEN" ] && echo '***' || echo '<not set>' )"
	@printf '%-25s %s\n' "Delete script path:" "./scripts/delete-private-packages.sh"
