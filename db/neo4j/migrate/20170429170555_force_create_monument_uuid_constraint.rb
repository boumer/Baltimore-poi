class ForceCreateMonumentUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Monument, :uuid, force: true
  end

  def down
    drop_constraint :Monument, :uuid
  end
end
