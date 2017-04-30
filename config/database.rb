require 'neo4j'
require 'neo4j/core/cypher_session/adaptors/http'

neo4j_url = ENV.fetch('GRAPHENEDB_URL') { 'http://neo4j:password@localhost:7474' }

adaptor = Neo4j::Core::CypherSession::Adaptors::HTTP.new(neo4j_url, wrap_level: :proc)
new_connection = proc { Neo4j::Core::CypherSession.new(adaptor) }

Neo4j::ActiveBase.on_establish_session(&new_connection)
Neo4j::ActiveBase.current_session = new_connection.call
