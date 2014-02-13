require 'red_storm'
require 'json'

class ParseJSON < RedStorm::DSL::Spout
  on_receive do |tuple|
    [JSON.parse(tuple[:classification_json])]
  end
end
