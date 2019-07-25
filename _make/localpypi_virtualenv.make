# Use this when you must have localpypi setup for the virtualenv

include ../_make/localpypi.make ../_make/virtualenv.make

localpypi_virtualenv.evt: virtualenv.evt | localpypi.evt 