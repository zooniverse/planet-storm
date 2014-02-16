require './spouts/classifications_spout'
require 'red_storm'

class PlanetHuntersTopology < RedStorm::DSL::Topology

  spout ClassificationsSpout, parallelism: 2 do
    output_fields :classification
  end

  bolt Split, parallelism: 2 do
    output_fields :marking, :subject_id
    source ClassificationSpout, :shuffle
  end

  bolt Cluster, parallelism: 2 do
    output_fields :transit, :subject_id
    source Split, fields: ["subject_id"]
  end

  bolt GenSecondary, parallelism: 2 do
    output_fields :secondary_subject
    source Cluster, :shuffle
  end


end
