require 'red_storm'

class SplitBolt < RedStorm::DSL::Bolt
  on_receive do |tuple|
    c = tuple[:classification]
    subject_id = c['subjects'].first['_id']
    c['annotations']['markings'].map do |r|
      [r, subject_id]
    end
  end
end
