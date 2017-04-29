class ForceCreateLandmarkUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Landmark, :uuid, force: true
  end

  def down
    drop_constraint :Landmark, :uuid
  end
end
