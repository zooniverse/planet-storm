require 'red_storm'

class Split < RedStorm::DSL::Bolt
  on_recieve do |tuple|
    c = tuple[:classification]
    subject_id = c['subjects'].first['_id']
    c['ranges'].map do |r|
      [r, subject_id]
    end
  end
end
