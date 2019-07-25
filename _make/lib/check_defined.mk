# Source: http://stackoverflow.com/a/10858332
# Retrieved: 2017-May-4
# Call example::
#
# include ../_make/lib/check_defined.make
# $(call check_defined, MY_FLAG OTHER_FLAG)
#
# NOTE: this code has a bootstrap issue because it can require a
#   constructed settings.mk file for hosts.  However, before
#   settings.mk is constructed some things (VIRTUAL_ENV for example)
#   may not be defined.  This prevents settings.mk from being built.
#
# To solve this, Hostmain.make adds a __SETTINGS_READY flag at the end.

# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
ifdef __SETTINGS_READY
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))
else
check_defined = 
endif