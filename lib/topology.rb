require './spouts/classifications_spout'
require 'red_storm'

class PHTopology < RedStorm::DSL::Topology

  spout ClassificationsSpout, parallelism: 2 do
    output_fields :classification_json
  end

  bolt ParseJSON, parallelism: 2 do
    output_fields :classification
    source ClassificationsSpout, :shuffle
  end

  bolt Split, parallelism: 2 do
    output_fields :marking, :subject_id
    source ParseJSON, :shuffle
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
