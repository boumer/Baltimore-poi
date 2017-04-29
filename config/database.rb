require 'neo4j'
require 'neo4j/core/cypher_session/adaptors/http'

adaptor = Neo4j::Core::CypherSession::Adaptors::HTTP.new('http://neo4j:password@localhost:7474', wrap_level: :proc)
new_connection = proc { Neo4j::Core::CypherSession.new(adaptor) }

Neo4j::ActiveBase.on_establish_session(&new_connection)
Neo4j::ActiveBase.current_session = new_connection.call
