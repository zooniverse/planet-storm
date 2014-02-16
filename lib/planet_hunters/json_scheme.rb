require 'java'
require 'json'

import_java 'backtype.storm.spout.Scheme'
import_java 'backtype.storm.spout.Values'
import_java 'backtype.storm.spout.Fields'

class JsonScheme < Scheme
  def deserialize(bytes)
    json_str = String.from_java_bytes(bytes)
    Values.new(JSON.parse(json_str))
  end

  def getOutputFields
    Fields.new("str")
  end
end
