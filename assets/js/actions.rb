require 'grand_central/action'

Action = GrandCentral::Action.create

GetCurrentLocation = Action.create
SetCurrentLocation = Action.with_attributes(:location)
