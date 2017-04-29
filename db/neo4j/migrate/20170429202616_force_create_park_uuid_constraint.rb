class ForceCreateParkUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Park, :uuid, force: true
  end

  def down
    drop_constraint :Park, :uuid
  end
end
