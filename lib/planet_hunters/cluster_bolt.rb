require 'red_storm'
require './transit'

class ClusterBolt < RedStorm::DSL::Bolt
  on_init do 
    @transits = Hash.new{|h,k| h[k] = []}
  end

  on_receive do |tuple|
    start, finish = tuple[:marking]
    subject_id = tuple[:subject_id]
    center = start + finish / 2
    t = @transits[subject_id].filter do |c|
      c.contains?(center) || c.within(start, finish)
    end

    if t.empty?
      @transits[subject_id] << Transit.new(start, finish)
    else
      t << [start, finish]
    end

    [t, subject_id]
  end
end
