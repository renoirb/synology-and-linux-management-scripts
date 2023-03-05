include ./Makefile.head


SHELLCHECK             = $(shell command -v shellcheck)
NPX                    = $(shell command -v npx)

#
# # Bookmarks of cool notes
#
# Because I never remember all the possible ways to twist things
#
# - https://github.com/xelalexv/dregsy/blob/b0615fda/Makefile
# - https://gist.github.com/evertrol/4b6fd05f3b6be2b331c60638b1af7101
# - https://github.com/xelalexv/dregsy/blob/b0615fda/Makefile
# - https://github.com/box/Makefile.test


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

