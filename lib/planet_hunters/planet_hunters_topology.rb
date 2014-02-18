require 'java'
require 'red_storm'
require './classifications_spout'
require './split_bolt'

class PlanetHuntersTopology < RedStorm::DSL::Topology

  spout ClassificationsSpout, "33.33.33.10:2181", "planet_hunters", parallelism: 2 do
    output_fields :classification
  end

  bolt SplitBolt, parallelism: 2 do
    output_fields :marking, :subject_id
    source ClassificationsSpout, :shuffle
  end

  #bolt ClusterBolt, parallelism: 2 do
    #output_fields :transit, :subject_id
    #source SplitBolt, fields: ["subject_id"]
  #end

  #bolt GenSecondary, parallelism: 2 do
    #output_fields :secondary_subject
    #source Cluster, :shuffle
  #end


end
