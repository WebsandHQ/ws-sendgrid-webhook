REPORTER = spec
SLOW = 10000
TIMEOUT = 20000
all: build

build:
	@coffee \
		-c \
		-o obj src

clean:
	@find  obj -type f | grep -v ".gitignore$$" | xargs rm
	@find  obj -type d | grep -v "^obj$$" | xargs rmdir

watch:
	@coffee \
		-o obj \
		-cw src


# the test build - we drop the test database and then version control it and bring it up to date
# the test scripts will then load the fixtures as needed.

TESTS = $(shell find test/tests -iname '*.coffee')
ifdef TEST
	THE_TESTS = $(join 'test/tests/', ${TEST})
else
	THE_TESTS = ${TESTS}
endif

test: build
	@NODE_TESTING=1 mocha \
		--compilers coffee:coffee-script \
		--reporter $(REPORTER) \
		--slow ${SLOW} \
		--timeout ${TIMEOUT} \
		${THE_TESTS}

test_clean: clean_db test

.PHONY: build browser_install clean watch test
