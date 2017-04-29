class ForceCreateMuseumUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Museum, :uuid, force: true
  end

  def down
    drop_constraint :Museum, :uuid
  end
end
