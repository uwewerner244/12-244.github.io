##  ------------------------------------------------------------------------  ##
##                                Build Project                               ##
##  ------------------------------------------------------------------------  ##

.SILENT:
# .IGNORE:
.EXPORT_ALL_VARIABLES:
.ONESHELL:

SHELL = /bin/sh
THIS_FILE := $(lastword $(MAKEFILE_LIST))
TO_NULL = 2>&1 >/dev/null

# $(info [THIS_FILE:${THIS_FILE}])
##  ------------------------------------------------------------------------  ##
# $(shell [ -f NODE_ENV ] || cp -prfu config/.NODE_ENV ./NODE_ENV);
##  ------------------------------------------------------------------------  ##

##  ------------------------------------------------------------------------  ##
$(shell [ -f ./.bowerrc ] || cp -prfu config/.bowerrc ./);
$(shell [ -f ./.npmrc ] || cp -prfu config/.npmrc ./);
##  ------------------------------------------------------------------------  ##

APP_NAME := cv
APP_PREF := cv_
APP_SLOG := "CV + PORTFOLIO"
APP_LOGO := ./assets/BANNER
APP_REPO := $(shell git ls-remote --get-url)

$(shell [ -f ./VERSION ] || echo "0.0.0" > VERSION)
$(shell [ -f ./.env ] || echo "NODE_ENV=production" >> .env)

CODE_VERSION := $(strip $(shell cat ./VERSION))
GIT_BRANCH := $(shell git rev-list --remove-empty --max-count=1 --reverse --branches)
GIT_COMMIT := $(shell git rev-list --remove-empty --max-count=1 --reverse --remotes --date-order)

DT = $(shell date +'%T')
TS = $(shell date +'%s')
DZ = $(shell date +'%Y%m%dT%H%M%S%:z')

WD := $(shell pwd -P)
BD := $(WD)/bin

BUILD_FILE = BUILD-$(CODE_VERSION)
BUILD_CNTR = $(strip $(shell [ -f "$(BUILD_FILE)" ] && cat $(BUILD_FILE) || echo 0))
BUILD_CNTR := $(shell echo $$(( $(BUILD_CNTR) + 1 )))

BUILD_FULL := $(shell date +'%Y-%m-%dT%H:%M:%S%:z')
BUILD_DATE := $(shell date +'%Y-%m-%d')
BUILD_TIME := $(shell date +'%H:%M:%S')
BUILD_YEAR := $(shell date +'%Y')
BUILD_HASH := $(shell echo "$(BUILD_FULL)" | md5sum | cut -b -4)

##  ------------------------------------------------------------------------  ##
##  Colors definition
##  ------------------------------------------------------------------------  ##
include $(BD)/Colors
##  ------------------------------------------------------------------------  ##

FMP := ffmpeg -hide_banner -y -loglevel "error" -stats

DAT = [$(Gray)$(DT)$(NC)]
BEGIN = $(Yellow)$(On_Blue)BEGIN TARGET$(NC)
DONE = $(Yellow)$(On_Blue)DONE TARGET$(NC)
FINE = $(Yellow)$(On_Green)FINISHED GOAL$(NC)
TARG = [$(Orange) $@ $(NC)]
THIS = [$(Red) $(THIS_FILE) $(NC)]
OKAY = [$(White) OK $(NC)]

##  ------------------------------------------------------------------------  ##
##  BUILDs counter
##  ------------------------------------------------------------------------  ##
$(file > $(BUILD_FILE),$(BUILD_CNTR))
$(info $(DAT) Created file [$(Yellow)$(BUILD_FILE)$(NC):$(Red)$(BUILD_CNTR)$(NC)])

##  ------------------------------------------------------------------------  ##
##  BUILD information
##  ------------------------------------------------------------------------  ##
BUILD_CONTENT = $(strip $(shell cat config/build.tpl))
BUILD_CONTENT := $(subst BUILD_CNTR,$(BUILD_CNTR),$(BUILD_CONTENT))
BUILD_CONTENT := $(subst BUILD_FULL,$(BUILD_FULL),$(BUILD_CONTENT))
BUILD_CONTENT := $(subst BUILD_DATE,$(BUILD_DATE),$(BUILD_CONTENT))
BUILD_CONTENT := $(subst BUILD_TIME,$(BUILD_TIME),$(BUILD_CONTENT))
BUILD_CONTENT := $(subst BUILD_YEAR,$(BUILD_YEAR),$(BUILD_CONTENT))
BUILD_CONTENT := $(subst BUILD_HASH,$(BUILD_HASH),$(BUILD_CONTENT))
BUILD_CONTENT := $(subst GIT_COMMIT,$(GIT_COMMIT),$(BUILD_CONTENT))
BUILD_CONTENT := $(subst CODE_VERSION,$(CODE_VERSION),$(BUILD_CONTENT))

