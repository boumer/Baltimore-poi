class ForceCreateLibraryUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Library, :uuid, force: true
  end

  def down
    drop_constraint :Library, :uuid
  end
end
