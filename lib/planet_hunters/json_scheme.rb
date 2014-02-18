require 'java'
require 'json'

java_import 'backtype.storm.spout.Scheme'
java_import 'backtype.storm.tuple.Values'
java_import 'backtype.storm.tuple.Fields'

class JsonScheme 
  include Scheme
  def deserialize(bytes)
    json_str = String.from_java_bytes(bytes)
    Values.new(JSON.parse(json_str))
  end

  def getOutputFields
    Fields.new("str")
  end
end