$(file > config/build.json,$(BUILD_CONTENT))
$(info $(DAT) Created file [$(Yellow)BUILD_CONTENT$(NC):$(White)$(WD)/config/build.json$(NC)])

##  ------------------------------------------------------------------------  ##
##  COMMIT information
##  ------------------------------------------------------------------------  ##
$(file > COMMIT,$(GIT_COMMIT));
$(info $(DAT) Created file [$(BYellow)COMMIT$(NC):$(White)$(GIT_COMMIT)$(NC)]);

##  ------------------------------------------------------------------------  ##
##                               DIRECTORIES                                  ##
##  ------------------------------------------------------------------------  ##

ARC := arch
SRC := src
BLD := build-${CODE_VERSION}
DST := dist-${CODE_VERSION}
WEB := web-${CODE_VERSION}-${BUILD_CNTR}

$(shell [ -d $(ARC) ] || mkdir $(ARC))

##  ------------------------------------------------------------------------  ##
##                                 PATHS                                      ##
##  ------------------------------------------------------------------------  ##

DIR_SRC := $(WD)/$(SRC)
DIR_BUILD := $(WD)/$(BLD)
DIR_DIST := $(WD)/$(DST)
DIR_WEB := $(WD)/$(WEB)

$(shell [ -d $(DIR_SRC) ]   || mkdir $(DIR_SRC))
$(shell [ -d $(DIR_BUILD) ] || mkdir $(DIR_BUILD))
$(shell [ -d $(DIR_DIST) ]  || mkdir $(DIR_DIST))
$(shell [ -d $(DIR_WEB) ]   || mkdir $(DIR_WEB))

##  ------------------------------------------------------------------------  ##

APP_ENV := $(shell grep NODE_ENV .env | cut -d "=" -f 2)
ifeq ($(APP_ENV),)
$(info $(DAT) $(Orange)APP_ENV$(NC) is $(Yellow)$(On_Red)NOT DETECTED$(NC)!)
endif

##  ------------------------------------------------------------------------  ##
##  Query default goal
##  ------------------------------------------------------------------------  ##
ifeq ($(.DEFAULT_GOAL),)
.DEFAULT_GOAL := default
endif
$(info $(DAT) $(Yellow)$(On_Purple)GOALS$(NC));
$(info $(DAT)   \-- $(Orange)DEFAULT$(NC): [$(White)$(.DEFAULT_GOAL)$(NC)]);
$(info $(DAT)   \-- $(Orange)CURRENT$(NC): [$(Blue)$(MAKECMDGOALS)$(NC)]);

##  ------------------------------------------------------------------------  ##
##                                  INCLUDES                                  ##
##  ------------------------------------------------------------------------  ##

