include ./Makefile.head


SHELLCHECK             = $(shell command -v shellcheck)
NPX                    = $(shell command -v npx)


# Help is not the default target cause its mainly used as the main
# build command. We're reserving it.
help-default help: .title
	@echo "    Usage: make NAME [PARAMETERS]"
	@echo ""
	@make -s .menu-item tgt="help" desc="Shows Help Menu: type: make help"
	@make -s .menu-item tgt="prettier" desc="Formats all Markdown files using prettier"
	@echo ""


.PHONY: prettier
prettier:
	@$(NPX) @renoirb/conventions-use-prettier -w '{**/,}*.md'

