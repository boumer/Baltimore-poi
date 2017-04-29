class ForceCreateNeighborhoodUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Neighborhood, :uuid, force: true
  end

  def down
    drop_constraint :Neighborhood, :uuid
  end
end
