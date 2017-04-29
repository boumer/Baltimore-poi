class ForceCreateReligiousBuildingUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :ReligiousBuilding, :uuid, force: true
  end

  def down
    drop_constraint :ReligiousBuilding, :uuid
  end
end
