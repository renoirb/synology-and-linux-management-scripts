include ./Makefile.head


SHELLCHECK             = $(shell command -v shellcheck)


# Help is not the default target cause its mainly used as the main
# build command. We're reserving it.
help-default help: .title
	@echo "    Usage: make NAME [PARAMETERS]"
	@echo ""
	@make -s .menu-item tgt="help" desc="Shows Help Menu: type: make help"
	@make -s .menu-item tgt="shellcheck" desc="Runs shellcheck on all shell scripts"
	@echo ""


.PHONY: *.sh
*.sh:
	@$(SHELLCHECK) $@


.PHONY: prettier
prettier:
	@npx @renoirb/conventions-use-prettier -w '{**/,}*.md'


shellcheck: $(wildcard *.sh)

