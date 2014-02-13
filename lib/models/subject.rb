require 'net/http'

class Subject
  attr_reader :points

  def self.from_id(id)
    # code to fetch_subject once I have access to docs
  end

  def self.from_old(old_sub, new_transit)
    sub_hash = old_sub.to_hash
    sub_hash['points'] = new_transit
    sub_hash['_id'] = nil
  end

  def to_hash
    h = Hash.new(@hash)
    h['points'] = @points
    h
  end
  
end
