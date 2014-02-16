require 'red_storm'

class GenSecondary
  on_receive do |tuple|
    t = tuple[:transit]
    if t.ready?
      sub = Subject.from_id(t[:subject_id])
      transit = sub.points.filter do |p|
        t.contains?(p)
      end
      [Subject.from_old(sub, transit).to_json]
    end
  end
end