include $(BD)/*.mk

##  ------------------------------------------------------------------------  ##

PHONY := default

default: run ;
	@ echo "$(DAT) $(FINE): $(TARG)" ;

##  ------------------------------------------------------------------------  ##

PHONY += test config

test: banner state help ;
	@ export NODE_ENV="${APP_ENV}"; npm run test
	@ echo "$(DAT) $(FINE): $(TARG)"

config:
	@ export NODE_ENV="${APP_ENV}"; npm run config
	@ echo "$(DAT) $(FINE): $(TARG)"

##  ------------------------------------------------------------------------  ##

PHONY += tasklist tasktree critical

tasklist:
	@ gulp --tasks --depth 1 --color
	@ echo "$(DAT) $(FINE): $(TARG)"

tasktree:
	@ gulp --tasks --depth 2 --color
	@ echo "$(DAT) $(FINE): $(TARG)"

# critical:
# 	@ export NODE_ENV="${APP_ENV}"; npm run crit
	# @ echo "$(DAT) $(FINE): $(TARG)"

##  ------------------------------------------------------------------------  ##
##  Create videos from *.gif files
##  ------------------------------------------------------------------------  ##
PHONY += print-names video

DIR_IMGS := $(DIR_DIST)/assets/img/works
GIF_FILES := $(notdir $(wildcard $(DIR_IMGS)/*.gif))
BASE_NAMES := $(basename $(GIF_FILES))
MPEG_FILES := $(patsubst %.gif,%.mp4,$(GIF_FILES))
WEBM_FILES := $(patsubst %.gif,%.webm,$(GIF_FILES))

print-names:;
	@ echo "DIR_IMGS = $(DIR_IMGS)"
	@ echo "GIF_FILES = $(GIF_FILES)"
	@ echo "BASE_NAMES = $(BASE_NAMES)"
	# @ echo "MPEG_FILES = $(MPEG_FILES)"
	# @ echo "WEBM_FILES = $(WEBM_FILES)"
	@ echo "$(DAT) $(DONE): $(TARG)" ;

video: ;
	@ $(foreach fbase, $(BASE_NAMES), $(FMP) -i "$(DIR_IMGS)/$(fbase).gif" -b:v 0 -crf 25 -f mp4 -vcodec libx264 -pix_fmt yuv420p "$(DIR_IMGS)/$(fbase).mp4" ;)
	@ $(foreach fbase, $(BASE_NAMES), $(FMP) -i "$(DIR_IMGS)/$(fbase).gif" -c libvpx-vp9 -b:v 0 -crf 41 "$(DIR_IMGS)/$(fbase).webm" ;)
	@ echo "RESULTS:"
	@ ls -als $(DIR_IMGS)/*.mp4
	@ ls -als $(DIR_IMGS)/*.webm
	@ echo "$(DAT) $(DONE): $(TARG)" ;

##  ------------------------------------------------------------------------  ##

PHONY += pre-update update

setup-deps: banner ;
	@ npm i -g bower
	@ npm i
	@ bower i --production
	@ touch ./setup-deps
	@ echo "$(DAT) $(FINE): $(TARG)"

setup: setup-deps ;
	@ touch ./setup
	@ echo "$(DAT) $(FINE): $(TARG)"

pre-build: banner ;
	@ rm -vf build
	@ echo "$(DAT) $(FINE): $(TARG)"

build: setup ;
	@ export NODE_ENV="${APP_ENV}"; npm run build
	@ touch ./build
	@ echo "$(DAT) $(FINE): $(TARG)"

dist: build video ;
	@ export NODE_ENV="production"; npm run dist
	# @ cp -pr ${BLD}/* ${DST}/
	@ rm -vrf ${DST}/resources
	@ tar -c "${DST}" | gzip -9 > "${ARC}/${APP_NAME}-v${CODE_VERSION}-b${BUILD_CNTR}.tar.gz"
	@ touch ./dist
	@ echo "$(DAT) $(FINE): $(TARG)"

pre-deploy: banner banner ;
	@ rm -vf deploy
	@ echo "$(DAT) $(FINE): $(TARG)"

deploy: dist banner ;
	# @ export NODE_ENV="${APP_ENV}"; npm run deploy
	@ cp -pr ${DST}/* ${WEB}/
	@ cd ${WD} && rm -vf webroot
	@ ln -s ${WEB} webroot
	@ touch ./deploy
	@ echo "$(DAT) $(FINE): $(TARG)"

pre-update: banner ;
	@ rm -vf setup setup-deps ;
	@ echo "$(DAT) $(FINE): $(TARG)"

update: pre-update setup banner ;
	@ echo "$(DAT) $(FINE): $(TARG)"

##  ------------------------------------------------------------------------  ##

PHONY += rebuild redeploy rb rd

rebuild: pre-build build ;
	@ echo "$(DAT) $(FINE): $(TARG)"

redeploy: pre-deploy rebuild deploy ;
	@ echo "$(DAT) $(FINE): $(TARG)"

rb: rebuild ;
	@ echo "$(DAT) $(FINE): $(TARG)"

rd: redeploy ;
	@ echo "$(DAT) $(FINE): $(TARG)"


##  ------------------------------------------------------------------------  ##

PHONY += _all full cycle cycle-dev dev dev-setup run watch
#* means the word "all" doesn't represent a file name in this Makefile;
#* means the Makefile has nothing to do with a file called "all" in the same directory.

_all: clean cycle banner ;
	@ echo "$(DAT) $(FINE): $(TARG)"

full: clean-all all banner ;
	@ echo "$(DAT) $(FINE): $(TARG)"

cycle: setup build deploy ;
	@ echo "$(DAT) $(FINE): $(TARG)"

cycle-dev: rd ;
	@ echo "$(DAT) $(FINE): $(TARG)"

dev: clean-dev banner cycle-dev ;
	@ export NODE_ENV="${APP_ENV}"; npm run dev
	@ echo "$(DAT) $(FINE): $(TARG)"

dev-setup: clean-deps setup banner cycle-dev ;
	@ export NODE_ENV="${APP_ENV}"; npm run dev
	@ echo "$(DAT) $(FINE): $(TARG)"

run: banner help cycle dist banner ;
	@ echo "$(DAT) $(FINE): $(TARG)"

watch:
	@ export NODE_ENV="${APP_ENV}"; npm run watch
	@ echo "$(DAT) $(FINE): $(TARG)"

##  ------------------------------------------------------------------------  ##
##  Declare the contents of the .PHONY variable as phony. We keep that
##  information in a variable so we can use it in if_changed and friends.
.PHONY: $(PHONY)

##  ------------------------------------------------------------------------  ##
